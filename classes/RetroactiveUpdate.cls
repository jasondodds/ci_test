public with sharing class RetroactiveUpdate {

/*
	NEED to refactor, to get individual operations broken in methods, for easier navigation/control
*/
	private List<CHANNEL_ORDERS__Service_Order__c> historicService;
	private List<sfLma__License__c>  license;
	public List<String> errorList;

	private Map<Id,Id> serviceOrgId;
	private Set<Id> badService;

	private List<csboss__BOSS_Order__c> anyBO;
	private Set<Id> licenseOrgId;
	private Set<Id> orphanedService;

	public RetroactiveUpdate() { }

	public List<String> FindUnconnectedServiceOrders()
	{	
		errorList = new List<String>();
		//if(Type.forName('sfLma__License__c') == NULL) 
		if(!Schema.getGlobalDescribe().containsKey('sfLma__License__c'))
			{
//FIRST: Does the Org even have the LMA installed?
				errorList.add('Please ensure your License Management Application (LMA) is setup and configured properly. You can then proceed to use this application as outlined in our supporting reference guide. After setup, you can then proceed to create opportunities, add products, and then use the \'create orders\' button on opportunities to get started in integrated your licenses with channel orders. Thank you!');
			}
		else
		{
//SECOND: Are there even any Service Orders that need processing?
	//Make sure no Service Orders have Fat-Finger Customer Org IDs
			historicService = [SELECT Id,CHANNEL_ORDERS__Customer_Org_ID__c FROM CHANNEL_ORDERS__Service_Order__c WHERE csboss__BOSS_Order__c = NULL];
			license = [SELECT Id, sfLma__Subscriber_Org_ID__c FROM sfLma__License__c WHERE sfLma__Subscriber_Org_ID__c != NULL];
			anyBO = new List<csboss__BOSS_Order__c>([SELECT Id, csboss__Service_Order__c FROM csboss__BOSS_Order__c WHERE csboss__Service_Order__c != NULL]);
			badService = new Set<Id>();
			serviceOrgId = new Map<Id,Id>();
			orphanedService = new Set<Id>();

			Set<Id> licenseOrgId = 	new Set<Id>();	
			for(sfLma__License__c l: license)
			{
				if(license.size()>0)
				{
					licenseOrgId.add(l.sfLma__Subscriber_Org_ID__c);
				}
			}


		//Create a map of ServiceOrder.Id and Customer_Org_ID
//Check to insure the LicenseOrgID set contains the Customer_Org_ID in the Map
//if it doesnt --> remove it from the Map...and add it to the badService
			if(historicService.size()>0)
			{
				for(CHANNEL_ORDERS__Service_Order__c s :historicService)
				{
					serviceOrgId.put(s.Id,s.CHANNEL_ORDERS__Customer_Org_ID__c);
				}
			}
			for(CHANNEL_ORDERS__Service_Order__c s :historicService)
			{
				if(!licenseOrgId.contains(serviceOrgId.get(s.Id)))
					{
						badService.add(s.Id);
						serviceOrgId.remove(s.Id);
				}
			}

// CreateFinalServiceOrderList()

//Historic Service list is now corrupt, because BadService is in it.  Need a new list of clean Service to work from
			List<CHANNEL_ORDERS__Service_Order__c> serviceOrdersToBossOrder = new List<CHANNEL_ORDERS__Service_Order__c>();
			if(serviceOrgId.size()>0)
			{
				for(CHANNEL_ORDERS__Service_Order__c s :historicService)
				{
					if(serviceOrgId.containsKey(s.Id))
					{
						serviceOrdersToBossOrder.add(s);
					}
				}
			}

				if(serviceOrdersToBossOrder.size()>0)
				{
					Set<Id> bossServiceIDs = new Set<Id>();

				 	if(anyBO.size()>0)
				 	 {
				 	 	//Where Boss Order size > 0, but Boss.Service_Order == ServiceOrder
							for(csboss__BOSS_Order__c b: anyBO)
							{
								for(CHANNEL_ORDERS__Service_Order__c s:serviceOrdersToBossOrder)
								{
										//If the SO is old, we want to Add it to the list of consideration 
										//But if SO is new but not used App, we still need to catch it
										if(b.csboss__Service_Order__c != NULL)
										{
											bossServiceIDs.add(b.csboss__Service_Order__c);
										}
//if the ServiceOrder Map does NOT contain the Service Order from BOSS, then it's orphaned --> Add it to Set
										if(!serviceOrgId.containsKey(b.csboss__Service_Order__c))
										{
											orphanedService.add(s.Id);
										}
								}
							}
							//Where Boss Order size > 0, but Boss.Service != ServiceOrder
							for(CHANNEL_ORDERS__Service_Order__c s:serviceOrdersToBossOrder)
								{
								if(!bossServiceIDs.contains(s.Id))
									{
										if(serviceOrgId.containsKey(s.Id))
										{
											orphanedService.add(s.Id);
										}
									}
							}
						}
						else 
						{
							for(CHANNEL_ORDERS__Service_Order__c s:serviceOrdersToBossOrder)
								{
// REFACTOR --> At this point we know there are not BOs....we need to pass the SO into the subsequent processes, where methods are using Orphan. 
									if(!serviceOrgId.containsKey(s.Id))
											{
												orphanedService.add(s.Id);
											}
									else
									{
										orphanedService.add(s.Id);
									}
								}
						}

							if(orphanedService.size()>0)
								{
									if(badService.size()>0)
										{
											SetUpNewBOSSOrder();
										errorList.add('Your request is processing. Some Service Orders were not processed due to errant Customer Org IDs. These are these affected Service Orders: '+badService);
										}
									else 
										{
											SetUpNewBOSSOrder();
										}
								}
							else
								{
									if(badService.size()>0)
										{
											errorList.add('No service orders exist in your organization without relationships to BOSS Orders. Some Service Orders were not processed due to errant Customer Org IDs. These are these affected Service Orders: '+badService);
										}
										else
										{
								 			errorList.add('No service orders exist in your organization without relationships to BOSS Orders. This process will not run. Additionally, please ensure this BOSS Order application is setup as outlined in our supporting reference guide. After setup, please proceed to create opportunities, add products, and then use the \'create orders\' button on opportunities to get started. The automation built into this package will link your service order transactions to your licenses going forward.');
										}
								}
					}
				else
					{
						errorList.add('No service orders exist in your organization without relationships to BOSS Orders. This process will not run. Additionally, please ensure this BOSS Order application is setup as outlined in our supporting reference guide. After setup, please proceed to create opportunities, add products, and then use the \'create orders\' button on opportunities to get started. The automation built into this package will link your service order transactions to your licenses going forward.');
					}
			}
			return errorList;
   }

	public void SetUpNewBOSSOrder()
	{
		List<CHANNEL_ORDERS__Service_Order__c> serviceOrder = [SELECT Id, CHANNEL_ORDERS__Customer_Org_ID__c,
																														CHANNEL_ORDERS__Related_Opportunity__c, CHANNEL_ORDERS__Service_Order_Status__c,
																														CHANNEL_ORDERS__Related_Opportunity__r.CampaignId
																													 FROM CHANNEL_ORDERS__Service_Order__c
																													 WHERE Id IN :orphanedService];

//Start setting up the relationship to grab the License and Opportunity information
	  List<sfLma__License__c> license = [ SELECT Id, sfLma__Account__c, sfLma__Subscriber_Org_ID__c
	  																		FROM sfLma__License__c
	  																		WHERE sfLma__Subscriber_Org_ID__c != NULL];

		Map<Id,Id> orgToLicenseMap = new Map<Id,Id>();
		for(CHANNEL_ORDERS__Service_Order__c sO :serviceOrder)
		{
			for(sfLma__License__c lic :license)
			{
				if(sO.CHANNEL_ORDERS__Customer_Org_ID__c == lic.sfLma__Subscriber_Org_ID__c)
					{
						orgToLicenseMap.put(lic.sfLma__Subscriber_Org_ID__c, lic.Id);
					}
			}
		}

		List<csboss__BOSS_Order__c> newBossOrders = new List<csboss__BOSS_Order__c>();

			for(CHANNEL_ORDERS__Service_Order__c serve:serviceOrder)
					{
						csboss__BOSS_Order__c boss = new csboss__BOSS_Order__c();
						Integer counter = 0;
						if(counter < orphanedService.size())
						{			
								boss.csboss__Service_Order__c = serve.Id;
								boss.csboss__Service_Order_Status__c = serve.CHANNEL_ORDERS__Service_Order_Status__c;
								if(serve.CHANNEL_ORDERS__Customer_Org_ID__c != NULL)
									{
						  			boss.csboss__License__c = orgToLicenseMap.get(serve.CHANNEL_ORDERS__Customer_Org_ID__c);
									}

								if(serve.CHANNEL_ORDERS__Related_Opportunity__c != NULL)
									{
										boss.csboss__Opportunity__c 		= serve.CHANNEL_ORDERS__Related_Opportunity__c;
										boss.csboss__Campaign__c				= serve.CHANNEL_ORDERS__Related_Opportunity__r.CampaignId;
									}
								for(sfLma__License__c l: license)
								{
									if(l.sfLma__Subscriber_Org_ID__c == serve.CHANNEL_ORDERS__Customer_Org_ID__c)
									{
										boss.csboss__Account__c = l.sfLma__Account__c;
										boss.csboss__License__c = l.Id;
									}
								}
								counter ++;
							}
					  newBossOrders.add(boss);
					}
		insert newBossOrders;
		SetupUpBOLI();
	}

	public void SetupUpBOLI()
	{
		//filter this to the new BO only
		List<csboss__BOSS_Order__c>	bossOrders = [SELECT Id, csboss__Service_Order__c FROM csboss__BOSS_Order__c];
		List<CHANNEL_ORDERS__Service_Order_Detail__c> serviceDetails = [SELECT Id,CHANNEL_ORDERS__Partner_Order__c FROM CHANNEL_ORDERS__Service_Order_Detail__c];
		Set<Id> soliIDs = new Set<Id>();
		List<csboss__BOSS_Order_Detail__c> boli = new List<csboss__BOSS_Order_Detail__c>();
		for(CHANNEL_ORDERS__Service_Order_Detail__c s: serviceDetails)
		{
			for(csboss__BOSS_Order__c b: bossOrders)
			{
				if(s.CHANNEL_ORDERS__Partner_Order__c == b.csboss__Service_Order__c)
				{
					csboss__BOSS_Order_Detail__c boItem = new csboss__BOSS_Order_Detail__c();
					boItem.csboss__BOSS_Order__c = b.Id;
					boItem.csboss__Service_Order_Detail__c = s.Id;
					boli.add(boItem);
				}
			}
		}
		insert boli;
	}

	public void NotificationOfOpportunitiesWithoutAccounts()
	{
			//we may need this
	}
}