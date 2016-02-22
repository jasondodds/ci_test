@isTest (seeAllData=false)
public class Test_BatchSchedulable {

	private static String CRON_EXP = '0 0 0 15 3 ? 2022';

	static testMethod void testSchedule(){				//MOVE TO BATCH TEST

	List<Lead> leads = new List<Lead>();
	leads.add(New Lead(LastName = 'Test1', Company = 'Easy Company', LeadSource = 'SFDC-IN|', Email = 'test1@easy.com'));
	leads.add(New Lead(LastName = 'Test2', Company = 'Easy Company',LeadSource = 'SFDC-DM|', Email = 'test2@easy.com'));
	leads.add(New Lead(LastName = 'Test3', Company = 'Easy Company',LeadSource = 'Conference Call', Email = 'test3@easy.com'));
	insert leads;

	Test.startTest();
	String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, New BOSSBatchSchedulable());
	CronTrigger cron = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
						FROM CronTrigger
						WHERE id = :jobId];

	System.assertEquals(CRON_EXP, cron.CronExpression);
	System.assertEquals(0,cron.TimesTriggered);
	System.assertEquals('2022-03-15 00:00:00', String.valueOf(cron.NextFireTime));

	Test.stopTest();

	}

	//static testMethod void testConfirmCustomSettingsHonored()
	//{
		
	//}

	//static testMethod void testConfirmSettingsRemainAfterUpdate()
	//{

	//}

	//static testMethod void testConfirmBatchesCancel()
	//{

	//}

	
}