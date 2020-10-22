/**
 * Created by Bogdan on 22.10.2020.
 */

@RestResource(UrlMapping='/subtodos/*')
global with sharing class SubTodosSupplier {

    @HttpPost
    global static List<Id> createSubTodo() {
        RestRequest request = RestContext.request;
        List<Sub_ToDo__c> subTodosToInsert = new List<Sub_ToDo__c>();
        List<Id> externalParentTodoIds = new List<Id>();

        List<Object> subTodosJson = (List<Object>) JSON.deserializeUntyped(request.requestBody.toString());
        for (Object todo : subTodosJson) {
            Map<String, Object> receivedTodoMap = (Map<String, Object>) todo;
            subTodosToInsert.add(mapSubTodo(receivedTodoMap, externalParentTodoIds));
        }

        List<ToDo__c> parentTodos = [SELECT Id, ExternalId__c FROM ToDo__c WHERE ExternalId__c IN :externalParentTodoIds];
        for (Sub_ToDo__c subToDo : subTodosToInsert) {
            for (ToDo__c parentTodo : parentTodos) {
                if (subToDo.ToDo__c == parentTodo.ExternalId__c) {
                    subToDo.ToDo__c = parentTodo.Id;
                }
            }
        }

        insert subTodosToInsert;

        List<Id> ids = new List<Id>();
        for (Sub_ToDo__c t : subTodosToInsert) {
            ids.add(t.Id);
        }
        System.debug(subTodosToInsert);
        return ids;
    }

    @HttpDelete
    global static void deleteSubTodo() {
        RestRequest request = RestContext.request;
        RestResponse res = new RestResponse();
        try {
            List<String> idToDelete = (List<String>) JSON.deserialize(request.requestBody.toString(), List<String>.class);
            List<Sub_ToDo__c> subToDos = [SELECT Id FROM Sub_ToDo__c WHERE ExternalId__c IN :idToDelete];
            delete subToDos;
            res.responseBody = Blob.valueOf('Request success');
            res.statusCode = 200;
        } catch (Exception e) {
            res.responseBody = Blob.valueOf(e.getMessage());
            res.statusCode = 500;
        }
        RestContext.response = res;
        System.debug(res);
    }

//    @HttpPut
//    global static void updateSubTodo() {
//        RestRequest request = RestContext.request;
//        List<Sub_ToDo__c> todosFromRequest = new List<Sub_ToDo__c>();
//        List<Object> todosJson = (List<Object>) JSON.deserializeUntyped(request.requestBody.toString());
//        for (Object todo : todosJson) {
//            Map<String, Object> receivedTodoMap = (Map<String, Object>) todo;
//            todosFromRequest.add(mapSubTodo(receivedTodoMap));
//        }
//
//        List<String> externalIds = new List<String>();
//        for (Sub_ToDo__c todo : todosFromRequest) {
//            externalIds.add(todo.ExternalId__c);
//        }
//
//        List<Sub_ToDo__c> todosFromDB = [SELECT Id, ExternalId__c FROM Sub_ToDo__c WHERE ExternalId__c IN :externalIds];
//        for (Sub_ToDo__c todoFromRequest : todosFromRequest) {
//            for (Sub_ToDo__c todoFromDB : todosFromDB) {
//                if (todoFromRequest.ExternalId__c == todoFromDB.ExternalId__c) {
//                    todoFromRequest.Id = todoFromDB.Id;
//                }
//            }
//        }
//        update todosFromRequest;
//    }

    private static Sub_ToDo__c mapSubTodo(Map<String, Object> receivedTodoMap, List<Id> externalParentTodoIds) {
        externalParentTodoIds.add((Id) receivedTodoMap.get('relatedToDo'));
        return new Sub_ToDo__c(
                Name = (String) receivedTodoMap.get('name'),
                Description__c = (String) receivedTodoMap.get('description'),
                ExternalId__c = (String) receivedTodoMap.get('id'),
                IsDone__c = (Boolean) receivedTodoMap.get('isDone'),
                ToDo__c = (Id) receivedTodoMap.get('relatedToDo')
        );
    }
}