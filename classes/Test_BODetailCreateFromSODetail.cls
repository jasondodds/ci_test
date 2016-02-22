@isTest (seeAllData=false)
public with sharing class Test_BODetailCreateFromSODetail {

	static testMethod void TestBossDetailCreation()
	{
		Global_Settings__c settings = new Global_Settings__c();
		settings = Global_Settings__c.getOrgDefaults();
		settings.csboss__Enabled_Opportunity_Line_Item_Trigger__c = TRUE;
		upsert settings;

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
			  	CHANNEL_ORDERS__COA_Sync_timestamp__c = System.Today().addDays(1),
			  	CHANNEL_ORDERS__Default_Contract_Length__c = 12
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

			  OpportunityLineItem opptyLineItem1 = new OpportunityLineItem(
			  	OpportunityId = oppty.Id,
			  	PricebookEntryId = priceBookEntry.Id,
			  	UnitPrice = 10,
			  	Quantity = 10,
			  	Description = 'This line item is currently setup with the Service Detail Line Item.'
			  	);
			 insert opptyLineItem1; 
			  
			  CHANNEL_ORDERS__Service_Order__c service = new CHANNEL_ORDERS__Service_Order__c(
			  	CHANNEL_ORDERS__Related_Opportunity__c = oppty.Id,
			  	CHANNEL_ORDERS__Service_Start_Date__c	 = oppty.csboss__Service_Start_Date__c,
			  	CHANNEL_ORDERS__Partner_Contract_Rules__c = String.valueOf(oppty.csboss__Partner_Contract_Terms__c).subString(0,15),
			  	CHANNEL_ORDERS__Date_Partner_Received_Customer_Order__c = oppty.csboss__Date_Partner_Received_Customer_Order__c,
			  	CHANNEL_ORDERS__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c = oppty.csboss__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c,
			  	CHANNEL_ORDERS__Order_Type__c = oppty.csboss__Channel_Order_Type__c,
			  	CHANNEL_ORDERS__Customer_Org_ID__c = lic.sfLma__Subscriber_Org_ID__c
			  	);		  
			  insert service;

			   csboss__BOSS_Order__c boss = new csboss__BOSS_Order__c(
			   	csboss__Opportunity__c = oppty.Id,
			   	csboss__Service_Order__c = service.Id
			   	);
	  		insert boss;

			  test.startTest();
			  //OLI created, triggers, new SOLI.  New SOLI triggers BOLI.  Success = New BOLI
 				CHANNEL_ORDERS__Service_Order_Detail__c soli = new CHANNEL_ORDERS__Service_Order_Detail__c(
 					CHANNEL_ORDERS__Partner_Order__c = service.Id,
 					CHANNEL_ORDERS__Product_Name__c  = catalog.Id,
 					CHANNEL_ORDERS__Quantity__c = opptyLineItem1.Quantity,
 					CHANNEL_ORDERS__Customer_Price_Per_Month__c = opptyLineItem1.UnitPrice,
 					csboss__Related_Opportunity_Line_Item__c = opptyLineItem1.Id,
 					 CHANNEL_ORDERS__pc_Contract_Length__c = 12
 					);

 				insert soli;
			  test.stopTest();
			  
			  List<csboss__BOSS_Order_Detail__c> boli = [SELECT Id FROM csboss__BOSS_Order_Detail__c WHERE csboss__BOSS_Order__c = :boss.Id];

			  System.assertEquals(1,boli.size());	
	}

	static testMethod void TestBOLICleanUp()
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
			  	CHANNEL_ORDERS__COA_Sync_timestamp__c = System.Today().addDays(1),
			  	CHANNEL_ORDERS__Default_Contract_Length__c = 12
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

			  OpportunityLineItem opptyLineItem1 = new OpportunityLineItem(
			  	OpportunityId = oppty.Id,
			  	PricebookEntryId = priceBookEntry.Id,
			  	UnitPrice = 10,
			  	Quantity = 10,
			  	Description = 'This line item is currently setup with the Service Detail Line Item.'
			  	);
			 insert opptyLineItem1; 
			  
			  CHANNEL_ORDERS__Service_Order__c service = new CHANNEL_ORDERS__Service_Order__c(
			  	CHANNEL_ORDERS__Related_Opportunity__c = oppty.Id,
			  	CHANNEL_ORDERS__Service_Start_Date__c	 = oppty.csboss__Service_Start_Date__c,
			  	CHANNEL_ORDERS__Partner_Contract_Rules__c = String.valueOf(oppty.csboss__Partner_Contract_Terms__c).subString(0,15),
			  	CHANNEL_ORDERS__Date_Partner_Received_Customer_Order__c = oppty.csboss__Date_Partner_Received_Customer_Order__c,
			  	CHANNEL_ORDERS__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c = oppty.csboss__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c,
			  	CHANNEL_ORDERS__Order_Type__c = oppty.csboss__Channel_Order_Type__c,
			  	CHANNEL_ORDERS__Customer_Org_ID__c = lic.sfLma__Subscriber_Org_ID__c
			  	);
			  insert service;

			   csboss__BOSS_Order__c boss = new csboss__BOSS_Order__c(
			   	csboss__Opportunity__c = oppty.Id,
			   	csboss__Service_Order__c = service.Id
			   	);
	  		insert boss;

 				CHANNEL_ORDERS__Service_Order_Detail__c soli = new CHANNEL_ORDERS__Service_Order_Detail__c(
 					CHANNEL_ORDERS__Partner_Order__c = service.Id,
 					CHANNEL_ORDERS__Product_Name__c  = catalog.Id,
 					CHANNEL_ORDERS__Quantity__c = opptyLineItem1.Quantity,
 					CHANNEL_ORDERS__Customer_Price_Per_Month__c = opptyLineItem1.UnitPrice,
 					csboss__Related_Opportunity_Line_Item__c = opptyLineItem1.Id,
 					CHANNEL_ORDERS__pc_Contract_Length__c = 12
 					);
 				insert soli;

			  test.startTest();
			  	delete soli;
			  test.stopTest();

			  List<csboss__BOSS_Order_Detail__c> deletedBoli = [SELECT Id,csboss__BOSS_Order__c FROM csboss__BOSS_Order_Detail__c WHERE csboss__BOSS_Order__c = :boss.Id];

			  System.assertEquals(0,deletedBoli.size());	
	}

	static testMethod void TestBossDetailFieldsUpdateStatusAddOn()
	{
		Global_Settings__c settings = new Global_Settings__c();
			settings = Global_Settings__c.getOrgDefaults();
			settings.csboss__Enabled_Opportunity_Line_Item_Trigger__c = TRUE;
		upsert settings;

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
							sfLma__Subscriber_Org_ID__c = '00D61000000eWOY',
							csboss__Has_Initial_Order__c = TRUE
							);
		insert lic;

		CHANNEL_ORDERS__Partner_Contract_Terms__c cntrct = new CHANNEL_ORDERS__Partner_Contract_Terms__c(
			  	Name = 'Test Contract', 
			  	CHANNEL_ORDERS__Partner_API_Key__c = 'ABCDE123456',
			  	CHANNEL_ORDERS__Allow_to_Sell_to_Existing_Org__c = TRUE,
			  	CHANNEL_ORDERS__COA_Sync_timestamp__c = System.Today().addDays(1),
			  	CHANNEL_ORDERS__Default_Contract_Length__c = 12
			  	);
			  insert cntrct;

			  CHANNEL_ORDERS__Partner_Product_Catalog__c catalog = new CHANNEL_ORDERS__Partner_Product_Catalog__c(
			  	CHANNEL_ORDERS__Partner_Contract_Terms__c = cntrct.Id,
			  	CHANNEL_ORDERS__Billing_Frequency__c = 12,
			  	CHANNEL_ORDERS__Cancellation_Terms__c = 12,
			  	CHANNEL_ORDERS__Contract_Auto_Renew__c = 'Yes',
			  	CHANNEL_ORDERS__Contract_Length__c = 24,
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
			  	csboss__Channel_Order_Type__c = 'Add-on', 
			  	csboss__License__c = lic.Id, 
			  	AccountId = Acct.Id,
			  	csboss__Partner_Contract_Terms__c = cntrct.Id,
			  	csboss__Service_Start_Date__c = System.Today().addDays(1),
			  	csboss__Date_Partner_Received_Customer_Order__c = System.Today().addDays(1),
			  	csboss__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c = System.Today().addDays(1),
			  	Pricebook2Id = priceBookEntry.Pricebook2Id
					);
			  insert oppty;

			  OpportunityLineItem opptyLineItem1 = new OpportunityLineItem(
			  	OpportunityId = oppty.Id,
			  	PricebookEntryId = priceBookEntry.Id,
			  	UnitPrice = 10,
			  	Quantity = 10,
			  	Description = 'This line item is currently setup with the Service Detail Line Item.'
			  	);
			 insert opptyLineItem1; 
			  
			  CHANNEL_ORDERS__Service_Order__c service = new CHANNEL_ORDERS__Service_Order__c(
			  	CHANNEL_ORDERS__Related_Opportunity__c = oppty.Id,
			  	CHANNEL_ORDERS__Service_Start_Date__c	 = oppty.csboss__Service_Start_Date__c,
			  	CHANNEL_ORDERS__Partner_Contract_Rules__c = String.valueOf(oppty.csboss__Partner_Contract_Terms__c).subString(0,15),
			  	CHANNEL_ORDERS__Date_Partner_Received_Customer_Order__c = oppty.csboss__Date_Partner_Received_Customer_Order__c,
			  	CHANNEL_ORDERS__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c = oppty.csboss__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c,
			  	CHANNEL_ORDERS__Order_Type__c = oppty.csboss__Channel_Order_Type__c,
			  	CHANNEL_ORDERS__Customer_Org_ID__c = lic.sfLma__Subscriber_Org_ID__c
			  	);		  
			  insert service;

			  csboss__BOSS_Order__c boss = new csboss__BOSS_Order__c(
			   	csboss__Opportunity__c = oppty.Id,
			   	csboss__Service_Order__c = service.Id
			   	);
	  		insert boss;

			  test.startTest();
			   CHANNEL_ORDERS__Service_Order_Detail__c soli = new CHANNEL_ORDERS__Service_Order_Detail__c(
 					CHANNEL_ORDERS__Partner_Order__c = service.Id,
 					CHANNEL_ORDERS__Product_Name__c  = catalog.Id,
 					CHANNEL_ORDERS__Quantity__c = 10,
 					CHANNEL_ORDERS__Customer_Price_Per_Month__c = 50,
 					CHANNEL_ORDERS__pc_Contract_Length__c = 24,
 					CHANNEL_ORDERS__pc_Partner_Contract_Term__c = cntrct.Id
 					);

 				insert soli;

			  test.stopTest();
			  
			  List<csboss__BOSS_Order_Detail__c> boli1 = [SELECT Id FROM csboss__BOSS_Order_Detail__c WHERE csboss__BOSS_Order__c = :boss.Id];
			  List<csboss__BOSS_Order_Detail__c> boli2 = [SELECT Id FROM csboss__BOSS_Order_Detail__c WHERE csboss__Service_Order_Detail__c = :soli.Id];
			  List<csboss__BOSS_Order_Detail__c> boli3 = [SELECT Id FROM csboss__BOSS_Order_Detail__c WHERE csboss__Net_ARR__c = 6000];
				List<csboss__BOSS_Order_Detail__c> boli4 = [SELECT Id FROM csboss__BOSS_Order_Detail__c WHERE csboss__Net_MRR__c = 500];
				List<csboss__BOSS_Order_Detail__c> boli5 = [SELECT Id FROM csboss__BOSS_Order_Detail__c WHERE csboss__Net_Seats__c = 10];

			  System.assertEquals(1,boli1.size());	
			  System.assertEquals(1,boli2.size());
			  System.assertEquals(1,boli3.size());
			  System.assertEquals(1,boli4.size());
			  System.assertEquals(1,boli5.size());
	}

	static testMethod void TestBossDetailFieldsUpdateStatusCancelationOrder()
	{
		Global_Settings__c settings = new Global_Settings__c();
			settings = Global_Settings__c.getOrgDefaults();
			settings.csboss__Enabled_Opportunity_Line_Item_Trigger__c = TRUE;
		upsert settings;

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
							sfLma__Subscriber_Org_ID__c = '00D61000000eWOY',
							csboss__Has_Initial_Order__c = TRUE
							);
		insert lic;

		CHANNEL_ORDERS__Partner_Contract_Terms__c cntrct = new CHANNEL_ORDERS__Partner_Contract_Terms__c(
			  	Name = 'Test Contract', 
			  	CHANNEL_ORDERS__Partner_API_Key__c = 'ABCDE123456',
			  	CHANNEL_ORDERS__Allow_to_Sell_to_Existing_Org__c = TRUE,
			  	CHANNEL_ORDERS__COA_Sync_timestamp__c = System.Today().addDays(1),
			  	CHANNEL_ORDERS__Default_Contract_Length__c = 12
			  	);
			  insert cntrct;

			  CHANNEL_ORDERS__Partner_Product_Catalog__c catalog = new CHANNEL_ORDERS__Partner_Product_Catalog__c(
			  	CHANNEL_ORDERS__Partner_Contract_Terms__c = cntrct.Id,
			  	CHANNEL_ORDERS__Billing_Frequency__c = 12,
			  	CHANNEL_ORDERS__Cancellation_Terms__c = 12,
			  	CHANNEL_ORDERS__Contract_Auto_Renew__c = 'Yes',
			  	CHANNEL_ORDERS__Contract_Length__c = 24,
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
			  	csboss__Channel_Order_Type__c = 'Cancelation Order', 
			  	csboss__License__c = lic.Id, 
			  	AccountId = Acct.Id,
			  	csboss__Partner_Contract_Terms__c = cntrct.Id,
			  	csboss__Service_Start_Date__c = System.Today().addDays(1),
			  	csboss__Date_Partner_Received_Customer_Order__c = System.Today().addDays(1),
			  	csboss__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c = System.Today().addDays(1),
			  	Pricebook2Id = priceBookEntry.Pricebook2Id
					);
			  insert oppty;

			  OpportunityLineItem opptyLineItem1 = new OpportunityLineItem(
			  	OpportunityId = oppty.Id,
			  	PricebookEntryId = priceBookEntry.Id,
			  	UnitPrice = 10,
			  	Quantity = 10,
			  	Description = 'This line item is currently setup with the Service Detail Line Item.'
			  	);
			 insert opptyLineItem1; 
			  
			  CHANNEL_ORDERS__Service_Order__c service = new CHANNEL_ORDERS__Service_Order__c(
			  	CHANNEL_ORDERS__Related_Opportunity__c = oppty.Id,
			  	CHANNEL_ORDERS__Service_Start_Date__c	 = oppty.csboss__Service_Start_Date__c,
			  	CHANNEL_ORDERS__Partner_Contract_Rules__c = String.valueOf(oppty.csboss__Partner_Contract_Terms__c).subString(0,15),
			  	CHANNEL_ORDERS__Date_Partner_Received_Customer_Order__c = oppty.csboss__Date_Partner_Received_Customer_Order__c,
			  	CHANNEL_ORDERS__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c = oppty.csboss__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c,
			  	CHANNEL_ORDERS__Order_Type__c = oppty.csboss__Channel_Order_Type__c,
			  	CHANNEL_ORDERS__Customer_Org_ID__c = lic.sfLma__Subscriber_Org_ID__c
			  	);		  
			  insert service;

			  csboss__BOSS_Order__c boss = new csboss__BOSS_Order__c(
			   	csboss__Opportunity__c = oppty.Id,
			   	csboss__Service_Order__c = service.Id
			   	);
	  		insert boss;

			  test.startTest();
			   CHANNEL_ORDERS__Service_Order_Detail__c soli = new CHANNEL_ORDERS__Service_Order_Detail__c(
 					CHANNEL_ORDERS__Partner_Order__c = service.Id,
 					CHANNEL_ORDERS__Product_Name__c  = catalog.Id,
 					CHANNEL_ORDERS__Quantity__c = 10,
 					CHANNEL_ORDERS__Customer_Price_Per_Month__c = 50,
 					//CHANNEL_ORDERS__pc_Contract_Length__c = ,
 					CHANNEL_ORDERS__pc_Partner_Contract_Term__c = cntrct.Id
 					);

 				insert soli;

			  test.stopTest();
			  
			  List<csboss__BOSS_Order_Detail__c> boli1 = [SELECT Id FROM csboss__BOSS_Order_Detail__c WHERE csboss__BOSS_Order__c = :boss.Id];
			  List<csboss__BOSS_Order_Detail__c> boli2 = [SELECT Id FROM csboss__BOSS_Order_Detail__c WHERE csboss__Service_Order_Detail__c = :soli.Id];
			  List<csboss__BOSS_Order_Detail__c> boli3 = [SELECT Id FROM csboss__BOSS_Order_Detail__c WHERE csboss__Net_ARR__c = -6000];
				List<csboss__BOSS_Order_Detail__c> boli4 = [SELECT Id FROM csboss__BOSS_Order_Detail__c WHERE csboss__Net_MRR__c = -500];
				List<csboss__BOSS_Order_Detail__c> boli5 = [SELECT Id FROM csboss__BOSS_Order_Detail__c WHERE csboss__Net_Seats__c = -10];

			  System.assertEquals(1,boli1.size());	
			  System.assertEquals(1,boli2.size());
			  System.assertEquals(1,boli3.size());
			  System.assertEquals(1,boli4.size());
			  System.assertEquals(1,boli5.size());
	}

	static testMethod void TestBossDetailFieldsUpdateStatusUpgradeOrgEdition()
	{
		Global_Settings__c settings = new Global_Settings__c();
			settings = Global_Settings__c.getOrgDefaults();
			settings.csboss__Enabled_Opportunity_Line_Item_Trigger__c = TRUE;
		upsert settings;

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
							sfLma__Subscriber_Org_ID__c = '00D61000000eWOY',
							csboss__Has_Initial_Order__c = TRUE
							);
		insert lic;

		CHANNEL_ORDERS__Partner_Contract_Terms__c cntrct = new CHANNEL_ORDERS__Partner_Contract_Terms__c(
			  	Name = 'Test Contract', 
			  	CHANNEL_ORDERS__Partner_API_Key__c = 'ABCDE123456',
			  	CHANNEL_ORDERS__Allow_to_Sell_to_Existing_Org__c = TRUE,
			  	CHANNEL_ORDERS__COA_Sync_timestamp__c = System.Today().addDays(1),
			  	CHANNEL_ORDERS__Default_Contract_Length__c = 12
			  	);
			  insert cntrct;

			  CHANNEL_ORDERS__Partner_Product_Catalog__c catalog = new CHANNEL_ORDERS__Partner_Product_Catalog__c(
			  	CHANNEL_ORDERS__Partner_Contract_Terms__c = cntrct.Id,
			  	CHANNEL_ORDERS__Billing_Frequency__c = 12,
			  	CHANNEL_ORDERS__Cancellation_Terms__c = 12,
			  	CHANNEL_ORDERS__Contract_Auto_Renew__c = 'Yes',
			  	CHANNEL_ORDERS__Contract_Length__c = 24,
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
			  	csboss__Channel_Order_Type__c = 'Upgrade - Org Edition', 
			  	csboss__License__c = lic.Id, 
			  	AccountId = Acct.Id,
			  	csboss__Partner_Contract_Terms__c = cntrct.Id,
			  	csboss__Service_Start_Date__c = System.Today().addDays(1),
			  	csboss__Date_Partner_Received_Customer_Order__c = System.Today().addDays(1),
			  	csboss__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c = System.Today().addDays(1),
			  	Pricebook2Id = priceBookEntry.Pricebook2Id
					);
			  insert oppty;

			  OpportunityLineItem opptyLineItem1 = new OpportunityLineItem(
			  	OpportunityId = oppty.Id,
			  	PricebookEntryId = priceBookEntry.Id,
			  	UnitPrice = 10,
			  	Quantity = 10,
			  	Description = 'This line item is currently setup with the Service Detail Line Item.'
			  	);
			 insert opptyLineItem1; 
			  
			  CHANNEL_ORDERS__Service_Order__c service = new CHANNEL_ORDERS__Service_Order__c(
			  	CHANNEL_ORDERS__Related_Opportunity__c = oppty.Id,
			  	CHANNEL_ORDERS__Service_Start_Date__c	 = oppty.csboss__Service_Start_Date__c,
			  	CHANNEL_ORDERS__Partner_Contract_Rules__c = String.valueOf(oppty.csboss__Partner_Contract_Terms__c).subString(0,15),
			  	CHANNEL_ORDERS__Date_Partner_Received_Customer_Order__c = oppty.csboss__Date_Partner_Received_Customer_Order__c,
			  	CHANNEL_ORDERS__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c = oppty.csboss__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c,
			  	CHANNEL_ORDERS__Order_Type__c = oppty.csboss__Channel_Order_Type__c,
			  	CHANNEL_ORDERS__Customer_Org_ID__c = lic.sfLma__Subscriber_Org_ID__c
			  	);		  
			  insert service;

			  csboss__BOSS_Order__c boss = new csboss__BOSS_Order__c(
			   	csboss__Opportunity__c = oppty.Id,
			   	csboss__Service_Order__c = service.Id
			   	);
	  		insert boss;

			  test.startTest();
			   CHANNEL_ORDERS__Service_Order_Detail__c soli = new CHANNEL_ORDERS__Service_Order_Detail__c(
 					CHANNEL_ORDERS__Partner_Order__c = service.Id,
 					CHANNEL_ORDERS__Product_Name__c  = catalog.Id,
 					CHANNEL_ORDERS__Quantity__c = 10,
 					CHANNEL_ORDERS__Customer_Price_Per_Month__c = 50,
 					CHANNEL_ORDERS__pc_Contract_Length__c = 24,
 					CHANNEL_ORDERS__pc_Partner_Contract_Term__c = cntrct.Id
 					);

 				insert soli;

			  test.stopTest();
			  
			  List<csboss__BOSS_Order_Detail__c> boli1 = [SELECT Id FROM csboss__BOSS_Order_Detail__c WHERE csboss__BOSS_Order__c = :boss.Id];
			  List<csboss__BOSS_Order_Detail__c> boli2 = [SELECT Id FROM csboss__BOSS_Order_Detail__c WHERE csboss__Service_Order_Detail__c = :soli.Id];
			  List<csboss__BOSS_Order_Detail__c> boli3 = [SELECT Id FROM csboss__BOSS_Order_Detail__c WHERE csboss__Net_ARR__c = 6000];
				List<csboss__BOSS_Order_Detail__c> boli4 = [SELECT Id FROM csboss__BOSS_Order_Detail__c WHERE csboss__Net_MRR__c = 500];
				List<csboss__BOSS_Order_Detail__c> boli5 = [SELECT Id FROM csboss__BOSS_Order_Detail__c WHERE csboss__Net_Seats__c = 0];

			  System.assertEquals(1,boli1.size());	
			  System.assertEquals(1,boli2.size());
			  System.assertEquals(1,boli3.size());
			  System.assertEquals(1,boli4.size());
			  System.assertEquals(1,boli5.size());
	}
}