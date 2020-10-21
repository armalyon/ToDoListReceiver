/**
 * Created by Bogdan on 20.10.2020.
 */

@RestResource(UrlMapping='/todos/*')
global with sharing class TodosSupplier {

    @HttpPost
    global static List<Id> createTodo() {
        RestRequest request = RestContext.request;
        List<ToDo__c> todosToInsert = new List<ToDo__c>();
        List<Object> todosJson = (List<Object>) JSON.deserializeUntyped(request.requestBody.toString());
        for (Object todo : todosJson) {
            Map<String, Object> receivedTodoMap = (Map<String, Object>) todo;
            todosToInsert.add(mapTodo(receivedTodoMap));
        }
        insert todosToInsert;
        List<Id> ids = new List<Id>();
        for (ToDo__c t : todosToInsert) {
            ids.add(t.Id);
        }
        System.debug(todosToInsert);
        return ids;
    }


    private static ToDo__c mapTodo(Map<String, Object> receivedTodoMap) {
        String recordTypeName = (String) receivedTodoMap.get('recordTypeName');
        RecordType recordType = [SELECT Id FROM RecordType WHERE Name = :recordTypeName];
        return new ToDo__c(
                ExternalId__c = (String) receivedTodoMap.get('id'),
                Name = (String) receivedTodoMap.get('name'),
                Status__c = (String) receivedTodoMap.get('status'),
                Start_Date__c = receivedTodoMap.get('startDate') != null ? Date.valueOf(receivedTodoMap.get('startDate') + ' 00:00:00') : null,
                Description__c = (String) receivedTodoMap.get('description'),
                Deadline__c = receivedTodoMap.get('deadline') != null ? Date.valueOf(receivedTodoMap.get('deadline') + ' 00:00:00') : null,
                Category__c = (String) receivedTodoMap.get('category'),
                RecordTypeId = recordType.Id
        );

    }


    @HttpDelete
    global static void deleteTodo() {
        RestRequest request = RestContext.request;
        RestResponse res = new RestResponse();
        List<String> idToDelete = (List<String>) JSON.deserialize(request.requestBody.toString(), List<String>.class);
        List<ToDo__c> deleteTodos = [SELECT Id FROM ToDo__c WHERE ExternalId__c IN :idToDelete];
        try {
            delete deleteTodos;
            res.responseBody = Blob.valueOf('Request success');
            res.statusCode = 200;
        } catch (Exception e) {
            res.responseBody = Blob.valueOf(e.getMessage());
            res.statusCode = 500;
        }
        RestContext.response = res;
        System.debug(res);
    }

    @HttpPut
    global static void updateTodo() {
        RestRequest request = RestContext.request;
        List<ToDo__c> todosFromRequest = new List<ToDo__c>();
        List<Object> todosJson = (List<Object>) JSON.deserializeUntyped(request.requestBody.toString());
        for (Object todo : todosJson) {
            Map<String, Object> receivedTodoMap = (Map<String, Object>) todo;
            todosFromRequest.add(mapTodo(receivedTodoMap));
        }
        List<String> externalIds = new List<String>();
        for (ToDo__c todo : todosFromRequest) {
            externalIds.add(todo.ExternalId__c);
        }
        List<ToDo__c> todosFromDB = [SELECT Id, ExternalId__c FROM ToDo__c WHERE ExternalId__c IN :externalIds];
        for (ToDo__c todoFromRequest : todosFromRequest) {
            for (ToDo__c todoFromDB : todosFromDB) {
                if (todoFromRequest.ExternalId__c == todoFromDB.ExternalId__c) {
                    todoFromRequest.Id = todoFromDB.Id;
                }
            }
        }
        update todosFromRequest;
    }
}