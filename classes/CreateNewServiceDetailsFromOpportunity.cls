public with sharing class CreateNewServiceDetailsFromOpportunity {
//Already reviewed.
	
	private List<CHANNEL_ORDERS__Service_Order__c> service;


	public  CreateNewServiceDetailsFromOpportunity () 
	{  
		
	}

	public void CreateNewServiceDetail(Set<Id> oppLine)
	{
		List<OpportunityLineItem> opptyItem = new List<OpportunityLineItem>([SELECT Id, 
									Product2.csboss__Related_Partner_Product_Catalog__r.CHANNEL_ORDERS__Partner_Contract_Terms__r.CHANNEL_ORDERS__Default_Billing_Frequency__c,
									Product2.csboss__Related_Partner_Product_Catalog__r.CHANNEL_ORDERS__Partner_Contract_Terms__r.CHANNEL_ORDERS__Default_Cancellation_Terms__c,
									Product2.csboss__Related_Partner_Product_Catalog__r.CHANNEL_ORDERS__Partner_Contract_Terms__r.CHANNEL_ORDERS__Default_Contract_Auto_Renew__c,
									Product2.csboss__Related_Partner_Product_Catalog__r.CHANNEL_ORDERS__Partner_Contract_Terms__r.CHANNEL_ORDERS__Default_Contract_Length__c,
									Product2.csboss__Related_Partner_Product_Catalog__r.CHANNEL_ORDERS__Partner_Contract_Terms__r.CHANNEL_ORDERS__Default_Renewal_Length__c,
									UnitPrice, Description,Quantity,Product2.csboss__Related_Partner_Product_Catalog__r.Id,
									Opportunity.csboss__Partner_Contract_Terms__c,OpportunityId
									 FROM OpportunityLineItem
									 WHERE Id IN :oppLine]);

		Map<Id,Id> opptyToServiceMap = new Map<Id,Id>();
		for(OpportunityLineItem oli : opptyItem )
		{
			opptyToServiceMap.put(oli.OpportunityId,NULL);
		}
	 service = [SELECT Id, CHANNEL_ORDERS__Related_Opportunity__c, CHANNEL_ORDERS__Service_Start_Date__c,
					CHANNEL_ORDERS__Partner_Contract_Rules__c,CHANNEL_ORDERS__Date_Partner_Received_Customer_Order__c,
					CHANNEL_ORDERS__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c,CHANNEL_ORDERS__Order_Type__c
					FROM CHANNEL_ORDERS__Service_Order__c
					WHERE CHANNEL_ORDERS__Related_Opportunity__c IN :opptyToServiceMap.keySet()];
		for(CHANNEL_ORDERS__Service_Order__c s : service)
		{
			// CURRENTLY, the Opportunity to Service is a 1:1 relationship. If that changes, this breaks.
			opptyToServiceMap.put(s.CHANNEL_ORDERS__Related_Opportunity__c, s.Id);
		}
		
		List<CHANNEL_ORDERS__Service_Order_Detail__c> newServiceLineItem = new List<CHANNEL_ORDERS__Service_Order_Detail__c>();
		for(OpportunityLineItem oppItem : opptyItem)
		{
				CHANNEL_ORDERS__Service_Order_Detail__c detailItem = new CHANNEL_ORDERS__Service_Order_Detail__c();

				detailItem.CHANNEL_ORDERS__pc_Partner_Contract_Term__c    =	oppItem.Opportunity.csboss__Partner_Contract_Terms__c;
				detailItem.CHANNEL_ORDERS__Product_Name__c 								= oppItem.Product2.csboss__Related_Partner_Product_Catalog__r.Id;
				detailItem.CHANNEL_ORDERS__Partner_Order__c 							= opptyToServiceMap.get(oppItem.OpportunityId); 
				detailItem.CHANNEL_ORDERS__pc_Billing_Frequency__c 				= oppItem.Product2.csboss__Related_Partner_Product_Catalog__r.CHANNEL_ORDERS__Partner_Contract_Terms__r.CHANNEL_ORDERS__Default_Billing_Frequency__c;
				detailItem.CHANNEL_ORDERS__pc_Cancellation_Terms__c 			= oppItem.Product2.csboss__Related_Partner_Product_Catalog__r.CHANNEL_ORDERS__Partner_Contract_Terms__r.CHANNEL_ORDERS__Default_Cancellation_Terms__c;
				detailItem.CHANNEL_ORDERS__pc_Contract_Auto_Renew__c 			= oppItem.Product2.csboss__Related_Partner_Product_Catalog__r.CHANNEL_ORDERS__Partner_Contract_Terms__r.CHANNEL_ORDERS__Default_Contract_Auto_Renew__c;
				detailItem.CHANNEL_ORDERS__pc_Contract_Length__c 					= oppItem.Product2.csboss__Related_Partner_Product_Catalog__r.CHANNEL_ORDERS__Partner_Contract_Terms__r.CHANNEL_ORDERS__Default_Contract_Length__c;
				detailItem.CHANNEL_ORDERS__pc_Renewal_Terms__c 						= oppItem.Product2.csboss__Related_Partner_Product_Catalog__r.CHANNEL_ORDERS__Partner_Contract_Terms__r.CHANNEL_ORDERS__Default_Renewal_Length__c;
				detailItem.CHANNEL_ORDERS__Customer_Price_Per_Month__c 		= oppItem.UnitPrice;
				detailItem.CHANNEL_ORDERS__Product_Line_Description__c 		= oppItem.Description;
				detailItem.CHANNEL_ORDERS__Quantity__c										= oppItem.Quantity;
				detailItem.csboss__Related_Opportunity_Line_Item__c				= oppItem.Id;		
				newServiceLineItem.add(detailItem);
		}
	for(CHANNEL_ORDERS__Service_Order__c s : service)
		{
			s.CHANNEL_ORDERS__Service_Start_Date__c = System.Today();
		}
		update service;
		insert newServiceLineItem;
	}
	public void CleanUpServiceLineUp(Set<Id> oppLine)
	{//check to make sure there is a SOLI for this Oppty then step in to cleanup
		List<CHANNEL_ORDERS__Service_Order_Detail__c> soli = new List<CHANNEL_ORDERS__Service_Order_Detail__c>(
																											[SELECT Id FROM CHANNEL_ORDERS__Service_Order_Detail__c
																											 WHERE csboss__Related_Opportunity_Line_Item__c IN :oppLine]);
		if(soli.size() >0)
		{
			Set<String> existingStringID = new Set<String>();
			for(Id id: oppLine)
			{
				existingStringID.add(String.valueOf(id));
			}
			delete [SELECT Id FROM CHANNEL_ORDERS__Service_Order_Detail__c WHERE csboss__Related_Opportunity_Line_Item__c IN :existingStringID];
			
			for(CHANNEL_ORDERS__Service_Order__c s : service)
			{
				s.CHANNEL_ORDERS__Service_Start_Date__c = System.Today();
			}
			update service;
		}
	}
}