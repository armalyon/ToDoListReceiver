public with sharing class ToDoController {

    @AuraEnabled(Cacheable=true)
    public static List<ToDo__c> getToDoList() {
        return [
                SELECT Id, Name, Description__c, Status__c, Category__c, Start_Date__c, Deadline__c
                FROM ToDo__c
        ];
    }

    @AuraEnabled(Cacheable=true)
    public static ToDo__c getToDoById(String recordId) {
        return [
                SELECT
                        Name,
                        Description__c,
                        Category__c,
                        Status__c,
                        Start_Date__c,
                        Deadline__c
                FROM ToDo__c
                WHERE Id = :recordId
        ];
    }

}