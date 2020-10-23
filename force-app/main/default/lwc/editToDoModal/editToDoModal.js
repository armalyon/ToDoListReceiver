import {LightningElement, api} from 'lwc';

export default class EditToDoModal extends LightningElement {

    @api isOpen;
    @api todo;

    handleSave(){
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    handleCancel(){
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

}