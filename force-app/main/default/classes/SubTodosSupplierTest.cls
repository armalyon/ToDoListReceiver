/**
 * Created by Bogdan on 22.10.2020.
 */

@IsTest
public with sharing class SubTodosSupplierTest {
    @IsTest
    static void testCreateTodo() {
        RestRequest request = new RestRequest();
        createTestRecord();
        ToDo__c parentTodo = [SELECT Id FROM ToDo__c LIMIT 1];
        System.debug(parentTodo);

        request.requestBody = Blob.valueOf('[' +
                '{"relatedToDo" : "a0009000001ycgnAAA",  "name" : "Test Subtodo", ' +
                ' "isDone" : false,  "id" : "a0109000002vfDiAAI",  "description" : "parent todo Test  "},' +
                '{"relatedToDo" : "a0009000001ycgnAAA",  "name" : "Test Subtodo2", ' +
                ' "isDone" : true,  "id" : "a0109000002vfDiAAI",  "description" : "Sub todo Test POST"} ]}');
        RestContext.request = request;

        List<Id> newTodoIds = SubTodosSupplier.createSubTodo();

        System.assert(newTodoIds != null);
        List<Sub_ToDo__c> todos = [SELECT Name, Description__c FROM Sub_ToDo__c WHERE Id IN :newTodoIds];
        System.assert(todos.size() == 2);
        System.assertEquals(todos.get(0).Name, 'Test Subtodo');
        System.assertEquals(todos.get(1).Description__c, 'Sub todo Test POST');
    }

    @IsTest
    static void testDeleteTodo() {
        List<Id> externalIds = new List<Id>();
        externalIds.add(createTestRecord().ExternalId__c);
        externalIds.add(createTestRecord().ExternalId__c);
        RestRequest request = new RestRequest();
        request.requestBody = Blob.valueOf(JSON.serialize(externalIds));
        RestContext.request = request;

        List<Sub_ToDo__c> subToDosBeforeDelete = [SELECT Id FROM Sub_ToDo__c];
        System.assert(subToDosBeforeDelete.size() == 2);

        SubTodosSupplier.deleteSubTodo();

        List<Sub_ToDo__c> subToDosAfterDelete = [SELECT Id FROM Sub_ToDo__c];
        System.assert(subToDosAfterDelete.size() == 0);
    }

    @IsTest
    static void testUpdateTodo() {
        Sub_ToDo__c todo = createTestRecord();
        System.assert(todo != null);
        System.assertEquals(todo.Name, 'Test Sub Todo');

        RestRequest request = new RestRequest();
        request.requestBody = Blob.valueOf('[' +
                '{"name" : "Test Subtodo updated",' +
                '"isDone" : false,  "id":"' + todo.ExternalId__c + '",  "description" : " todo desc Test "}]');
        RestContext.request = request;

        SubTodosSupplier.updateSubTodo();

        Sub_ToDo__c updatedTodo = [SELECT Id,Name FROM Sub_ToDo__c WHERE Id = :todo.Id];
        System.assert(updatedTodo != null);
        System.assertEquals(updatedTodo.Name, 'Test Subtodo updated');
    }

    static Sub_ToDo__c createTestRecord() {
        ToDo__c testTodo = new ToDo__c(
                Name = 'Test record', Description__c = 'Test Desc',
                Status__c = 'Planned', Category__c = 'Personal',
                Start_Date__c = Date.parse('10/10/2020'),
                Deadline__c = Date.parse('22/11/2020'),
                ExternalId__c = 'a0009000001ycgnAAA');
        insert testTodo;
        Sub_ToDo__c subToDoTest = new Sub_ToDo__c(
                Name = 'Test Sub Todo', IsDone__c = false,
                ToDo__c = testTodo.Id, ExternalId__c = 'a0009000001ycgnAAA');

        insert subToDoTest;
        return subToDoTest;
    }
}