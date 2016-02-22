/*********************************************
	Created: December 4, 2015
	Author: Ron Kiker (CodeScience)
	Notes: Class to merge LMA & Web Leads 
	Run on demand - (new BOSSBatchSchedulable().execute(null));
**********************************************/
global class BOSSBatchSchedulable implements Database.Batchable<sObject>, Schedulable {
/********************************
	Schedulable ---> Only requires an "exeecute"
	If there are 5 batch jobs currently running, reschedule the Batch to run 30 minutes later. 
*********************************/
	global void execute(SchedulableContext context)
	{
		BOSSBatchSchedulable batch = new BOSSBatchSchedulable();

		if([SELECT count() FROM AsyncApexJob WHERE JobType ='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 5)
			{
				Database.executeBatch(batch);
			} 
		else 
			{
				Datetime dt = Datetime.now().addMinutes(30);
				String rescheduler = dt.format('s m H d M \'?\' yyyy');
				Id schedId = System.Schedule('BOSS Lead Merge Retry: '+ rescheduler,rescheduler,batch);
			}
	}

/********************************
	Batchable
*********************************/
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		System.Debug('*************** Inside START  *****************');
		String	query = 'SELECT Id, FirstName, LastName, Company, Phone, Email, LeadSource, License__c FROM Lead WHERE (LeadSource LIKE \'SFDC-IN|%\' OR LeadSource LIKE \'SFDC-DM|%\' OR LeadSource LIKE \'SFDC-TD|%\' OR LeadSource LIKE \'SFDC-TS|%\' OR LeadSource LIKE \'Package Installation%\' OR LeadSource LIKE \'SFDC-dup-TS|%\' OR LeadSource LIKE \'SFDC-dup-TD|%\' OR LeadSource LIKE \'SFDC-dup-DM|%\' OR LeadSource LIKE \'SFDC-dup-IN|%\') AND isConverted = FALSE ORDER BY CreatedDate ASC';
		return Database.getQueryLocator(query);
	}

/********************************
	Execute 
*********************************/
	global void execute(Database.BatchableContext BC, List<Lead> scope) {
		System.Debug('*************** Inside EXECUTE *****************');
		//If Lead Merge is ON --> Execute BOSSLeadMerge.cls
		Global_Settings__c settings = Global_Settings__c.getOrgDefaults();
		BOSSLeadMerge boss = new BOSSLeadMerge();
				
			if(settings.BOSS_Lead_Merge__c == true)
			{
				boss.LeadMerge(scope);
			}
			if(settings.BOSS_Convert_Lead_To_Contact__c == true)
			{
				boss.LeadConvertToContact(scope);
			}
	}
/***************************
	Finish
*********************************/
	global void finish(Database.BatchableContext BC) {
	System.Debug('*************** Inside FINISH *****************');
	//Track progress of batch
	for(CronTrigger cron :[	SELECT Id 
							FROM CronTrigger 
							WHERE State = 'DELETED' 
							 AND CronJobDetail.Name LIKE 'BOSSLeadMergeRetry%'])
		{
			System.abortJob(cron.Id);
		}
	Global_Settings__c settings = Global_Settings__c.getOrgDefaults();
		if(settings.Opportunity_Renewal__c == true)
			{
				OpportunityRenewal oppRenew = new OpportunityRenewal();
				oppRenew.CreateClone();
			}
	}

}