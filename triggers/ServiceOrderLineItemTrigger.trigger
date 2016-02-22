trigger ServiceOrderLineItemTrigger on CHANNEL_ORDERS__Service_Order_Detail__c (after insert, before delete) 
{
	/******************
	If a new Service Order Detail Item is created, we want to make a BOSS Detail line item to match.
	First we need to make sure a BOSS order already exists for this Service Order.
	We also want to update and delete a BOSS Detail if its corresponding Service Detail is deleted.
	*******************/
	if(Trigger.isInsert)
	{
		Set<Id> newSoli = new Set<Id>();
		Set<Id> serviceOrder = new Set<Id>();
		List<csboss__BOSS_Order__c> bossOrders = new List<csboss__BOSS_Order__c>(
																								[SELECT Id,csboss__Service_Order__c
																								 FROM csboss__BOSS_Order__c
																								 WHERE csboss__Service_Order__c != NULL]);

		for(csboss__BOSS_Order__c boss :bossOrders)
		{
			serviceOrder.add(boss.csboss__Service_Order__c);
		}
		for(CHANNEL_ORDERS__Service_Order_Detail__c soli : Trigger.new)
		{
			if(serviceOrder.contains(soli.CHANNEL_ORDERS__Partner_Order__c))
			{
				newSoli.add(soli.Id);
			}
			ServiceDetailCreatesBossDetail soliTrigger = new ServiceDetailCreatesBossDetail();
			soliTrigger.CreateBossDetailLineItem(newSoli);
		}
	}

	else if(Trigger.isDelete)
	{
		ServiceDetailCreatesBossDetail soliTrigger = new ServiceDetailCreatesBossDetail();
		soliTrigger.CleanUpServiceDetailItems(Trigger.oldMap.keySet());
	}
}