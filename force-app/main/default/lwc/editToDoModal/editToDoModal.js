import {LightningElement, api} from 'lwc';
import NAME_FIELD from '@salesforce/schema/ToDo__c.Name';
import DESCRIPTION_FIELD from '@salesforce/schema/ToDo__c.Description__c';
import STATUS_FIELD from '@salesforce/schema/ToDo__c.Status__c';
import CATEGORY_FIELD from '@salesforce/schema/ToDo__c.Category__c';
import START_DAY_FIELD from '@salesforce/schema/ToDo__c.Start_Date__c';
import DEADLINE_FIELD from '@salesforce/schema/ToDo__c.Deadline__c';


export default class EditToDoModal extends LightningElement {

    @api isOpen;
    @api todo;

    fields = [NAME_FIELD, DESCRIPTION_FIELD, STATUS_FIELD, CATEGORY_FIELD, START_DAY_FIELD, DEADLINE_FIELD];

    handleSave(){
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    handleCancel(){
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    get view (){
        if (this.todo.Id == null){
            return 'edit';
        } else return 'view';
    }

}