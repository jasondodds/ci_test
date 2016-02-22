@isTest (seeAllData=false)
public with sharing class Test_CreateOrdersFromOpportunity {

	static testMethod void opportunityWithServiceOrder()
	{
		Account acct = new Account (Name = 'Test Account');
		insert acct;
		//LMA License
		sfLma__License__c lic = new sfLma__License__c(
					sfLma__Install_Date__c = System.Today(),
					sfLma__Seats__c = 4,
					sfLma__Status__c = 'Active',
					sfLma__Subscriber_Org_ID__c = '00D61000000eWOY'
					);

		insert lic;
		//Opportunity with License
	  Opportunity oppty = new Opportunity(Name = 'Test Oppty', CloseDate = System.Today(), StageName='Prospecting',
	  	csboss__Channel_Order_Type__c = 'Initial', csboss__License__c = lic.Id, AccountId = Acct.Id);
	  insert oppty;
	  //Boss Order with Opportunity && License
	  csboss__BOSS_Order__c boss = new csboss__BOSS_Order__c(csboss__Opportunity__c = oppty.Id);
	  insert boss;
	  //Contract -> required
	  CHANNEL_ORDERS__Partner_Contract_Terms__c cntrct = new CHANNEL_ORDERS__Partner_Contract_Terms__c(
	  	Name = 'Test Contract', 
	  	CHANNEL_ORDERS__Partner_API_Key__c = 'ABCDE123456',
	  	CHANNEL_ORDERS__Allow_to_Sell_to_Existing_Org__c = TRUE,
	  	CHANNEL_ORDERS__COA_Sync_timestamp__c = System.Today()
	  	);
	  insert cntrct;
	  //now....create Service Order
	  CHANNEL_ORDERS__Service_Order__c serviceOrder = new CHANNEL_ORDERS__Service_Order__c(
	  	CHANNEL_ORDERS__Order_Type__c = 'Initial',
	  	CHANNEL_ORDERS__Service_Start_Date__c = oppty.CloseDate,
	  	CHANNEL_ORDERS__Partner_Contract_Rules__c = cntrct.Id,
	  	CHANNEL_ORDERS__Customer_Org_ID__c = '00D61000000eWOY',
	  	CHANNEL_ORDERS__Service_Order_Status__c	= 'Draft',
	  	CHANNEL_ORDERS__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c = System.today(),
	  	CHANNEL_ORDERS__Date_Partner_Received_Customer_Order__c = oppty.CloseDate,
	  	CHANNEL_ORDERS__Related_Opportunity__c = oppty.Id
	  	);
	  insert serviceOrder;
	  test.startTest();
	  //confirm that the oppty has a Service Order...then deliver the appropriate message
       Test.setCurrentPage(Page.CreateOrdersFromOpportunity);
       ApexPages.StandardController ctrl = new ApexPages.StandardController(oppty);
       CreateOrdersFromOpportunity controller = new CreateOrdersFromOpportunity(ctrl);	
       controller.OperationalCheck();

		ApexPages.Message[] msgs=ApexPages.getMessages();
       	boolean messagePosted = false;
       	for(ApexPages.Message msg : msgs)
       	{ 
       		if(msg.getDetail().contains('A Service Order already exists for this Opportunity.')) 
       		{
       			messagePosted = true;
       		}
       	}
      test.stopTest();

       	for(ApexPages.Message msg : ApexPages.getMessages())
       	{
       		System.assertEquals('A Service Order already exists for this Opportunity.', msg.getSummary());
       	}
	}


	static testMethod void opportunityWithoutAccount()		
	{
		//LMA License
		sfLma__License__c lic = new sfLma__License__c(
					sfLma__Install_Date__c = System.Today(),
					sfLma__Seats__c = 4,
					sfLma__Status__c = 'Active',
					sfLma__Subscriber_Org_ID__c = '00D61000000eWOY'
					);

		insert lic;
		//Opportunity with License
	  Opportunity oppty = new Opportunity(
	  	Name = 'Test Oppty', 
	  	CloseDate = System.Today(), 
	  	StageName='Prospecting',
	  	csboss__Channel_Order_Type__c = 'Initial', 
	  	csboss__License__c = lic.Id);
	  insert oppty;
	  //Boss Order with Opportunity && License
	  csboss__BOSS_Order__c boss = new csboss__BOSS_Order__c(csboss__Opportunity__c = oppty.Id);
	  insert boss;
	  //Contract -> required
	  CHANNEL_ORDERS__Partner_Contract_Terms__c cntrct = new CHANNEL_ORDERS__Partner_Contract_Terms__c(
	  	Name = 'Test Contract', 
	  	CHANNEL_ORDERS__Partner_API_Key__c = 'ABCDE123456',
	  	CHANNEL_ORDERS__Allow_to_Sell_to_Existing_Org__c = TRUE,
	  	CHANNEL_ORDERS__COA_Sync_timestamp__c = System.Today()
	  	);
	  insert cntrct;

	  test.startTest();
	  //confirm that the oppty has a Service Order...then deliver the appropriate message
       Test.setCurrentPage(Page.CreateOrdersFromOpportunity);
       ApexPages.StandardController ctrl = new ApexPages.StandardController(oppty);
       CreateOrdersFromOpportunity controller = new CreateOrdersFromOpportunity(ctrl);	
       controller.OperationalCheck();

		ApexPages.Message[] msgs=ApexPages.getMessages();
       	boolean messagePosted = false;
       	for(ApexPages.Message msg : msgs)
       	{ 
       		if(msg.getDetail().contains('You need to have an Account, License, and Partner Contract Terms setup within this Opportunity before proceeding.')) 
       		{
       			messagePosted = true;
       		}
       	}
      test.stopTest();

       	for(ApexPages.Message msg : ApexPages.getMessages())
       	{
       		System.assertEquals('You need to have an Account, License, and Partner Contract Terms setup within this Opportunity before proceeding.', msg.getSummary());
       	}
	}

	static testMethod void CreateServiceLineItems()
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

	  Campaign camp = new Campaign(
	  	Name = 'Test Campaign',
	  	IsActive = TRUE
	  	);
	  insert camp;

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
	  	Pricebook2Id = priceBookEntry.Pricebook2Id,
	  	CampaignId = camp.Id
			);
	  insert oppty;

	  OpportunityLineItem opptyLineItem = new OpportunityLineItem(
	  	OpportunityId = oppty.Id,
	  	PricebookEntryId = priceBookEntry.Id,
	  	UnitPrice = 10,
	  	Quantity = 10,
	  	Description = 'This is a test to confirm Service Order Details are being generated for this Opportunity Line Item.'
	  	);
	  insert opptyLineItem;
	  
	  test.startTest();
	  Test.setCurrentPage(Page.CreateOrdersFromOpportunity);
	  ApexPages.StandardController ctrl = new ApexPages.StandardController(oppty);
	  CreateOrdersFromOpportunity controller = new CreateOrdersFromOpportunity(ctrl);	
    controller.populateClassProperties(oppty);
    controller.CreateOrdersAndRecord();
	  test.stopTest();

	  List<CHANNEL_ORDERS__Service_Order_Detail__c> serviceDetail = [SELECT Id 
	  																															 FROM CHANNEL_ORDERS__Service_Order_Detail__c
	  																															 WHERE CHANNEL_ORDERS__Product_Line_Description__c = 'This is a test to confirm Service Order Details are being generated for this Opportunity Line Item.'];
	  System.assertEquals(1,serviceDetail.size());

	  List<csboss__BOSS_Order__c> bossCampaign = new List<csboss__BOSS_Order__c>([SELECT Id FROM csboss__BOSS_Order__c WHERE csboss__Campaign__c =: oppty.CampaignId]);
	  System.assertEquals(1,bossCampaign.size());
	}		


	static testMethod void CreateServiceOrder()
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
	  	csboss__License__c = lic.Id, AccountId = Acct.Id,
	  	csboss__Partner_Contract_Terms__c = cntrct.Id,
	  	csboss__Service_Start_Date__c = System.Today().addDays(1),
	  	csboss__Date_Partner_Received_Customer_Order__c = System.Today().addDays(1),
	  	csboss__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c = System.Today().addDays(1),
	  	Pricebook2Id = priceBookEntry.Pricebook2Id	
			);
	  insert oppty;

	  OpportunityLineItem opptyLineItem = new OpportunityLineItem(
	  	OpportunityId = oppty.Id,
	  	PricebookEntryId = priceBookEntry.Id,
	  	UnitPrice = 10,
	  	Quantity = 10,
	  	Description = 'This is a test --> pay attention. '
	  	);
	  insert opptyLineItem;

	  test.startTest();
	  Test.setCurrentPage(Page.CreateOrdersFromOpportunity);
	  ApexPages.StandardController ctrl = new ApexPages.StandardController(oppty);
	  CreateOrdersFromOpportunity controller = new CreateOrdersFromOpportunity(ctrl);	
    controller.populateClassProperties(oppty);
   	controller.CreateOrdersAndRecord();
	  test.stopTest();

	  List<CHANNEL_ORDERS__Service_Order__c> serviceOrder = [SELECT Id FROM CHANNEL_ORDERS__Service_Order__c
	  																												WHERE CHANNEL_ORDERS__Related_Opportunity__c = :oppty.Id];
	  System.assertEquals(1,serviceOrder.size());
	}

	static testMethod void TestForOpptyContractMatchingLineItemContract()
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
	  CHANNEL_ORDERS__Partner_Contract_Terms__c cntrct2 = new CHANNEL_ORDERS__Partner_Contract_Terms__c(
	  	Name = 'Test Contract2', 
	  	CHANNEL_ORDERS__Partner_API_Key__c = 'ABCDE12345678',
	  	CHANNEL_ORDERS__Allow_to_Sell_to_Existing_Org__c = TRUE,
	  	CHANNEL_ORDERS__COA_Sync_timestamp__c = System.Today().addDays(1)
	  	);
	  insert cntrct2;

	  CHANNEL_ORDERS__Partner_Product_Catalog__c catalog = new CHANNEL_ORDERS__Partner_Product_Catalog__c(
	  	CHANNEL_ORDERS__Partner_Contract_Terms__c = cntrct2.Id,
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
	  	csboss__License__c = lic.Id, AccountId = Acct.Id,
	  	csboss__Partner_Contract_Terms__c = cntrct.Id,
	  	csboss__Service_Start_Date__c = System.Today().addDays(1),
	  	csboss__Date_Partner_Received_Customer_Order__c = System.Today().addDays(1),
	  	csboss__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c = System.Today().addDays(1),
	  	Pricebook2Id = priceBookEntry.Pricebook2Id	
			);
	  insert oppty;

	  OpportunityLineItem opptyLineItem = new OpportunityLineItem(
	  	OpportunityId = oppty.Id,
	  	PricebookEntryId = priceBookEntry.Id,
	  	UnitPrice = 10,
	  	Quantity = 10,
	  	Description = 'This is a test --> pay attention. '
	  	);
	  insert opptyLineItem;
		

		test.startTest();
	   Test.setCurrentPage(Page.CreateOrdersFromOpportunity);
	   ApexPages.StandardController ctrl = new ApexPages.StandardController(oppty);
	   CreateOrdersFromOpportunity controller = new CreateOrdersFromOpportunity(ctrl);	
	   controller.OperationalCheck();

   	ApexPages.Message[] msgs=ApexPages.getMessages();
   	boolean messagePosted = false;
   	for(ApexPages.Message msg : msgs)
   	{ 
   		if(msg.getDetail().contains('Partner Contract Terms assigned to your Opportunity Line Item(s) must match the Partner Contract Terms assigned to your Opportunity.')) 
   		{
   			messagePosted = true;
   		}
   	}
  	test.stopTest();
   	for(ApexPages.Message msg : ApexPages.getMessages())
   	{
   		System.assertEquals('Partner Contract Terms assigned to your Opportunity Line Item(s) must match the Partner Contract Terms assigned to your Opportunity.', msg.getSummary());
   	}

	}
}