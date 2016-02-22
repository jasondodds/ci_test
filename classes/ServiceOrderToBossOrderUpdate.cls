public with sharing class ServiceOrderToBossOrderUpdate {
	
	public ServiceOrderToBossOrderUpdate() { }

	public void ServiceOrderPrep(Set<Id> serviceOrder)
	{
		List<csboss__BOSS_Order__c> boss = [SELECT Id,csboss__Service_Order__r.Id,csboss__Service_Order_Status__c
																				FROM csboss__BOSS_Order__c
																				WHERE csboss__Service_Order__r.Id = :serviceOrder];
	  List<CHANNEL_ORDERS__Service_Order__c> service = [SELECT Id, CHANNEL_ORDERS__Service_Order_Status__c
	  																									FROM CHANNEL_ORDERS__Service_Order__c
	  																									WHERE Id = :serviceOrder];
	  List<csboss__BOSS_Order__c> updatableBoss = new List<csboss__BOSS_Order__c>();
	  for(csboss__BOSS_Order__c b :boss)
	  {
	  	for(CHANNEL_ORDERS__Service_Order__c s : service)
	  	{
	  		if(b.csboss__Service_Order__r.Id == s.Id)
	  		{
	  			//at present, only worried about Service Status, but this could change 
	  			if(b.csboss__Service_Order_Status__c != s.CHANNEL_ORDERS__Service_Order_Status__c)
	  			{
	  				b.csboss__Service_Order_Status__c = s.CHANNEL_ORDERS__Service_Order_Status__c;
	  				updatableBoss.add(b);
	  			}
	  		}
	  	}
	  }
	  update updatableBoss;
	}
}