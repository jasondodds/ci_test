@isTest(seeAllData=false)
public class Test_ServiceOrderToBossOrderUpdate {

	static testMethod void testForAccountOnOpportunity()
	{
		Account acct = new Account (Name = 'Test Account',
																		BillingStreet = '123 Main',
																		BillingCity = 'Home',
																		BillingState = 'WA',
																		BillingCountry = 'US',
																		BillingPostalCode = '98277');
				insert acct;

				sfLma__License__c lic = new sfLma__License__c(
							sfLma__Install_Date__c = System.Today(),
							sfLma__Seats__c = 4,
							sfLma__Status__c = 'Active',
							sfLma__Subscriber_Org_ID__c = '00D61000000eWOY'
							);
				insert lic;

			  CHANNEL_ORDERS__Partner_Contract_Terms__c cntrct = new CHANNEL_ORDERS__Partner_Contract_Terms__c(
			  	Name = 'Test Contract', 
			  	CHANNEL_ORDERS__Partner_API_Key__c = 'ABCDE123456',
			  	CHANNEL_ORDERS__Allow_to_Sell_to_Existing_Org__c = TRUE,
			  	CHANNEL_ORDERS__COA_Sync_timestamp__c = System.Today().addDays(1)
			  	);
			  insert cntrct;

			  CHANNEL_ORDERS__Partner_Product_Catalog__c catalog = new CHANNEL_ORDERS__Partner_Product_Catalog__c(
			  	CHANNEL_ORDERS__Partner_Contract_Terms__c = cntrct.Id,
			  	CHANNEL_ORDERS__Billing_Frequency__c = 12,
			  	CHANNEL_ORDERS__Cancellation_Terms__c = 12,
			  	CHANNEL_ORDERS__Contract_Auto_Renew__c = 'Yes',
			  	CHANNEL_ORDERS__Contract_Length__c = 12,
			  	CHANNEL_ORDERS__Renewal_Terms__c = 12
			  	);
			  insert catalog;

				Product2 product = new Product2(
					Name = 'Test Product',
					csboss__Related_Partner_Product_Catalog__c = catalog.Id,
					Family = 'Hardware');
				insert product;
				

				Id priceBookId = Test.getStandardPricebookId();

				PriceBookEntry priceBookEntry = new PriceBookEntry(
					Product2Id = product.Id,
					Pricebook2Id =  priceBookId,
					UnitPrice = 10,
					IsActive = TRUE
					);
				insert priceBookEntry;

			  Opportunity oppty = new Opportunity(
			  	Name = 'Test Oppty', 
			  	CloseDate = System.Today(), 
			  	StageName='Prospecting',
			  	csboss__Channel_Order_Type__c = 'Initial', 
			  	csboss__License__c = lic.Id, 
			  	AccountId = Acct.Id,
			  	csboss__Partner_Contract_Terms__c = cntrct.Id,
			  	csboss__Service_Start_Date__c = System.Today().addDays(1),
			  	csboss__Date_Partner_Received_Customer_Order__c = System.Today().addDays(1),
			  	csboss__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c = System.Today().addDays(1),
			  	Pricebook2Id = priceBookEntry.Pricebook2Id
					);
			  insert oppty;
			  
			  CHANNEL_ORDERS__Service_Order__c service = new CHANNEL_ORDERS__Service_Order__c(
			  	CHANNEL_ORDERS__Related_Opportunity__c = oppty.Id,
			  	CHANNEL_ORDERS__Service_Start_Date__c	 = oppty.csboss__Service_Start_Date__c,
			  	CHANNEL_ORDERS__Partner_Contract_Rules__c = String.valueOf(oppty.csboss__Partner_Contract_Terms__c).subString(0,15),
			  	CHANNEL_ORDERS__Date_Partner_Received_Customer_Order__c = oppty.csboss__Date_Partner_Received_Customer_Order__c,
			  	CHANNEL_ORDERS__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c = oppty.csboss__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c,
			  	CHANNEL_ORDERS__Order_Type__c = oppty.csboss__Channel_Order_Type__c,
			  	CHANNEL_ORDERS__Customer_Org_ID__c = lic.sfLma__Subscriber_Org_ID__c,
			  	CHANNEL_ORDERS__Service_Order_Status__c = 'Draft'
			  	);
			  insert service;

			  csboss__BOSS_Order__c boss = new csboss__BOSS_Order__c(
			   	csboss__Opportunity__c = oppty.Id,
			   	csboss__Service_Order__c = service.Id,
			   	csboss__Service_Order_Status__c = 'Draft',
			   	csboss__License__c = lic.Id
			   	);
	  		insert boss;

	  		test.startTest();
	  		service.CHANNEL_ORDERS__Service_Order_Status__c = 'Submitted';
	  		update service;
	  		test.stopTest();

	  		List<csboss__BOSS_Order__c> result = [SELECT Id FROM csboss__BOSS_Order__c WHERE csboss__Service_Order_Status__c = 'Submitted'];

	  		System.assertEquals(1, result.size());
	}
}