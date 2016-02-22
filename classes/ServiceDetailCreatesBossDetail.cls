public with sharing class ServiceDetailCreatesBossDetail 
{

	public ServiceDetailCreatesBossDetail() { }

	public void CreateBossDetailLineItem(Set<Id> newSoli)
	{
		List<CHANNEL_ORDERS__Service_Order_Detail__c> soli = new List<CHANNEL_ORDERS__Service_Order_Detail__c>(
																												[SELECT Id,CHANNEL_ORDERS__Partner_Order__c, CHANNEL_ORDERS__Partner_Order__r.CHANNEL_ORDERS__Order_Type__c,
																												 CHANNEL_ORDERS__Partner_Order__r.CHANNEL_ORDERS__Service_Start_Date__c,CHANNEL_ORDERS__Quantity__c,
																											   CHANNEL_ORDERS__Customer_Price_Per_Month__c
																												 FROM CHANNEL_ORDERS__Service_Order_Detail__c 
																												 WHERE Id IN :newSoli]);

		Map<Id,Id> serviceSoliPair = new Map<Id,Id>();
		for(CHANNEL_ORDERS__Service_Order_Detail__c detail :soli)
			{
				serviceSoliPair.put(detail.CHANNEL_ORDERS__Partner_Order__c,detail.Id);
			}
		List<csboss__BOSS_Order__c> boss = new List<csboss__BOSS_Order__c>([
																				SELECT Id,csboss__Service_Order__c
																				FROM csboss__BOSS_Order__c
																				WHERE csboss__Service_Order__c IN :serviceSoliPair.keySet()]);


		List<csboss__BOSS_Order_Detail__c> newBossDetails = new List<csboss__BOSS_Order_Detail__c>();
		for(csboss__BOSS_Order__c b :boss)
			{
				for(CHANNEL_ORDERS__Service_Order_Detail__c s :soli )
				{
				//if(serviceSoliPair.containsKey(b.csboss__Service_Order__c))
				//	{
					if(b.csboss__Service_Order__c == s.CHANNEL_ORDERS__Partner_Order__c)
					{
						Integer netMRR = Integer.valueOf(s.CHANNEL_ORDERS__Customer_Price_Per_Month__c * s.CHANNEL_ORDERS__Quantity__c);
						Integer netARR = Integer.valueOf((s.CHANNEL_ORDERS__Customer_Price_Per_Month__c * s.CHANNEL_ORDERS__Quantity__c) * 12);
						csboss__BOSS_Order_Detail__c boli = new csboss__BOSS_Order_Detail__c();

						boli.csboss__BOSS_Order__c 						= b.Id;
						boli.csboss__Service_Order_Detail__c  = s.Id;
						//boli.csboss__Service_Order_Detail__c 	= serviceSoliPair.get(b.csboss__Service_Order__c);

						if((s.CHANNEL_ORDERS__Partner_Order__r.CHANNEL_ORDERS__Order_Type__c == 'Initial') || (s.CHANNEL_ORDERS__Partner_Order__r.CHANNEL_ORDERS__Order_Type__c == 'Add-on'))
						{
							boli.csboss__Calculated_Contract_End_Date__c = CalculateServiceStartDate(s.Id);

							boli.csboss__Net_ARR__c = netARR;
							boli.csboss__Net_MRR__c = netMRR;
							boli.csboss__Net_Seats__c =	s.CHANNEL_ORDERS__Quantity__c;
							boli.csboss__Service_Start_Date__c = s.CHANNEL_ORDERS__Partner_Order__r.CHANNEL_ORDERS__Service_Start_Date__c;
						}

						if((s.CHANNEL_ORDERS__Partner_Order__r.CHANNEL_ORDERS__Order_Type__c == 'Cancelation Order') || (s.CHANNEL_ORDERS__Partner_Order__r.CHANNEL_ORDERS__Order_Type__c == 'Reduction'))
						{
							boli.csboss__Calculated_Contract_End_Date__c = CalculateServiceStartDate(s.Id);

							boli.csboss__Net_ARR__c = (-1 * netARR);
							boli.csboss__Net_MRR__c = ( -1 * netMRR);
							boli.csboss__Net_Seats__c =	(-1 * s.CHANNEL_ORDERS__Quantity__c);
							boli.csboss__Service_Start_Date__c = s.CHANNEL_ORDERS__Partner_Order__r.CHANNEL_ORDERS__Service_Start_Date__c;
						}

						if((s.CHANNEL_ORDERS__Partner_Order__r.CHANNEL_ORDERS__Order_Type__c == 'Upgrde - Partner App') || (s.CHANNEL_ORDERS__Partner_Order__r.CHANNEL_ORDERS__Order_Type__c == 'Upgrade - Org Edition'))
						{
							boli.csboss__Calculated_Contract_End_Date__c = CalculateServiceStartDate(s.Id);

							boli.csboss__Net_ARR__c = netARR;
							boli.csboss__Net_MRR__c = netMRR;
							boli.csboss__Net_Seats__c =	0;
							boli.csboss__Service_Start_Date__c = s.CHANNEL_ORDERS__Partner_Order__r.CHANNEL_ORDERS__Service_Start_Date__c;
						}
						newBossDetails.add(boli);
					}
					//}
				 }
			}
		insert newBossDetails;
	}

	private Date CalculateServiceStartDate(Id soliID)
	{
		Date tempDate;
		CHANNEL_ORDERS__Service_Order_Detail__c s = [SELECT Id, CHANNEL_ORDERS__pc_Contract_Length__c, CHANNEL_ORDERS__Partner_Order__r.Id,
																										CHANNEL_ORDERS__Partner_Order__r.CHANNEL_ORDERS__Service_Start_Date__c,
																										CHANNEL_ORDERS__pc_Partner_Contract_Term__r.CHANNEL_ORDERS__Default_Contract_Length__c
		 																								FROM CHANNEL_ORDERS__Service_Order_Detail__c
		 																								WHERE Id = :soliID];
		Date startDate = s.CHANNEL_ORDERS__Partner_Order__r.CHANNEL_ORDERS__Service_Start_Date__c;
		Integer optionA;
		Integer optionB;
		if(s.CHANNEL_ORDERS__pc_Contract_Length__c == NULL)
			{
				optionA = Integer.valueOf(s.CHANNEL_ORDERS__pc_Partner_Contract_Term__r.CHANNEL_ORDERS__Default_Contract_Length__c / 12);
				tempDate = startDate + optionA;
			}
		else
			{
				optionB = Integer.valueOf((s.CHANNEL_ORDERS__pc_Contract_Length__c / 12) * 365);
				tempDate = startDate + optionB;
			}
		return tempDate;
	} 

	public void CleanUpServiceDetailItems(Set<Id> newSoli)
	{
		List<csboss__BOSS_Order_Detail__c> boli = new List<csboss__BOSS_Order_Detail__c>(
																								[SELECT Id 
																								FROM csboss__BOSS_Order_Detail__c
																								WHERE csboss__Service_Order_Detail__c IN :newSoli]);
		if(boli.size() >0)
		{
			Set<String> soliStringId = new Set<String>();
			for(Id id: newSoli)
			{
				soliStringId.add(String.valueOf(id));
			}
			delete [SELECT Id FROM csboss__BOSS_Order_Detail__c WHERE csboss__Service_Order_Detail__c IN :soliStringId];
		}
	}
}