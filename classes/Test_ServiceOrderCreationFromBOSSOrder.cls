@isTest (seeAllData=False)
public class Test_ServiceOrderCreationFromBOSSOrder {
/*	
	static testMethod void testServiceOrderCreated() 
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

	  test.startTest();

       Test.setCurrentPage(Page.ServiceOrderCreationFromBOSSOrder);
       ApexPages.StandardController ctrl = new ApexPages.StandardController(boss);
       ServiceOrderCreationFromBOSSOrder controller = new ServiceOrderCreationFromBOSSOrder(ctrl);	
       controller.CheckForBossOrder();

    test.stopTest();

    List<CHANNEL_ORDERS__Service_Order__c> result = [SELECT Id FROM CHANNEL_ORDERS__Service_Order__c];

    System.assertEquals(1,result.size());

	}

	static testMethod void testConfirmBOSSOpptyHasAccount()
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
	  Opportunity oppty = new Opportunity(Name = 'Test Oppty', CloseDate = System.Today(), StageName='Prospecting',
	  	csboss__Channel_Order_Type__c = 'Initial', csboss__License__c = lic.Id);
	  insert oppty;
	  //Boss Order with Opportunity && License
	  csboss__BOSS_Order__c boss = new csboss__BOSS_Order__c(csboss__Opportunity__c = oppty.Id); //Name='Test Order', 
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

       Test.setCurrentPage(Page.ServiceOrderCreationFromBOSSOrder);
       ApexPages.StandardController ctrl = new ApexPages.StandardController(boss);
       ServiceOrderCreationFromBOSSOrder controller = new ServiceOrderCreationFromBOSSOrder(ctrl);	
       controller.CheckForBossOrder();

				ApexPages.Message[] msgs=ApexPages.getMessages();
       	boolean messagePosted = false;
       	for(ApexPages.Message msg : msgs)
       	{ 
       		if(msg.getDetail().contains('Please add an Account to this BOSS Order.')) 
       		{
       			messagePosted = true;
       		}
       	}
      test.stopTest();
       	for(ApexPages.Message msg : ApexPages.getMessages())
       	{
       		System.assertEquals('Please add an Account to this BOSS Order.', msg.getSummary());
       	}
	}

		static testMethod void testConfirmBOSSOpptyHasLicense()
	{
		Account acct = new Account (Name = 'Test Account');
		insert acct;
	  Opportunity oppty = new Opportunity(Name = 'Test Oppty', CloseDate = System.Today(), StageName='Prospecting',
	  	csboss__Channel_Order_Type__c = 'Initial', AccountId = acct.Id); 
	  insert oppty;

	  csboss__BOSS_Order__c boss = new csboss__BOSS_Order__c(csboss__Opportunity__c = oppty.Id);
	  insert boss;
	
	  CHANNEL_ORDERS__Partner_Contract_Terms__c cntrct = new CHANNEL_ORDERS__Partner_Contract_Terms__c(
	  	Name = 'Test Contract', 
	  	CHANNEL_ORDERS__Partner_API_Key__c = 'ABCDE123456',
	  	CHANNEL_ORDERS__Allow_to_Sell_to_Existing_Org__c = TRUE,
	  	CHANNEL_ORDERS__COA_Sync_timestamp__c = System.Today()
	  	);
	  insert cntrct;

	  test.startTest();

       Test.setCurrentPage(Page.ServiceOrderCreationFromBOSSOrder);
       ApexPages.StandardController ctrl = new ApexPages.StandardController(boss);
       ServiceOrderCreationFromBOSSOrder controller = new ServiceOrderCreationFromBOSSOrder(ctrl);	
       controller.CheckForBossOrder();

				ApexPages.Message[] msgs=ApexPages.getMessages();
       	boolean messagePosted = false;
       	for(ApexPages.Message msg : msgs)
       	{ 
       		if(msg.getDetail().contains('Please add a License to this BOSS Order.')) 
       		{
       			messagePosted = true;
       		}
       	}
      test.stopTest();
       	for(ApexPages.Message msg : ApexPages.getMessages())
       	{
       		System.assertEquals('Please add a License to this BOSS Order.', msg.getSummary());
       	}
	}

	static testMethod void testCustomerCreated()
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
	  csboss__BOSS_Order__c boss = new csboss__BOSS_Order__c( csboss__Opportunity__c = oppty.Id);
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

       Test.setCurrentPage(Page.ServiceOrderCreationFromBOSSOrder);
       ApexPages.StandardController ctrl = new ApexPages.StandardController(boss);
       ServiceOrderCreationFromBOSSOrder controller = new ServiceOrderCreationFromBOSSOrder(ctrl);	
       controller.CheckForBossOrder();

    test.stopTest();

    List<CHANNEL_ORDERS__Customer__c> result = [SELECT Id FROM CHANNEL_ORDERS__Customer__c WHERE csboss__Account__c = :acct.Id];

    System.assertEquals(1,result.size());
 	}

 	static testMethod void testExistingAccountCommitUpdateButton()
 	{
 		sfLma__License__c lic = new sfLma__License__c(
					sfLma__Install_Date__c = System.Today(),
					sfLma__Seats__c = 4,
					sfLma__Status__c = 'Active',
					sfLma__Subscriber_Org_ID__c = '00D61000000eWOY'
					);
		insert lic;
	  Opportunity oppty = new Opportunity(Name = 'Test Oppty', CloseDate = System.Today(), StageName='Prospecting',
	  	csboss__Channel_Order_Type__c = 'Initial', csboss__License__c = lic.Id);
	  insert oppty;

	 csboss__BOSS_Order__c boss = new csboss__BOSS_Order__c(csboss__Opportunity__c = oppty.Id, csboss__Account__c = NULL);
	  insert boss;

 		CHANNEL_ORDERS__Partner_Contract_Terms__c cntrct = new CHANNEL_ORDERS__Partner_Contract_Terms__c(
	  	Name = 'Test Contract', 
	  	CHANNEL_ORDERS__Partner_API_Key__c = 'ABCDE123456',
	  	CHANNEL_ORDERS__Allow_to_Sell_to_Existing_Org__c = TRUE,
	  	CHANNEL_ORDERS__COA_Sync_timestamp__c = System.Today()
	  	);
	  insert cntrct;

 		Account anAccount = new Account(Name = 'VFPage Test');
 		insert anAccount;

 		test.startTest();
 	  ApexPages.StandardController ctrl = new ApexPages.StandardController(boss);
 	  ServiceOrderCreationFromBOSSOrder controller = new ServiceOrderCreationFromBOSSOrder(ctrl);	
 	 	controller.bossOppty.AccountId = anAccount.ID;
 	  controller.onCommit();
 	  test.stopTest();

 	  
 	  List<CHANNEL_ORDERS__Service_Order__c> result = [SELECT Id FROM CHANNEL_ORDERS__Service_Order__c];

    System.assertEquals(1,result.size());
    System.assertEquals(controller.bossOppty.AccountId, anAccount.Id);

 	}
 	static testMethod void testExistingLicenseCommitUpdateButton()
 	{
 		sfLma__License__c lic = new sfLma__License__c(
					sfLma__Install_Date__c = System.Today(),
					sfLma__Seats__c = 4,
					sfLma__Status__c = 'Active',
					sfLma__Subscriber_Org_ID__c = '00D61000000eWOY'
					);
		insert lic;

		Account anAccount = new Account(Name = 'VFPage Test');
 		insert anAccount;

	  Opportunity oppty = new Opportunity(Name = 'Test Oppty', CloseDate = System.Today(), StageName='Prospecting',
	  csboss__Channel_Order_Type__c = 'Initial', AccountId = anAccount.Id);
	  insert oppty;

	 csboss__BOSS_Order__c boss = new csboss__BOSS_Order__c(csboss__Opportunity__c = oppty.Id);
	  insert boss;

 		CHANNEL_ORDERS__Partner_Contract_Terms__c cntrct = new CHANNEL_ORDERS__Partner_Contract_Terms__c(
	  	Name = 'Test Contract', 
	  	CHANNEL_ORDERS__Partner_API_Key__c = 'ABCDE123456',
	  	CHANNEL_ORDERS__Allow_to_Sell_to_Existing_Org__c = TRUE,
	  	CHANNEL_ORDERS__COA_Sync_timestamp__c = System.Today()
	  	);
	  insert cntrct;

 		test.startTest();
 	  ApexPages.StandardController ctrl = new ApexPages.StandardController(boss);
 	  ServiceOrderCreationFromBOSSOrder controller = new ServiceOrderCreationFromBOSSOrder(ctrl);	
 	 	controller.bossOppty.csboss__License__c = lic.Id;
 	  controller.onCommit();
 	  test.stopTest();

 	  List<CHANNEL_ORDERS__Service_Order__c> result = [SELECT Id FROM CHANNEL_ORDERS__Service_Order__c];

    System.assertEquals(1,result.size());
 	  System.assertEquals(controller.bossOppty.csboss__License__c, lic.Id);

 	}

 	static testMethod void testNewAccountCommitUpdateButton()
 	{
 		sfLma__License__c lic = new sfLma__License__c(
					sfLma__Install_Date__c = System.Today(),
					sfLma__Seats__c = 4,
					sfLma__Status__c = 'Active',
					sfLma__Subscriber_Org_ID__c = '00D61000000eWOY'
					);

		insert lic;
	  Opportunity oppty = new Opportunity(Name = 'Test Oppty', CloseDate = System.Today(), StageName='Prospecting',
	  	csboss__Channel_Order_Type__c = 'Initial', csboss__License__c = lic.Id);
	  insert oppty;
	  csboss__BOSS_Order__c boss = new csboss__BOSS_Order__c(csboss__Opportunity__c = oppty.Id);
	  insert boss;
	  CHANNEL_ORDERS__Partner_Contract_Terms__c cntrct = new CHANNEL_ORDERS__Partner_Contract_Terms__c(
	  	Name = 'Test Contract', 
	  	CHANNEL_ORDERS__Partner_API_Key__c = 'ABCDE123456',
	  	CHANNEL_ORDERS__Allow_to_Sell_to_Existing_Org__c = TRUE,
	  	CHANNEL_ORDERS__COA_Sync_timestamp__c = System.Today()
	  	);
	  insert cntrct;

 	  ApexPages.StandardController ctrl = new ApexPages.StandardController(boss);
 	  ServiceOrderCreationFromBOSSOrder controller = new ServiceOrderCreationFromBOSSOrder(ctrl);	
 	    controller.Name = 'VFPage Test';
 			controller.BillingStreet = '12345 Main';
 			controller.BillingCity = 'test';
 			controller.BillingState = 'AA';
 	   controller.onCommit();

 	  Account newAccount = [SELECT Id FROM Account WHERE Name = 'VFPage Test'];
 	 	List<CHANNEL_ORDERS__Customer__c> result = [SELECT Id FROM CHANNEL_ORDERS__Customer__c];

    System.assertEquals(1,result.size());
 	  System.assertEquals(controller.bossOppty.AccountId, newAccount.Id);
 	}


	//static testMethod void testForOpportunityOnBOSSOrder()
	//{

	//}
	//static testMethod void testForAccountOnBOSSOrderOpportunity()
	//{

	//}
*/
}