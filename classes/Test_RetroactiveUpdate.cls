@isTest (seeAllData=false)
public class Test_RetroactiveUpdate {

	static testMethod void testBOSSOrderCreation()
	{
		Account acct = new Account (Name = 'Test Account');
		insert acct;

		sfLma__License__c lic = new sfLma__License__c(
					sfLma__Install_Date__c = System.Today(),
					sfLma__Seats__c = 4,
					sfLma__Status__c = 'Active',
					sfLma__Subscriber_Org_ID__c = '00D61000000eWOY',
					sfLma__Account__c = acct.Id
					);

		insert lic;

		Campaign camp = new Campaign(
			Name = 'TestCampaign'
			);
		insert camp;
		
	  Opportunity oppty = new Opportunity(
	  	Name = 'Test Oppty', 
	  	CloseDate = System.Today(), 
	  	StageName='Prospecting',
	  	csboss__Channel_Order_Type__c = 'Initial', 
	  	csboss__License__c = lic.Id, 
	  	AccountId = Acct.Id,
	  	CampaignId = camp.Id);
	  insert oppty;
	  
	  CHANNEL_ORDERS__Partner_Contract_Terms__c cntrct = new CHANNEL_ORDERS__Partner_Contract_Terms__c(
	  	Name = 'Test Contract', 
	  	CHANNEL_ORDERS__Partner_API_Key__c = 'ABCDE123456',
	  	CHANNEL_ORDERS__Allow_to_Sell_to_Existing_Org__c = TRUE,
	  	CHANNEL_ORDERS__COA_Sync_timestamp__c = System.Today(),
	  	CHANNEL_ORDERS__Default_Contract_Length__c = 12
	  	);
	  insert cntrct;
	 
	  CHANNEL_ORDERS__Service_Order__c serviceOrder = new CHANNEL_ORDERS__Service_Order__c(
	  	CHANNEL_ORDERS__Order_Type__c = 'Initial',
	  	CHANNEL_ORDERS__Service_Start_Date__c = oppty.CloseDate,
	  	CHANNEL_ORDERS__Partner_Contract_Rules__c = cntrct.Id,
	  	CHANNEL_ORDERS__Customer_Org_ID__c = lic.sfLma__Subscriber_Org_ID__c,
	  	CHANNEL_ORDERS__Service_Order_Status__c	= 'Draft',
	  	CHANNEL_ORDERS__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c = System.today(),
	  	CHANNEL_ORDERS__Date_Partner_Received_Customer_Order__c = oppty.CloseDate,
	  	CHANNEL_ORDERS__Related_Opportunity__c = oppty.Id
	  	);
	  insert serviceOrder;
System.Debug(' ******* TEST: SERVICE ****** ' +serviceOrder);
	  test.startTest();
	  RetroactiveUpdate retro = new RetroactiveUpdate();
	  retro.FindUnconnectedServiceOrders();
	  test.stopTest();

	  List<csboss__BOSS_Order__c> result = [SELECT Id FROM csboss__BOSS_Order__c WHERE csboss__Service_Order__c = :serviceOrder.Id];
	  List<csboss__BOSS_Order__c> result2 = [SELECT Id FROM csboss__BOSS_Order__c WHERE csboss__License__c =:lic.Id];
	  List<csboss__BOSS_Order__c> result3 = [SELECT Id FROM csboss__BOSS_Order__c WHERE csboss__Campaign__c =:camp.Id];
	  List<csboss__BOSS_Order__c> result4 = [SELECT Id FROM csboss__BOSS_Order__c WHERE csboss__Account__c =:acct.Id];
	  System.assertEquals(1,result.size());
	  System.assertEquals(1,result2.size());
	  System.assertEquals(1,result3.size());
	  System.assertEquals(1,result4.size());

	}

	static testMethod void testBOSSOrderCreationWithCreateOrderBOPresent()
	{
		Account acct = new Account (Name = 'Test Account');
		insert acct;

		sfLma__License__c lic = new sfLma__License__c(
					sfLma__Install_Date__c = System.Today(),
					sfLma__Seats__c = 4,
					sfLma__Status__c = 'Active',
					sfLma__Subscriber_Org_ID__c = '00D61000000eWOY'
					);

		insert lic;
		
	  Opportunity oppty = new Opportunity(Name = 'Test Oppty', CloseDate = System.Today(), StageName='Prospecting',
	  	csboss__Channel_Order_Type__c = 'Initial', csboss__License__c = lic.Id, AccountId = Acct.Id);
	  insert oppty;
	  
	  CHANNEL_ORDERS__Partner_Contract_Terms__c cntrct = new CHANNEL_ORDERS__Partner_Contract_Terms__c(
	  	Name = 'Test Contract', 
	  	CHANNEL_ORDERS__Partner_API_Key__c = 'ABCDE123456',
	  	CHANNEL_ORDERS__Allow_to_Sell_to_Existing_Org__c = TRUE,
	  	CHANNEL_ORDERS__COA_Sync_timestamp__c = System.Today(),
	  	CHANNEL_ORDERS__Default_Contract_Length__c = 12
	  	);
	  insert cntrct;
	 	
	 	csboss__BOSS_Order__c boss = new csboss__BOSS_Order__c(
	  	csboss__Opportunity__c = oppty.Id ,
	  	csboss__License__c = lic.Id
	  	);
	  insert boss;

	  CHANNEL_ORDERS__Service_Order__c serviceOrder = new CHANNEL_ORDERS__Service_Order__c(
	  	CHANNEL_ORDERS__Order_Type__c = 'Initial',
	  	CHANNEL_ORDERS__Service_Start_Date__c = oppty.CloseDate,
	  	CHANNEL_ORDERS__Partner_Contract_Rules__c = cntrct.Id,
	  	CHANNEL_ORDERS__Customer_Org_ID__c = lic.sfLma__Subscriber_Org_ID__c,
	  	CHANNEL_ORDERS__Service_Order_Status__c	= 'Draft',
	  	CHANNEL_ORDERS__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c = System.today(),
	  	CHANNEL_ORDERS__Date_Partner_Received_Customer_Order__c = oppty.CloseDate,
	  	CHANNEL_ORDERS__Related_Opportunity__c = oppty.Id,
	  	csboss__BOSS_Order__c = boss.Id
	  	);
	  insert serviceOrder;
	  boss.csboss__Service_Order__c = serviceOrder.Id;
	  update boss;

	  	CHANNEL_ORDERS__Service_Order__c serviceOrder2 = new CHANNEL_ORDERS__Service_Order__c(
	  	CHANNEL_ORDERS__Order_Type__c = 'Initial',
	  	CHANNEL_ORDERS__Service_Start_Date__c = System.today(),
	  	CHANNEL_ORDERS__Partner_Contract_Rules__c = cntrct.Id,
	  	CHANNEL_ORDERS__Customer_Org_ID__c = lic.sfLma__Subscriber_Org_ID__c,
	  	CHANNEL_ORDERS__Service_Order_Status__c	= 'Draft',
	  	CHANNEL_ORDERS__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c = System.today(),
	  	CHANNEL_ORDERS__Date_Partner_Received_Customer_Order__c = System.today(),
	  	CHANNEL_ORDERS__Related_Opportunity__c = oppty.Id
	  	);
	  insert serviceOrder2;

	

	  test.startTest();
	  RetroactiveUpdate retro = new RetroactiveUpdate();
	  retro.FindUnconnectedServiceOrders();
	  test.stopTest();

	  List<csboss__BOSS_Order__c> result = [SELECT Id,csboss__Service_Order__c FROM csboss__BOSS_Order__c WHERE csboss__Service_Order__c != NULL];

	  System.assertEquals(2,result.size());

	}

	static testMethod void testBOSSOrderCreationWithCreateOrderNoBORelationship()
	{
		Account acct = new Account (Name = 'Test Account');
		insert acct;

		sfLma__License__c lic = new sfLma__License__c(
					sfLma__Install_Date__c = System.Today(),
					sfLma__Seats__c = 4,
					sfLma__Status__c = 'Active',
					sfLma__Subscriber_Org_ID__c = '00D61000000eWOY'
					);

		insert lic;
		
	  Opportunity oppty = new Opportunity(Name = 'Test Oppty', CloseDate = System.Today(), StageName='Prospecting',
	  	csboss__Channel_Order_Type__c = 'Initial', csboss__License__c = lic.Id, AccountId = Acct.Id);
	  insert oppty;
	  
	  CHANNEL_ORDERS__Partner_Contract_Terms__c cntrct = new CHANNEL_ORDERS__Partner_Contract_Terms__c(
	  	Name = 'Test Contract', 
	  	CHANNEL_ORDERS__Partner_API_Key__c = 'ABCDE123456',
	  	CHANNEL_ORDERS__Allow_to_Sell_to_Existing_Org__c = TRUE,
	  	CHANNEL_ORDERS__COA_Sync_timestamp__c = System.Today(),
	  	CHANNEL_ORDERS__Default_Contract_Length__c = 12
	  	);
	  insert cntrct;
	 	
	  CHANNEL_ORDERS__Service_Order__c serviceOrder = new CHANNEL_ORDERS__Service_Order__c(
	  	CHANNEL_ORDERS__Order_Type__c = 'Initial',
	  	CHANNEL_ORDERS__Service_Start_Date__c = oppty.CloseDate,
	  	CHANNEL_ORDERS__Partner_Contract_Rules__c = cntrct.Id,
	  	CHANNEL_ORDERS__Customer_Org_ID__c = lic.sfLma__Subscriber_Org_ID__c,
	  	CHANNEL_ORDERS__Service_Order_Status__c	= 'Draft',
	  	CHANNEL_ORDERS__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c = System.today(),
	  	CHANNEL_ORDERS__Date_Partner_Received_Customer_Order__c = oppty.CloseDate,
	  	CHANNEL_ORDERS__Related_Opportunity__c = oppty.Id
	  	);
	  insert serviceOrder;


	  csboss__BOSS_Order__c boss = new csboss__BOSS_Order__c(
	  	csboss__Opportunity__c = oppty.Id,
	  	csboss__Service_Order__c = serviceOrder.Id,
	  	csboss__License__c = lic.Id
	  	);
	  insert boss;

	  	CHANNEL_ORDERS__Service_Order__c serviceOrder2 = new CHANNEL_ORDERS__Service_Order__c(
	  	CHANNEL_ORDERS__Order_Type__c = 'Initial',
	  	CHANNEL_ORDERS__Service_Start_Date__c = System.today(),
	  	CHANNEL_ORDERS__Partner_Contract_Rules__c = cntrct.Id,
	  	CHANNEL_ORDERS__Customer_Org_ID__c = lic.sfLma__Subscriber_Org_ID__c,
	  	CHANNEL_ORDERS__Service_Order_Status__c	= 'Draft',
	  	CHANNEL_ORDERS__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c = System.today(),
	  	CHANNEL_ORDERS__Date_Partner_Received_Customer_Order__c = System.today(),
	  	CHANNEL_ORDERS__Related_Opportunity__c = oppty.Id
	  	);
	  insert serviceOrder2;

	

	  test.startTest();
	  RetroactiveUpdate retro = new RetroactiveUpdate();
	  retro.FindUnconnectedServiceOrders();
	  test.stopTest();

	  List<csboss__BOSS_Order__c> result = [SELECT Id,csboss__Service_Order__c FROM csboss__BOSS_Order__c WHERE csboss__Service_Order__c != NULL];

	  System.assertEquals(2,result.size());

	}

	static testMethod void testBOLICreation()
	{
		Account acct = new Account (Name = 'Test Account');
		insert acct;

		sfLma__License__c lic = new sfLma__License__c(
					sfLma__Install_Date__c = System.Today(),
					sfLma__Seats__c = 4,
					sfLma__Status__c = 'Active',
					sfLma__Subscriber_Org_ID__c = '00D61000000eWOY',
					sfLma__Account__c = acct.Id
					);
		insert lic;

	  CHANNEL_ORDERS__Partner_Contract_Terms__c cntrct = new CHANNEL_ORDERS__Partner_Contract_Terms__c(
	  	Name = 'Test Contract', 
	  	CHANNEL_ORDERS__Partner_API_Key__c = 'ABCDE123456',
	  	CHANNEL_ORDERS__Allow_to_Sell_to_Existing_Org__c = TRUE,
	  	CHANNEL_ORDERS__COA_Sync_timestamp__c = System.Today(),
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

		Campaign camp = new Campaign(
			Name = 'TestCampaign'
			);
		insert camp;

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
	  	CampaignId = camp.Id);
	  insert oppty;

	  CHANNEL_ORDERS__Service_Order__c serviceOrder = new CHANNEL_ORDERS__Service_Order__c(
	  	CHANNEL_ORDERS__Order_Type__c = 'Initial',
	  	CHANNEL_ORDERS__Service_Start_Date__c = oppty.CloseDate,
	  	CHANNEL_ORDERS__Partner_Contract_Rules__c = cntrct.Id,
	  	CHANNEL_ORDERS__Customer_Org_ID__c = lic.sfLma__Subscriber_Org_ID__c,
	  	CHANNEL_ORDERS__Service_Order_Status__c	= 'Draft',
	  	CHANNEL_ORDERS__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c = System.today(),
	  	CHANNEL_ORDERS__Date_Partner_Received_Customer_Order__c = oppty.CloseDate,
	  	CHANNEL_ORDERS__Related_Opportunity__c = oppty.Id
	  	);
	   insert serviceOrder;

	  CHANNEL_ORDERS__Service_Order_Detail__c soli = new CHANNEL_ORDERS__Service_Order_Detail__c(
	  	CHANNEL_ORDERS__Partner_Order__c = serviceOrder.Id,
	  	CHANNEL_ORDERS__Product_Name__c  = catalog.Id,
	  	CHANNEL_ORDERS__Quantity__c = 10,
	  	CHANNEL_ORDERS__Customer_Price_Per_Month__c = 10,
	  	CHANNEL_ORDERS__pc_Contract_Length__c = 12

	  	);
	 	insert soli;

	  test.startTest();
	  RetroactiveUpdate retro = new RetroactiveUpdate();
	  retro.FindUnconnectedServiceOrders();
	  test.stopTest();

	  List<csboss__BOSS_Order__c> result1 = [SELECT Id FROM csboss__BOSS_Order__c WHERE csboss__Service_Order__c = :serviceOrder.Id];
	  List<csboss__BOSS_Order_Detail__c> result2 = [SELECT Id FROM csboss__BOSS_Order_Detail__c WHERE csboss__BOSS_Order__c != NULL AND csboss__Service_Order_Detail__c =:soli.Id];

	  System.assertEquals(1,result1.size());
	  System.assertEquals(1,result2.size());
	}

}