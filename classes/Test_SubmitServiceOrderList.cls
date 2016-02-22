@isTest(seeAllData=false)
public with sharing class Test_SubmitServiceOrderList {

	static testMethod void Test_SubmitServiceOrderList() {
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
			  CHANNEL_ORDERS__Customer__c customer = new CHANNEL_ORDERS__Customer__c(
			  	CHANNEL_ORDERS__Customer_City__c = acct.BillingCity,
			  	CHANNEL_ORDERS__Customer_Country__c = acct.BillingCountry,
			  	CHANNEL_ORDERS__Customer_State__c = acct.BillingState,
			  	CHANNEL_ORDERS__Customer_Street__c = acct.BillingStreet,
			  	CHANNEL_ORDERS__Customer_Company_Name__c = acct.Name,
			  	CHANNEL_ORDERS__Customer_ZIP_Postal_Code__c = acct.BillingPostalCode,
			  	CHANNEL_ORDERS__Customer_Org_ID__c = lic.sfLma__Subscriber_Org_ID__c
			  	);
			  insert customer;

			  OpportunityLineItem opptyLineItem1 = new OpportunityLineItem(
			  	OpportunityId = oppty.Id,
			  	PricebookEntryId = priceBookEntry.Id,
			  	UnitPrice = 10,
			  	Quantity = 10,
			  	Description = 'This line item is currently setup with the Service Detail Line Item.'
			  	);
			  insert opptyLineItem1;
			 
			  List<CHANNEL_ORDERS__Service_Order__c> orderList = new List<CHANNEL_ORDERS__Service_Order__c>();

			  CHANNEL_ORDERS__Service_Order__c service = new CHANNEL_ORDERS__Service_Order__c(
			  	CHANNEL_ORDERS__Customer__c = customer.Id,
			  	CHANNEL_ORDERS__Related_Opportunity__c = oppty.Id,
			  	CHANNEL_ORDERS__Service_Order_Status__c = 'Draft',
			  	CHANNEL_ORDERS__Service_Start_Date__c	 = oppty.csboss__Service_Start_Date__c,
			  	CHANNEL_ORDERS__Partner_Contract_Rules__c = String.valueOf(oppty.csboss__Partner_Contract_Terms__c).subString(0,15),
			  	CHANNEL_ORDERS__Date_Partner_Received_Customer_Order__c = oppty.csboss__Date_Partner_Received_Customer_Order__c,
			  	CHANNEL_ORDERS__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c = oppty.csboss__Date_Customer_Accepted_SFDC_Svc_Agrmnt__c,
			  	CHANNEL_ORDERS__Order_Type__c = oppty.csboss__Channel_Order_Type__c,
			  	CHANNEL_ORDERS__I_certify__c = 'Yes',
			  	CHANNEL_ORDERS__Customer_Org_ID__c = lic.sfLma__Subscriber_Org_ID__c,
			  	CHANNEL_ORDERS__Created_with_new_COA__c = TRUE
			  	);
			  orderlist.add(service);
			  insert orderList;

			  CHANNEL_ORDERS__Service_Order_Detail__c detail1 = new CHANNEL_ORDERS__Service_Order_Detail__c(
					CHANNEL_ORDERS__pc_Partner_Contract_Term__c   			=	cntrct.Id,
					CHANNEL_ORDERS__Product_Name__c 										= catalog.Id,
					CHANNEL_ORDERS__Partner_Order__c 										= service.Id, 
					CHANNEL_ORDERS__Customer_Price_Per_Month__c 				= opptyLineItem1.UnitPrice,
					CHANNEL_ORDERS__Product_Line_Description__c 				= opptyLineItem1.Description,
					CHANNEL_ORDERS__Quantity__c													= opptyLineItem1.Quantity,
					csboss__Related_Opportunity_Line_Item__c						= opptyLineItem1.Id
			  	);
			  insert detail1;

			  test.startTest();
			  PageReference pageRef = Page.SubmitServiceOrderListView;
			  Test.setCurrentPage(pageRef);
       	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(orderList);
       	sc.setSelected(orderlist);
       	SubmitServiceOrderListView controller = new SubmitServiceOrderListView(sc);	
       	controller.SubmitOrders();

			  test.stopTest();
			  List<CHANNEL_ORDERS__Service_Order__c> result = [SELECT Id, CHANNEL_ORDERS__Service_Order_Status1__c
			  																								 FROM CHANNEL_ORDERS__Service_Order__c
			  																								 WHERE CHANNEL_ORDERS__Service_Order_Status__c = 'Received' OR CHANNEL_ORDERS__Service_Order_Status__c = 'Error'];
			  System.assertEquals(1,result.size());

	}
}