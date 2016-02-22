@isTest (seeAllData=false)
public with sharing class Test_OpportunityRenewal {

	static testMethod void testRenewal(){	
		Global_Settings__c settings = new Global_Settings__c();
		settings.Opportunity_Renewal__c = true;
		insert settings;

		Opportunity oppty1 = new Opportunity(
			Name = 'Test1',
			StageName = 'closed won',
			CloseDate = System.Today()
		);
		insert oppty1;
		Opportunity oppty2 = new Opportunity(
			Name = 'Test2',
			StageName = 'prospecting',
			CloseDate = System.Today()
		);
		insert oppty2;
		test.startTest();
		BOSSBatchSchedulable batch = new BOSSBatchSchedulable();
		Database.executeBatch(batch);
		test.stopTest();

		List<Opportunity> result = [SELECT Id FROM Opportunity WHERE StageName = 'Renewal'];
system.debug('******* how many opportunities: '+result.size());
		system.assert(result.size() == 1);
	}
}