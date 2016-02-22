public with sharing class Setup {

        public Boolean IsBOSSBatchScheduled {get;set;}
        public String BOSSBatchExecutedTime {get; set;}
        public Boolean HasBOSSBatchRunManually {get; set;}
        public String BOSSBatchManualRunTime {get;set;}
        public Id BatchJobID {get;set;}
        public Boolean tooManyJobs {get; set;}
        public Boolean LeadMerge {get; set;}
        public Boolean ConvertLeadToContact {get; set;}
        public Boolean IsAppInstalledCampaign{get; set;}
        public Id CreatedAppInstalledCampaign{get;set;}
        public Boolean RenderInstalledCampaign{get; set;}
        public String CampaignInlineHelptext {get;set;}
        public Boolean IsTestDriveCampaign{get; set;}
        public Id CreatedTestDriveCampaign{get;set;}
        public boolean RenderTestDriveCampaign{get; set;}
        public Boolean IsTrialForceCampaign{get; set;}
        public Id CreatedTrialForceCampaign{get; set;}
        public Boolean RenderTrialForceCampaign{get; set;}
        public Boolean IsDemoVideoCampaign{get; set;}
        public Id CreatedDemoVideoCampaign{get; set;}
        public Boolean RenderDemoVideoCampaign{get; set;}
        public Boolean CanCreateCampaigns{get; set;}
        public Boolean EnableOpptyLineTrigger {get;set;}
        //public Boolean IsNotificationRequested {get;set;}
        //public Contact notificationCon{get;set;}

        private Global_Settings__c settings {get; set;} 

         public List<String> settingsErrorList {
              get {
                  if(this.settingsErrorList == null) {   
                      this.settingsErrorList = new List<String>();
                  }            
                  return this.settingsErrorList;
              }
              set;
          }
         public List<String> triggerSettingsErrorList {
              get {
                  if(this.triggerSettingsErrorList == null) {   
                      this.triggerSettingsErrorList = new List<String>();
                  }            
                  return this.triggerSettingsErrorList;
              }
              set;
          }
         public List<String> batchOperationsErrorList {
            get {
                if(this.batchOperationsErrorList == null) {   
                    this.batchOperationsErrorList = new List<String>();
                }            
                return this.batchOperationsErrorList;
            }
            set;
        }
        public List<String> campaignCreationErrorList {
            get {
                if(this.campaignCreationErrorList == null) {   
                    this.campaignCreationErrorList = new List<String>();
                }            
                return this.campaignCreationErrorList;
            }
            set;
        }

        public Setup()
        {

          RefreshCustomSettings();
          CheckCronJobs();
          HasBOSSBatchRunManually = FALSE;

          List<CronTrigger> jobs = [SELECT Id 
                                    FROM CronTrigger 
                                    WHERE  NextFireTime != NULL
                                     AND CronJobDetail.Name LIKE 'BOSS Batch Schedulable%'];
          if(jobs.Size() > 0)
                  {
                          BatchJobID = jobs[0].Id;
                  }
        }

        public void CheckCronJobs()
        {
          List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name, PreviousFireTime 
                                    FROM CronTrigger 
                                    WHERE CronJobDetail.Name LIKE 'BOSS Batch Schedulable%' ];
          if(jobs.size() > 0)
            {
            for(CronTrigger con: jobs)
              {
              if(con.CronJobDetail.Name == 'BOSS Batch Schedulable')
                {
                  IsBOSSBatchScheduled = TRUE;
                  BOSSBatchExecutedTime = String.valueOf(con.PreviousFireTime);
                }
              }
            }

          if(String.isBlank(BOSSBatchExecutedTime))
            {
              BOSSBatchExecutedTime = 'Pending';
            }
        }
        
        public PageReference ScheduleOn()
        {
          
          BOSSBatchSchedulable b = new BOSSBatchSchedulable();
          String sch = '0 0 3 * * ?';     
          String batchName = (Test.isRunningTest() ? 'Test Boss Batch' : 'BOSS Batch Schedulable');
          String jobID = system.schedule(batchName, sch, b); 
          return null;

        }

        public PageReference Start()
        {
        if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 4) 
          {
          CheckCronJobs();
          if(IsBOSSBatchScheduled == TRUE) 
          {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'BOSS Scheduled Batch Job Has Already Been Scheduled')); 
          }
          else 
          {
           System.schedule('BOSS Batch Schedulable', '0 ' + DateTime.now().minute() + ' 3 * * ?', new BOSSBatchSchedulable());
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'BOSS Schedulable Batch Job Scheduled Successfully'));      

           IsBOSSBatchScheduled = TRUE;
          }
          } 
        else 
        {
         tooManyJobs = TRUE;
        }

        return null;
        }

        //turn off the scheduled batch
        public PageReference Stop()
        {
                List<CronTrigger> cronJobs = [Select Id from CronTrigger where CronJobDetail.Name LIKE 'BOSS Batch Schedulable%'];
                if(cronJobs.size() > 0)
                        {
                                for(CronTrigger job : cronJobs)
                                {
                                        System.abortJob(job.Id);
                                }
                        }
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'BOSS Schedulable Batch Job Cancelled Successfully')); 

                IsBOSSBatchScheduled = FALSE;

                return null;
        }

        public PageReference RunNow()
        {
                (new BOSSBatchSchedulable()).execute(null);
                HasBOSSBatchRunManually = TRUE;
                BOSSBatchManualRunTime = String.valueOf(System.Today());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'BOSS Batch Job Submitted Successfully')); 
        return null;
        }

        public PageReference CreateCampaigns()
        {


          if(IsAppInstalledCampaign == TRUE && CreatedAppInstalledCampaign == NULL)
            {
              settings = Global_Settings__c.getOrgDefaults();
              Campaign newAppCampaign = new Campaign(
                      Name = 'App Installed Campaign', Status='In Progress', StartDate = System.Today());
              insert newAppCampaign;
                      settings.csboss__CreatedAppInstalledCampaign__c = newAppCampaign.Id;
              upsert settings;
            }

          if(IsTestDriveCampaign == TRUE && CreatedTestDriveCampaign == NULL)
            {
                      settings = Global_Settings__c.getOrgDefaults();
              Campaign newAppCampaign = new Campaign(
                              Name = 'Test Drive Campaign', Status='In Progress', StartDate = System.Today());
              insert newAppCampaign;
                      settings.csboss__CreatedTestDriveCampaign__c = newAppCampaign.Id;
              upsert settings;
            }
          if(IsTrialForceCampaign == TRUE && CreatedTrialForceCampaign == NULL)
          {
            settings = Global_Settings__c.getOrgDefaults();
            Campaign newAppCampaign = new Campaign(
                    Name = 'Trialforce Campaign', Status='In Progress', StartDate = System.Today());
            insert newAppCampaign;
                    settings.csboss__CreatedTrialForceCampaign__c = newAppCampaign.Id;
            upsert settings;
          }
          if(IsDemoVideoCampaign == TRUE && CreatedDemoVideoCampaign == NULL)
          {
            settings = Global_Settings__c.getOrgDefaults();
            Campaign newAppCampaign = new Campaign(
                    Name = 'Demo Video Campaign', Status='In Progress', StartDate = System.Today());
            insert newAppCampaign;
                    settings.csboss__CreatedDemoVideoCampaign__c = newAppCampaign.Id;
            upsert settings;
          }
          RenderCampaigns();
          return null;
        }

        public PageReference RenderCampaigns()
        {

          settings = Global_Settings__c.getOrgDefaults();
          Id installId = settings.csboss__CreatedAppInstalledCampaign__c;
          Id driveId = settings.csboss__CreatedTestDriveCampaign__c;
          Id trialId = settings.csboss__CreatedTrialForceCampaign__c;
          Id demoId = settings.csboss__CreatedDemoVideoCampaign__c;
          Set<Id> campaignIds = new Set<Id>();                
                  campaignIds.add(installId);
                  campaignIds.add(driveId);
                  campaignIds.add(trialId);
                  campaignIds.add(demoId);

          Map<Id,Campaign> newCamp = new Map<Id,Campaign>([SELECT Id FROM Campaign WHERE Id =: campaignIds]);

          if(newcamp.containsKey(installId))
          {
                  RenderInstalledCampaign = FALSE;                
          }
          else
          {
          settings.csboss__CreatedAppInstalledCampaign__c = NULL;
          settings.csboss__AppInstalledCampaign__c = FALSE;
          RenderInstalledCampaign = TRUE; 
          upsert settings;                        
          }

          if(newcamp.containsKey(driveId))
            {
                    RenderTestDriveCampaign = FALSE;                
            }
            else
            {
              settings.csboss__CreatedTestDriveCampaign__c = NULL;
              settings.csboss__TestDriveCampaign__c = FALSE;
              RenderTestDriveCampaign = TRUE; 
              upsert settings;
            }

          if(newcamp.containsKey(trialId))
            {
                    RenderTrialForceCampaign = FALSE;               
            }
            else
            {
              settings.csboss__CreatedTrialForceCampaign__c = NULL;
              settings.csboss__IsTrialForceCampaign__c = FALSE;
              RenderTrialForceCampaign = TRUE;        
              upsert settings;
            }

          if(newcamp.containsKey(demoId))
            {
                    RenderDemoVideoCampaign = FALSE;                
            }
            else
            {
              settings.csboss__CreatedDemoVideoCampaign__c = NULL;
              settings.csboss__IsDemoVideoCampaign__c = FALSE;
              RenderDemoVideoCampaign = TRUE; 
              upsert settings;
            }
          RefreshCustomSettings();
          return null;
  
        }

        public PageReference RetroUpdate()
        {
          this.settingsErrorList.clear();
          RetroactiveUpdate retro = new RetroactiveUpdate();
          this.settingsErrorList = retro.FindUnconnectedServiceOrders();
          return null;
        }


        public void SaveCustomSettings()
        {
          ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info, 'Your settings successfully saved!');
          ApexPages.Message error_msg = new ApexPages.Message(ApexPages.Severity.Error, 'An Error occured while saving your settings! Check the debug logs.');
          
          if(settings != NULL)
          {
            settings.csboss__BOSS_Lead_Merge__c     = LeadMerge;
            settings.csboss__BOSS_Convert_Lead_To_Contact__c        = ConvertLeadToContact;
            settings.csboss__Enabled_Opportunity_Line_Item_Trigger__c = EnableOpptyLineTrigger;
          }

          try
          {
            upsert settings;
            RefreshCustomSettings();
            ApexPages.addMessage(msg);
          }
          catch (Exception e)
          {
            ApexPages.addMessage(error_msg);
            System.Debug('***** Save Custom Setting Error: ' + e.getMessage());
          }
        }

        public PageReference RefreshCustomSettings()
        {
          settings = Global_Settings__c.getOrgDefaults();
          LeadMerge                                                       = settings.BOSS_Lead_Merge__c;
          ConvertLeadToContact                            = settings.BOSS_Convert_Lead_To_Contact__c;
          IsAppInstalledCampaign                          = settings.AppInstalledCampaign__c;
          CreatedAppInstalledCampaign             = settings.CreatedAppInstalledCampaign__c;
          IsTestDriveCampaign                             = settings.TestDriveCampaign__c;
          CreatedTestDriveCampaign                        = settings.CreatedTestDriveCampaign__c;
          IsTrialForceCampaign                            = settings.IsTrialForceCampaign__c;
          CreatedTrialForceCampaign                       = settings.CreatedTrialForceCampaign__c;
          IsDemoVideoCampaign                                     = settings.IsDemoVideoCampaign__c;
          CreatedDemoVideoCampaign                        = settings.CreatedDemoVideoCampaign__c;
          CampaignInlineHelptext                          = settings.Campaign_Inline_Helptext__c;
          EnableOpptyLineTrigger                          = settings.Enabled_Opportunity_Line_Item_Trigger__c;
          //IsNotificationRequested                               = settings.csboss__Notification_Feature__c;
          CanCreateCampaigns = ((CreatedAppInstalledCampaign == NULL) || (CreatedTestDriveCampaign == NULL) || (CreatedTrialForceCampaign == NULL) || (CreatedDemoVideoCampaign == NULL));
          System.Debug('***** CanCreateCampaigns: ' + CanCreateCampaigns);
          return null;
        }
}