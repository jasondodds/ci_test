@isTest (seeAllData=False)
public class Test_Setup {

	 public static String CRON_EXP = '0 0 0 15 3 ? 2022';
	static testMethod void testSchedule()
	{
		test.startTest();
		String jobId = System.schedule('BOSSBatchSchedulableTest',
				CRON_Exp,
				new BOSSBatchSchedulable());
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
						  FROM CronTrigger
						  WHERE id = :jobId];
		System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0,ct.TimesTriggered);
		System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));		
	}

	static testMethod void testStartMessage() {

		test.startTest();
		Global_Settings__c settings = new Global_Settings__c();
		settings = Global_Settings__c.getOrgDefaults();
		Setup controller = new Setup();
		controller.ScheduleOn();
		controller.Start();
		for(ApexPages.Message msg : ApexPages.getMessages())
       	{
       		System.assertEquals('BOSS Scheduled Batch Job Has Already Been Scheduled', msg.getSummary());
       	}
	}

	static testMethod void testStopMessage()
	{
		test.startTest();
		Global_Settings__c settings = new Global_Settings__c();
		settings = Global_Settings__c.getOrgDefaults();
		Setup controller = new Setup();
		controller.ScheduleOn();
		controller.Stop();
		for(ApexPages.Message msg : ApexPages.getMessages())
       	{
       		System.assertEquals('BOSS Schedulable Batch Job Cancelled Successfully', msg.getSummary());
       	}
	}

	static testMethod void testRunNowMessage()
	{
		test.startTest();
		Global_Settings__c settings = new Global_Settings__c();
		settings = Global_Settings__c.getOrgDefaults();
		Setup controller = new Setup();
		controller.ScheduleOn();
		controller.RunNow();
		for(ApexPages.Message msg : ApexPages.getMessages())
       	{
       		System.assertEquals('BOSS Batch Job Submitted Successfully', msg.getSummary());
       	}
	}

	static testMethod void testCampaignCreationAppInstall()
	{
		Global_Settings__c settings = new Global_Settings__c();
		settings = Global_Settings__c.getOrgDefaults();	

		test.startTest();
      Setup setup = new Setup();
      settings.CreatedAppInstalledCampaign__c = NULL;
			setup.IsAppInstalledCampaign = TRUE;	
      setup.CreateCampaigns();

    test.stopTest();
 			List<Campaign> result = [SELECT Id FROM Campaign WHERE Name = 'App Installed Campaign'];
 			System.assertEquals(1,result.size());
	}

		static testMethod void testCampaignCreationDemoVideo()
	{
		Global_Settings__c settings = new Global_Settings__c();
		settings = Global_Settings__c.getOrgDefaults();	

		test.startTest();
      Setup setup = new Setup();
      settings.CreatedDemoVideoCampaign__c = NULL;
			setup.IsDemoVideoCampaign = TRUE;	
      setup.CreateCampaigns();

    test.stopTest();
 			List<Campaign> result = [SELECT Id FROM Campaign WHERE Name = 'Demo Video Campaign'];
 			System.assertEquals(1,result.size());
	}

		static testMethod void testCampaignCreationTestDrive()
	{
		Global_Settings__c settings = new Global_Settings__c();
		settings = Global_Settings__c.getOrgDefaults();	

		test.startTest();
      Setup setup = new Setup();
      settings.CreatedTestDriveCampaign__c = NULL;
			setup.IsTestDriveCampaign = TRUE;	
      setup.CreateCampaigns();

    test.stopTest();
 			List<Campaign> result = [SELECT Id FROM Campaign WHERE Name = 'Test Drive Campaign'];
 			System.assertEquals(1,result.size());
	}

		static testMethod void testCampaignCreationTrialForce()
	{
		Global_Settings__c settings = new Global_Settings__c();
		settings = Global_Settings__c.getOrgDefaults();	

		test.startTest();
      Setup setup = new Setup();
      settings.CreatedTrialForceCampaign__c = NULL;
			setup.IsTrialForceCampaign = TRUE;	
      setup.CreateCampaigns();

    test.stopTest();
 			List<Campaign> result = [SELECT Id FROM Campaign WHERE Name = 'Trialforce Campaign'];
 			System.assertEquals(1,result.size());
	}

		static testMethod void testRenderAppInstallCampaign()
		{
			Global_Settings__c settings = new Global_Settings__c();
			settings = Global_Settings__c.getOrgDefaults();

      Setup setup = new Setup();
      settings.csboss__CreatedAppInstalledCampaign__c = NULL;
			settings.csboss__AppInstalledCampaign__c	= FALSE;
			test.startTest();
      setup.CreateCampaigns();
      
      List<Campaign>  c = [SELECT Id FROM Campaign WHERE Name = 'App Installed Campaign'];

      delete c;
    	test.stopTest();
    	setup.RenderCampaigns();
 			System.assertEquals(true,setup.RenderInstalledCampaign);

		}
		static testMethod void testRenderTrialforceCampaign()
		{
			Global_Settings__c settings = new Global_Settings__c();
			settings = Global_Settings__c.getOrgDefaults();

      Setup setup = new Setup();
      settings.csboss__CreatedTrialForceCampaign__c = NULL;
			settings.csboss__IsTrialForceCampaign__c	= FALSE;
			test.startTest();
      setup.CreateCampaigns();
      
      List<Campaign>  c = [SELECT Id FROM Campaign WHERE Name = 'Trialforce Campaign'];

      delete c;
    	test.stopTest();
    	setup.RenderCampaigns();
 			System.assertEquals(true,setup.RenderTrialForceCampaign);

		}
		static testMethod void testRenderDemoVideoCampaign()
		{
			Global_Settings__c settings = new Global_Settings__c();
			settings = Global_Settings__c.getOrgDefaults();

      Setup setup = new Setup();
      settings.csboss__CreatedDemoVideoCampaign__c = NULL;
			settings.csboss__IsDemoVideoCampaign__c	= FALSE;
			test.startTest();
      setup.CreateCampaigns();
      
      List<Campaign>  c = [SELECT Id FROM Campaign WHERE Name = 'Demo Video Campaign'];

      delete c;
    	test.stopTest();
    	setup.RenderCampaigns();
 			System.assertEquals(true,setup.RenderDemoVideoCampaign);

		}
		static testMethod void testRenderTestDriveCampaign()
		{
			Global_Settings__c settings = new Global_Settings__c();
			settings = Global_Settings__c.getOrgDefaults();

      Setup setup = new Setup();
      settings.csboss__CreatedTestDriveCampaign__c = NULL;
			settings.csboss__IsTrialForceCampaign__c	= FALSE;
			test.startTest();
      setup.CreateCampaigns();
      
      List<Campaign>  c = [SELECT Id FROM Campaign WHERE Name = 'Test Drive Campaign'];

      delete c;
    	test.stopTest();
    	setup.RenderCampaigns();
 			System.assertEquals(true,setup.RenderTestDriveCampaign);

		}

		static testMethod void testRefreshCustomSettings()
		{
			Global_Settings__c settings = new Global_Settings__c();
			settings = Global_Settings__c.getOrgDefaults();
			settings.BOSS_Lead_Merge__c = TRUE;
			upsert settings;
			test.startTest();
			Setup setup = new Setup();
			settings.BOSS_Lead_Merge__c = FALSE;
			upsert settings;
			setup.RefreshCustomSettings();
    	test.stopTest();
			system.assertEquals(FALSE, setup.LeadMerge);
		}
}