trigger ServiceOrderTrigger on CHANNEL_ORDERS__Service_Order__c (after update) {

	if(Trigger.isUpdate)
	{
		/*
		Update Boss Order with Service Order change.  Only updating records that have an established relationship.
		If a relationship does not exist, then the User will need to run RetroUpdate; which will establish the field
		connections and any changes will be addressed by this trigger.
		*/
		Set<Id> serviceOrder = new Set<Id>();
		List<csboss__BOSS_Order__c> bossOrders = new List<csboss__BOSS_Order__c>(
																						[SELECT Id,csboss__Service_Order__r.Id
																						 FROM csboss__BOSS_Order__c
																						 WHERE csboss__Service_Order__c != NULL]);
		for(CHANNEL_ORDERS__Service_Order__c s :Trigger.old)
		{
			for(csboss__BOSS_Order__c b :bossOrders)			
				if(s.Id == b.csboss__Service_Order__r.Id)
				{
					serviceOrder.add(s.Id);
				}
		}
		ServiceOrderToBossOrderUpdate so = new ServiceOrderToBossOrderUpdate();
		so.ServiceOrderPrep(serviceOrder);
	}

}