trigger BOSSOrderDetailTrigger on csboss__BOSS_Order_Detail__c (after insert, after update) 
{

// Design Decision Change --> functionality moving over to SOLI trigger

	//if(Trigger.isInsert || Trigger.isUpdate)
	//{
	//	BOSSDetailAutomatedFieldUpdates runUpdate = new BOSSDetailAutomatedFieldUpdates();
	//	runUpdate.FieldCollection();
	//}
}