@isTest
private class QueryConditionTests {
    
    @isTest
    static void shouldEncapsulateSObjectFieldsAndValues() {
        QueryCondition basicQuery = QueryCondition.equals(Opportunity.IsWon, true);

        System.assertEquals('IsWon = true', basicQuery.toString());
    }

    @isTest
    static void shouldEqualAnotherQueryWithTheSameValues() {
        QueryCondition basicQuery = QueryCondition.equals(Opportunity.IsWon, true);
        QueryCondition sameQuery = QueryCondition.equals(Opportunity.IsWon, true);
        System.assertEquals(basicQuery, sameQuery);
    }

    @isTest
    static void shouldProperlyRenderDatetimesAsStrings() {
        Datetime sevenDaysAgo = System.now().addDays(-7);
        QueryCondition greaterThan = QueryCondition.greaterThan(Opportunity.CreatedDate, sevenDaysAgo);
        QueryCondition basicQuery = QueryCondition.greaterThanOrEqual(Opportunity.CreatedDate, sevenDaysAgo);

        String expectedTimeString = sevenDaysAgo.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'Greenwich Mean Time');
        System.assertEquals('CreatedDate > ' + expectedTimeString, greaterThan.toString());
        System.assertEquals('CreatedDate >= ' + expectedTimeString, basicQuery.toString());
    }

    @isTest
    static void shouldProperlyFromatComparisonQueries() {
        String expectedLessThan = 'Amount < 0';
        String expectedLessThanOrEqual = 'Amount <= 0';

        QueryCondition lessThan = QueryCondition.lessThan(Opportunity.Amount, 0);
        QueryCondition lessThanOrEqual = QueryCondition.lessThanOrEqual(Opportunity.Amount, 0);

        System.assertEquals(expectedLessThan, lessThan.toString());
        System.assertEquals(expectedLessThanOrEqual, lessThanOrEqual.toString());

        String expectedNotEquals = 'Amount != 0';
        System.assertEquals(expectedNotEquals, QueryCondition.notEquals(Opportunity.Amount, 0).toString());
        String notEqualsIterable = 'Amount not in (0,1,2)';
        System.assertEquals(
            notEqualsIterable,
            QueryCondition.notEquals(Opportunity.Amount, new List<Integer>{ 0, 1, 2 }).toString()
        );
    }

    @isTest
    static void shouldProperlyHandleNumbers() {
        Double number1 = 1261992;
        Integer number2 = 1;
        Decimal number3 = 1.00;
        Long number4 = 1234567890;

        QueryCondition doubleQuery = QueryCondition.equals(Opportunity.Amount, number1);
        QueryCondition intQuery = QueryCondition.equals(Opportunity.Amount, number2);
        QueryCondition decimalQuery = QueryCondition.equals(Opportunity.Amount, number3);
        QueryCondition longQuery = QueryCondition.equals(Opportunity.Amount, number4);

        System.assertEquals('Amount = 1261992.0', doubleQuery.toString(), 'double');
        System.assertEquals('Amount = 1', intQuery.toString(), 'int');
        System.assertEquals('Amount = 1.00', decimalQuery.toString(), 'decimal');
        System.assertEquals('Amount = 1234567890', longQuery.toString(), 'long');
    }

    @isTest
    static void shouldProperlyHandleNulls() {
        Id nullId = null;

        QueryCondition idQuery = QueryCondition.equals(Opportunity.Id, nullId);

        System.assertEquals('Id = null', idQuery.toString());
    }

    @isTest
    static void shouldAllowOrStatements() {
        Id nullId = null;
        String expectedQuery = '(Id = null OR Id != null)';

        QueryCondition orQuery = QueryCondition.orQuery(QueryCondition.equals(Account.Id, nullId), QueryCondition.notEquals(Account.Id, nullId));

        System.assertEquals(expectedQuery, orQuery.toString());
    }

    @isTest
    static void shouldAllowLikeStatements() {
        String expectedName = '%someName%';

        QueryCondition likeQuery = QueryCondition.likeQuery(Account.Name, expectedName);

        System.assertEquals('Name like \'' + expectedName + '\'', likeQuery.toString());
    }

    @isTest
    static void shouldAllowNotLikeStatements() {
        String expectedName = '%someName%';

        QueryCondition notLike = QueryCondition.notLike(Account.Name, expectedName);

        System.assertEquals('(not Name like \'' + expectedName + '\')', notLike.toString());
    }

    @isTest
    static void shouldAllowLikeWithLists() {
        String firstVal = '%one';
        String secondVal = 'two%';
        List<String> expectedBindVars = new List<String>{ firstVal, secondVal };

        QueryCondition notLike = QueryCondition.notLike(Account.Name, expectedBindVars);

        System.assertEquals('(not Name like :bindVar)', notLike.toString());
        System.assertEquals(expectedBindVars, notLike.getBindVars());
    }
}
