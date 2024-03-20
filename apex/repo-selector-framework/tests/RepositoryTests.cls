@isTest
private class RepositoryTests {
    
    @isTest
    static void shouldTakeInAQuery() {
        QueryCondition basicQuery = QueryCondition.equals(ContactPointAddress.PreferenceRank, 1);
        Repository.getInstance().get(new TestSelector().whereIs(basicQuery));

        System.assertEquals(1, Limits.getQueries());
    }

    @isTest
    static void shouldHandleListsAndSetsOfIdsOrStrings() {
        Id accountId = TestingUtils.generateId(Account.SObjectType);
        Id secondAccountId = TestingUtils.generateId(Account.SObjectType);
        List<Id> ids = new List<Id>{ accountId, secondAccountId };
        Set<Id> setIds = new Set<Id>(ids);
        Set<String> cpaNames = new Set<String>{ 'Open', 'Closed' };

        QueryCondition listQuery = QueryCondition.equals(ContactPointAddress.ParentId, ids);
        QueryCondition setQuery = QueryCondition.equals(ContactPointAddress.ParentId, setIds);
        QueryCondition setStringQuery = QueryCondition.equals(ContactPointAddress.Name, cpaNames);

        IRepository repo = Repository.getInstance();

        repo.get(new TestSelector().whereIs(listQuery));
        repo.get(new TestSelector().whereIs(setQuery));
        repo.get(new TestSelector().whereIs(setStringQuery));
        System.assertEquals(3, Limits.getQueries());
        // we need to write a special assert for sets with multiple values
        System.assertEquals('Name in (\'Open\',\'Closed\')', setStringQuery.toString());
    }

    @isTest
    static void shouldProperlyShortCircuitWhenEmptyCollectionsPassedIn() {
        QueryCondition listQuery = QueryCondition.equals(ContactPointAddress.Id, new List<Id>());

        ISelector builder = new TestSelector().whereIs(listQuery);
        List<SObject> cpas = Repository.getInstance().get(builder);

        System.assertEquals(0, cpas.size());
        System.assertEquals(0, Limits.getQueries());
    }

    @isTest
    static void shouldRespectOrStatementsInQueries() {
        ContactPointAddress cpa = new ContactPointAddress(Name = 'Test Or', PreferenceRank = 1);
        ContactPointAddress secondCpa = new ContactPointAddress(Name = 'Test Or Two', PreferenceRank = 2);
        insert new List<ContactPointAddress>{ cpa, secondCpa };

        Id nullId = null;
        QueryCondition andQuery = QueryCondition.equals(ContactPointAddress.ParentId, nullId);
        QueryCondition orQuery = QueryCondition.orQuery(
            QueryCondition.equals(ContactPointAddress.PreferenceRank, cpa.PreferenceRank),
            QueryCondition.equals(ContactPointAddress.PreferenceRank, secondCpa.PreferenceRank)
        );

        ISelector builder = new TestSelector().whereIs(new List<QueryCondition>{ andQuery, orQuery });
        List<SObject> cpas = Repository.getInstance().get(builder);
        System.assertEquals(2, cpas.size());
    }

    @isTest
    static void shouldRespectNotLikeSyntaxForMultipleValues() {
        ContactPointAddress cpa = new ContactPointAddress(Name = 'Test Or', PreferenceRank = 1);
        ContactPointAddress secondCpa = new ContactPointAddress(Name = 'Something different', PreferenceRank = 2);
        insert new List<ContactPointAddress>{ cpa, secondCpa };

        QueryCondition notLike = QueryCondition.notLike(ContactPointAddress.Name, new List<String>{ cpa.Name, 'someOtherString' });

        ISelector builder = new TestSelector().whereIs(notLike);
        List<SObject> cpas = Repository.getInstance().get(builder);

        System.assertEquals(1, cpas.size());
        System.assertEquals(secondCpa.Id, cpas[0].Id);
    }

    @isTest
    static void shouldDecorateDmlMethods() {
        Repository repo = (Repository)Repository.getMockInstance();
        DmlMock dml = (DmlMock)repo.dml;
        SObject acc = new Account();
        List<SObject> accs = new List<SObject>{ acc };

        repo.doInsert(accs);
        System.assertEquals(acc, dml.records.values()[0]);
        System.assertEquals(1, dml.records.values().size());

        repo.doUpdate(accs);
        System.assertEquals(acc, dml.records.values()[0]);
        System.assertEquals(1, dml.records.values().size());

        repo.doUpsert(accs);
        System.assertEquals(acc, dml.records.values()[0]);
        System.assertEquals(1, dml.records.values().size());

        repo.doDelete(accs);
        System.assertEquals(true, dml.records.isEmpty());
        System.assertEquals(acc, dml.deletedRecords.values()[0]);

        repo.doUndelete(accs);
        System.assertEquals(acc, dml.records.values()[0]);
        System.assertEquals(true, dml.deletedRecords.isEmpty());

        repo.doHardDelete(accs);
        System.assertEquals(true, dml.records.isEmpty());
        System.assertEquals(true, dml.deletedRecords.isEmpty());
    }

    private class TestSelector extends Selector {

        private SObjectType getObjectType() {
            return ContactPointAddress.SObjectType;
        }
    
        private List<String> getObjectFields() {
            return new List<String>{
                'Id',
                'PreferenceRank',
                'ParentId',
                'Name'
            };
        }
    }
}
