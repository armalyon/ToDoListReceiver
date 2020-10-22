/**
 * Created by Bogdan on 20.10.2020.
 */

@IsTest
public with sharing class TodosSupplierTest {
    @IsTest
    static void testCreateTodo() {
        RestRequest request = new RestRequest();
        request.requestBody = Blob.valueOf('[ {"status" : "Planned", "startDate" : "2020-10-20",' +
                '  "recordTypeName" : "Work", "name" : "Test Todo",' +
                '  "id" : "a0009000001BKMzAAO", "description" : "Test Description",' +
                '  "deadline" : "2020-10-21", "category" : "Work" },' +
                '{"status" : "Planned", "startDate" : "2020-10-20",  "recordTypeName" : "Personal", ' +
                '"name" : "Test Todo",  "id" : "a0009000001BKMzBBB", ' +
                '"description" : "Test Description",  "deadline" : "2020-10-21", "category" : "Personal" }]}');
        RestContext.request = request;

        List<Id> newTodoIds = TodosSupplier.createTodo();

        System.assert(newTodoIds != null);
        List<ToDo__c> todos = [SELECT Name, Description__c FROM ToDo__c WHERE Id IN :newTodoIds];
        System.assert(todos.size() == 2);
        System.assertEquals(todos.get(0).Name, 'Test Todo');
        System.assertEquals(todos.get(1).Description__c, 'Test Description');
    }

    @IsTest
    static void testDeleteTodo() {
        List<Id> externalIds = new List<Id>();
        externalIds.add(createTestRecord().ExternalId__c);
        externalIds.add(createTestRecord().ExternalId__c);
        RestRequest request = new RestRequest();
        request.requestBody = Blob.valueOf(JSON.serialize(externalIds));
        RestContext.request = request;

        TodosSupplier.deleteTodo();

        List<ToDo__c> todos = [SELECT Id FROM ToDo__c];
        System.assert(todos.size() == 0);
    }

    @IsTest
    static void testUpdateTodo() {
        ToDo__c todo = createTestRecord();
        System.assert(todo != null);
        System.assertEquals(todo.Name, 'Test record');

        RestRequest request = new RestRequest();
        request.requestBody = Blob.valueOf('[{"name": "Test Update", "id":"' + todo.ExternalId__c + '", ' +
                '"recordTypeName" : "Personal"}]');
        RestContext.request = request;

        TodosSupplier.updateTodo();

        ToDo__c updatedTodo = [SELECT Id,Name FROM ToDo__c WHERE Id = :todo.Id];
        System.assert(updatedTodo != null);
        System.assertEquals(updatedTodo.Name, 'Test Update');
    }

    static ToDo__c createTestRecord() {
        ToDo__c testTodo = new ToDo__c(
                Name = 'Test record', Description__c = 'Test Desc',
                Status__c = 'Planned', Category__c = 'Personal',
                Start_Date__c = Date.parse('10/10/2020'),
                Deadline__c = Date.parse('22/11/2020'),
                ExternalId__c = 'a0009000001ycgnAAA');
        insert testTodo;
        Sub_ToDo__c subToDoTest = new Sub_ToDo__c(Name = 'Test Sub Todo', IsDone__c = false, ToDo__c = testTodo.Id);
        insert subToDoTest;
        return testTodo;
    }
}