trigger OpptyLineItemTrigger on OpportunityLineItem (after insert, after delete) 
{
	if(Trigger.isInsert)
	{
		Global_Settings__c settings = new Global_Settings__c();
			settings = Global_Settings__c.getOrgDefaults();
		if(settings.csboss__Enabled_Opportunity_Line_Item_Trigger__c)
			{
				Set<Id> opptyId = new Set<Id>();
				for(OpportunityLineItem oli : Trigger.new)
				{
					opptyId.add(oli.OpportunityId);
				}
				List<CHANNEL_ORDERS__Service_Order__c> serviceOrder = new List<CHANNEL_ORDERS__Service_Order__c>([
																												SELECT Id, CHANNEL_ORDERS__Related_Opportunity__c
																												FROM CHANNEL_ORDERS__Service_Order__c 
																												WHERE CHANNEL_ORDERS__Related_Opportunity__c IN :opptyId]);		
				Set<Id> opptyWithService = new Set<Id>();
				for(CHANNEL_ORDERS__Service_Order__c service : serviceOrder)
				{
					opptyWithService.add(service.CHANNEL_ORDERS__Related_Opportunity__c);
				}

				Set<Id> oliMap = new Set<Id>();

				for(OpportunityLineItem oppLineItem :Trigger.new)
					{
							if(opptyWithService.contains(oppLineItem.OpportunityId))
							{
								oliMap.add(oppLineItem.Id);
							}
						}
				CreateNewServiceDetailsFromOpportunity opptyTrigger = new CreateNewServiceDetailsFromOpportunity();	
				opptyTrigger.CreateNewServiceDetail(oliMap);
			}
		}
	else if (Trigger.isDelete)
	{
		CreateNewServiceDetailsFromOpportunity opptyTrigger = new CreateNewServiceDetailsFromOpportunity();	
		opptyTrigger.CleanUpServiceLineUp(Trigger.oldMap.keySet());
	}
}