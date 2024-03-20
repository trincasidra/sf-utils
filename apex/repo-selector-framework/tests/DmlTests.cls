@isTest
private class DmlTests {
    
    @TestSetup
    static void setup() {
        Contact con = new Contact(LastName='Test1');
        con.Email = 'something@something.com';
        insert new List<SObject>{ new Account(Name='TestAccount'), con };
    }

    @isTest
    static void shouldDoDmlInsert() {
        Contact contact = new Contact(LastName= 'Test2');
        new Dml().doInsert(contact);

        System.assertNotEquals(null, contact.Id);
    }

    @isTest
    static void shouldDoDmlUpdate() {
        Contact contact = [SELECT Id FROM Contact];

        contact.FirstName = 'Harry';
        new Dml().doUpdate(contact);

        System.assert(contact.FirstName == 'Harry');
    }

    @isTest
    static void shouldNotFailOnUpdateCallFromEmptyList() {
        List<Contact> contacts = new List<Contact>();
        new Dml().doUpdate(contacts);
    }

    @isTest
    static void shouldDoDmlUpsert() {
        Contact contact = [SELECT Id FROM Contact];
        contact.FirstName = 'Harry';
        new Dml().doUpsert(contact);

        System.assert(contact.FirstName == 'Harry');
    }

    @isTest
    static void shouldDoDmlDelete() {
        Contact contact = [SELECT Id FROM Contact];

        new Dml().doDelete(contact);
        List<Contact> deletedContacts = [SELECT Id, IsDeleted FROM Contact ALL ROWS];

        System.assert(deletedContacts[0].IsDeleted);
    }

    @isTest
    static void shouldDoDmlHardDelete() {
        Contact contact = [SELECT Id FROM Contact];

        new Dml().doHardDelete(contact);
        List<Contact> deletedContacts = [SELECT Id, IsDeleted FROM Contact ALL ROWS];

        System.assert(deletedContacts[0].IsDeleted);
    }

    @isTest
    static void shouldDoDmlUndelete() {
        Contact contact = [SELECT Id FROM Contact];

        Dml Dml = new Dml();
        Dml.doDelete(contact);
        Dml.doUndelete(contact);

        List<Contact> notDeletedContacts = [SELECT Id FROM Contact];
        System.assert(!notDeletedContacts.isEmpty());
    }

    @isTest
    static void shouldRollbackAllUpsertsIfUpsertListHadError() {
        Account one = new Account(Name = 'Test1');
        Account two = new Account();
        try {//should fail because name is a required field on Account
            new Dml().doUpsert(new List<Account>{ one, two });
        } catch (Exception e) { }
        System.assertEquals(null, one.Id);
        System.assertEquals(null, two.Id);
    }

    @isTest
    static void shouldNotFailOnUpdateDueToChunkingErrors() {
        List<SObject> records = new List<SObject>();
        List<Account> accounts = new List<Account>();
        List<Contact> contacts = new List<Contact>();

        for(Integer i = 0; i < Dml.maxDmlChunking; i ++) {
            Account a = new Account(Name=''+i);
            accounts.add(a);
            records.add(a);

            Contact c = new Contact(LastName=''+i);
            contacts.add(c);
            records.add(c);
        }

        insert accounts;
        insert contacts;

        try {
            new Dml().doUpdate(records);
        } catch(Exception ex) {
            System.assert(false, ex);
        }
    }
}
