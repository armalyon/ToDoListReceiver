/**
 * Created by Bogdan on 20.10.2020.
 */

@IsTest
public with sharing class TodosSupplierTest {
    @IsTest
    static void testCreateAccount() {
        RestRequest request = new RestRequest();
        request.requestBody = Blob.valueOf('{"name": "Test record"}');
        RestContext.request = request;

        Id thisAccountId;// = AccountManager.createAccount();

        System.assert(thisAccountId != null);
        Account thisAccount = [SELECT Id, Name FROM Account WHERE Id = :thisAccountId];
        System.assert(thisAccount != null);
        System.assertEquals(thisAccount.Name, 'Test record');
    }

    @IsTest
    static void testDeleteAccount() {
        Id recordId = createTestRecord();
        RestRequest request = new RestRequest();
        request.requestURI =
                'https:/cunning-fox-2asnae-dev-ed.lightning.force.com/services/apexrest/Accounts/' + recordId;
        request.httpMethod = 'DELETE';
        RestContext.request = request;

        //AccountManager.deleteAccount();

        List<Account> accounts = [SELECT Id FROM Account WHERE Id = :recordId];
        System.assert(accounts.size() == 0);
    }

    @IsTest
    static void testUpsertAccount() {
        // 1. Insert new record
        Id account1Id;// = AccountManager.upsertAccount(null, 'Test name', '067777777', 'www.test.com');

        System.assert(account1Id != null);
        Account account1 = [SELECT Id,Name, Phone, Website FROM Account WHERE Id = :account1Id];
        System.assert(account1 != null);
        System.assert(account1.Name == 'Test name' && account1.Phone == '067777777');

        // 2. Update status of existing record to Working
        Id account2Id;// = AccountManager.upsertAccount(account1Id, 'Test name new', '99999','www.testUpdate.com');
        System.assertEquals(account1Id, account2Id);
        Account account2 = [SELECT Id,Name, Phone, Website FROM Account WHERE Id = :account2Id];
        System.assert(account2 != null);
        System.assert(account2.Name == 'Test name new' && account2.Phone == '99999'
                && account2.Website == 'www.testUpdate.com');
    }
    @IsTest
    static void testUpdateAccountFields() {
        Id recordId = createTestRecord();
        RestRequest request = new RestRequest();
        request.requestURI =
                'https:/cunning-fox-2asnae-dev-ed.lightning.force.com/services/apexrest/Accounts/' + recordId;
        request.httpMethod = 'PATCH';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"name": "Test PATCH"}');
        RestContext.request = request;

        Id thisAccountId; //= AccountManager.updateAccountFields();

        System.assert(thisAccountId == recordId);
        Account thisAccount = [SELECT Id,Name FROM Account WHERE Id = :thisAccountId];
        System.assert(thisAccount != null);
        System.assertEquals(thisAccount.Name, 'Test PATCH');
    }

    static Id createTestRecord() {
        Account accountTest = new Account(
                Name = 'Test record');
        insert accountTest;
        Contact contactTest = new Contact(LastName = 'TestContact', AccountId = accountTest.Id);
        insert contactTest;
        return accountTest.Id;
    }
}