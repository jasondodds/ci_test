@isTest
private class SendSurveyButtonController_Test{

    @isTest static void testLeadsMeetSendCriteria(){
        User user = TestingUtils.createAdminUserWithAdminPermSet();
        System.runAs(user){
            TestingUtils.createApiCustomSettings(user);
            //create leads with no emails to induce error condition 
            Lead lead1 = new Lead(LastName = 'Lead1', Company = 'Acme', Email = 'test@test.com', HasOptedOutOfEmail = true);
            Lead lead2 = new Lead(LastName = 'Lead2', Company = 'Acme', Email = 'test@test.com', HasOptedOutOfEmail = false);
            Lead lead3 = new Lead(LastName = 'Lead3', Company = 'Acme');
            //pass in list of leads
            List<Lead> leadList = new List<Lead>{lead1, lead2, lead3};
            insert leadList;
            Test.startTest();
            Test.setCurrentPage(Page.LeadListSendSurvey);
            ApexPages.StandardSetController setController  = new ApexPages.StandardSetController(leadList);
            setController.setSelected(leadList);
            SendSurveyButtonController controller = new SendSurveyButtonController(setController);
            //call same method as page action
            System.assert(controller.hasCredentials);
            System.assertEquals(null, controller.createPanelFromLeadList());
            System.assertEquals(2, controller.recordsSkipped);
            System.assertEquals(0, controller.ErrorList.size());
            Test.stopTest();
        }
    }

    @isTest static void testNoLeadsSelected(){
        User user = TestingUtils.createStandardUser();
        System.runAs(user){
            TestingUtils.createApiCustomSettings(user);
            //create leads 
            Lead lead1 = new Lead(LastName = 'Lead1', email='lead1@test.com', Company = 'Acme');
            Lead lead2 = new Lead(LastName = 'Lead2', email='lead2@test.com', Company = 'Acme');
            Lead lead3 = new Lead(LastName = 'Lead3', email='lead3@test.com', Company = 'Acme');
            //pass in list of leads
            List<Lead> leadList = new List<Lead>{lead1, lead2, lead3};
            insert leadList;
            Test.startTest();
            Test.setCurrentPage(Page.LeadListSendSurvey);
            ApexPages.StandardSetController setController  = new ApexPages.StandardSetController(leadList);
            SendSurveyButtonController controller = new SendSurveyButtonController(setController);
            //call same method as page action
            System.assertEquals(null, controller.createPanelFromLeadList());
            System.assertEquals(1, controller.ErrorList.size());
            System.assertEquals('No leads selected.', controller.ErrorList[0]);
            Test.stopTest();
        }
    }

    @isTest static void testContactsMeetSendCriteria(){
        User user = TestingUtils.createAdminUserWithAdminPermSet();
        System.runAs(user){
            TestingUtils.createApiCustomSettings(user);
            TestingUtils.createOptOutCustomSettings();
            //create contacts with no emails to induce error condition 
            Contact contact1 = new Contact(LastName = 'testContact1', Email = 'test@test.com', HasOptedOutOfEmail = true);
            Contact contact2 = new Contact(LastName = 'testContact2', Email = 'test@test.com', HasOptedOutOfEmail = false);
            Contact contact3 = new Contact(LastName = 'testContact3');
            Contact contact4 = new Contact(LastName = 'testContact4', Email = 'test@test.com', DoNotCall = true);
            //pass in list of contacts
            List<Contact> contactList = new List<Contact>{contact1, contact2, contact3, contact4};
            insert contactList;
            Test.startTest();
            Test.setCurrentPage(Page.ContactListSendSurvey);
            ApexPages.StandardSetController setController = new ApexPages.StandardSetController(contactList);
            setController.setSelected(contactList);
            SendSurveyButtonController controller = new SendSurveyButtonController(setController);
            //call same method as page action
            System.assertEquals(null, controller.createPanelFromContactList());
            System.assertEquals(3, controller.recordsSkipped);
            System.assertEquals(0, controller.ErrorList.size());
            Test.stopTest();
        }
    }

    @isTest static void testNoContactsSelected(){
        User user = TestingUtils.createStandardUser();
        System.runAs(user){
            TestingUtils.createApiCustomSettings(user);
            Contact contact1 = new Contact(LastName = 'testContact1', email = 'testcontact1@test.com');
            Contact contact2 = new Contact(LastName = 'testContact2', email = 'testcontact2@test.com');
            Contact contact3 = new Contact(LastName = 'testContact3', email = 'testcontact3@test.com');
            //pass in list of contacts
            List<Contact> contactList = new List<Contact>{contact1, contact2, contact3};
            insert contactList;
            Test.startTest();
            Test.setCurrentPage(Page.ContactListSendSurvey);
            ApexPages.StandardSetController setController = new ApexPages.StandardSetController(contactList);
            SendSurveyButtonController controller = new SendSurveyButtonController(setController);
            //call same method as page action
            System.assertEquals(null, controller.createPanelFromContactList());
            System.assertEquals(1, controller.ErrorList.size());
            System.assertEquals('No contacts selected.', controller.ErrorList[0]);
            Test.stopTest();
        }
    }

    @isTest static void testCampaignNoRecipients(){
        User user = TestingUtils.createStandardUser();
        System.runAs(user){
            TestingUtils.createApiCustomSettings(user);
            //test passing in individual campaign
            Campaign campaign = new Campaign(Name = 'test campaign');
            insert campaign;
            //don't add members, to get induce error
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
            Test.setCurrentPage(Page.CampaignSendSurvey);
            ApexPages.StandardController standardController = new ApexPages.StandardController(campaign);
            SendSurveyButtonController controller = new SendSurveyButtonController(standardController);
            controller.createPanelFromCampaign();
            System.debug(controller.ErrorList);
            System.assertEquals(1, controller.ErrorList.size());
            Test.stopTest();
        }
    }


    @isTest static void testNoCampaignsSelected(){
        User user = TestingUtils.createStandardUser();
        System.runAs(user){
            TestingUtils.createApiCustomSettings(user);
            //test passing in list of campaign
            Campaign campaign = new Campaign(Name = 'new Campaign');
            Campaign campaign2 = new Campaign(Name = 'new Campaign2');
            Campaign campaign3 = new Campaign(Name = 'new Campaign3');
            insert campaign; 
            insert campaign2;
            insert campaign3;
            List<Campaign> campaignList = new List<Campaign>{campaign, campaign2, campaign3};

            //add members? not necessary
            Test.startTest();
            Test.setCurrentPage(Page.CampaignSendSurvey);
            //DON't set selected 
            ApexPages.StandardSetController standardSetController = new ApexPages.StandardSetController(campaignList);
            SendSurveyButtonController controller = new SendSurveyButtonController(standardSetController);
            controller.createPanelFromCampaignList();
            System.assertEquals(1, controller.ErrorList.size());
            System.assertEquals('No campaigns selected.', controller.ErrorList[0]);
            Test.stopTest();
        }
    }


    @isTest static void testCampaignListRecipientsNoEmail(){
        User user = TestingUtils.createStandardUser();
        System.runAs(user){
            TestingUtils.createApiCustomSettings(user);
            //test passing in individual campaign
            Campaign campaign = new Campaign(Name = 'test campaign');
            insert campaign;
            //add memebers
            //Lead lead1 = new Lead(LastName ='lead1');
            //insert lead1;
            Contact contact1 = new Contact(LastName = 'contact1');
            insert contact1;

            CampaignMember cm1 = new CampaignMember(campaignId = campaign.Id, contactId = contact1.Id);
            //CampaignMember cm2 = new CampaignMember(LeadId = lead1.Id, campaignId = campaign.Id);

            List<CampaignMember> memberList = new List<CampaignMember>{cm1};  
            insert memberList;
            List<Campaign> campaignList = new List<Campaign>{campaign};
            Test.startTest();
            Test.setCurrentPage(Page.CampaignSendSurvey);
            ApexPages.StandardSetController standardSetController = new ApexPages.StandardSetController(campaignList);
            standardSetController.setSelected(campaignList);
            SendSurveyButtonController controller = new SendSurveyButtonController(standardSetController);
            Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
            controller.createPanelFromCampaignList();
            Test.stopTest();
            System.assertEquals(1, controller.recordsSkipped);
        }
    }

    @isTest static void testCampaignListLeadContactRecipients(){
        User user = TestingUtils.createStandardUser();
        System.runAs(user){
            TestingUtils.createApiCustomSettings(user);
            //test passing in individual campaign
            Campaign campaign = new Campaign(Name = 'test campaign');
            insert campaign;
            //add memebers
            Lead lead1 = new Lead(LastName ='lead1', Company='TestCo', Email='test1@test.com');
            insert lead1;
            Contact contact1 = new Contact(LastName = 'contact1', Email='test1@test.com');
            insert contact1;
            Lead lead2 = new Lead(LastName ='lead2', Company='TestCo', Email='test1@test.com', HasOptedOutOfEmail = true);
            insert lead2;
            Contact contact2 = new Contact(LastName = 'contact2', Email='test1@test.com', HasOptedOutOfEmail = true);
            insert contact2;

            CampaignMember cm1 = new CampaignMember(campaignId = campaign.Id, contactId = contact1.Id);
            CampaignMember cm2 = new CampaignMember(LeadId = lead1.Id, campaignId = campaign.Id);
            CampaignMember cm3 = new CampaignMember(campaignId = campaign.Id, contactId = contact2.Id);
            CampaignMember cm4 = new CampaignMember(LeadId = lead2.Id, campaignId = campaign.Id);

            List<CampaignMember> memberList = new List<CampaignMember>{cm1,cm2,cm3,cm4};  
            insert memberList;
            List<Campaign> campaignList = new List<Campaign>{campaign};
            Test.startTest();
            Test.setCurrentPage(Page.CampaignSendSurvey);
            ApexPages.StandardSetController standardSetController = new ApexPages.StandardSetController(campaignList);
            standardSetController.setSelected(campaignList);
            SendSurveyButtonController controller = new SendSurveyButtonController(standardSetController);
            Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
            controller.createPanelFromCampaignList();
            Test.stopTest();
            System.assertEquals(2, controller.recordsSkipped);
        }
    }

    @isTest static void testSendNotification(){
        User user = TestingUtils.createStandardUser();
        System.runAs(user){
            TestingUtils.createApiCustomSettings(user);
            List<Campaign> campaignList = new List<Campaign>();
            //pass in list of campaigns
            Test.startTest();
            Test.setCurrentPage(Page.CampaignListSendSurvey);
            ApexPages.StandardSetController setController = new ApexPages.StandardSetController(campaignList);
            SendSurveyButtonController controller = new SendSurveyButtonController(setController);

            PageReference pageRef = Page.SurveyMessage;
            System.assert(controller.sendNotification().getUrl().startsWith(Page.SurveyMessage.getUrl()));
            Test.stopTest();
        }
    }   

    @isTest static void testSuccessfulMockCall(){
        User user = TestingUtils.createStandardUser();
        System.runAs(user){
            TestingUtils.createApiCustomSettings(user);
            Contact contact1 = new Contact(LastName = 'testContact1', email = 'testcontact1@test.com');
            insert contact1;
            Contact contact2 = new Contact(LastName = 'testContact2', email = 'testcontact2@test.com');
            insert contact2;
            Contact contact3 = new Contact(LastName = 'testContact3', email = 'testcontact3@test.com');
            insert contact3;    
            //pass in list of contacts
            List<Contact> contactList = new List<Contact>{contact1, contact2, contact3};
            Test.startTest();
            Test.setCurrentPage(Page.ContactListSendSurvey);
            Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
            ApexPages.StandardSetController setController = new ApexPages.StandardSetController(contactList);
            SendSurveyButtonController controller = new SendSurveyButtonController(setController);
            DateTime tempDateTime = DateTime.now();
            controller.createPanelFromContactList();
            System.assertEquals(0, controller.recordsSkipped);
            //Possible race condition is test is slow running
            //trim time of - is awlays a few seconds difference
//          System.assertEquals('Contact List '+ tempDateTime, controller.panelName);
            Test.stopTest();
        }
    }

    //test survey with status = Edit Survey
    @isTest static void testEditSurveyStandard(){
        User user = TestingUtils.createStandardUser();
        System.runAs(user){
            TestingUtils.createApiCustomSettings(user);
            //create and submit a survey record
            Survey__c survey = new Survey__c();
            //set status to panel created
            survey.Status__c = 'Edit Survey';
            insert survey;
            Test.setCurrentPage(Page.SelectSurvey);
            ApexPages.currentPage().getParameters().put('surveyid', survey.Id);

            SendSurveyButtonController controller = new SendSurveyButtonController(); 
            controller.init();
            System.assertEquals(survey.Id, controller.survey.Id);
            PageReference pageRef = controller.editSurvey();
            System.assert(pageRef == null);
        }
    }

    //test survey with status = Edit Survey
    @isTest static void testEditSurveyAdmin(){
        User user = TestingUtils.createAdminUserWithAdminPermSet();
        System.runAs(user){
            TestingUtils.createApiCustomSettings(user);
            //create and submit a survey record
            Survey__c survey = new Survey__c();
            //set status to panel created
            survey.Status__c = 'Edit Survey';
            insert survey;
            Test.setCurrentPage(Page.SelectSurvey);
            ApexPages.currentPage().getParameters().put('surveyid', survey.Id);

            SendSurveyButtonController controller = new SendSurveyButtonController(); 
            controller.init();
            System.assertEquals(survey.Id, controller.survey.Id);
            PageReference pageRef = controller.editSurvey();
            System.assertEquals(true, controller.showEditSurveyCanvas);
        }
    }

    //test survey with status = Edit Response Mappings
    @isTest static void testEditResponseMappings(){
        User user = TestingUtils.createStandardUser();
        System.runAs(user){
            TestingUtils.createApiCustomSettings(user);
            //create and submit a survey record
            Survey__c survey = new Survey__c();
            //set status to panel created
            survey.Status__c = 'Edit Response Mappings';
            insert survey;
            Test.setCurrentPage(Page.SelectSurvey);
            ApexPages.currentPage().getParameters().put('surveyid', survey.Id);

            SendSurveyButtonController controller = new SendSurveyButtonController(); 
            controller.init();
            System.assertEquals(survey.Id, controller.survey.Id);
            PageReference pageRef = controller.editResponseMapping();

        }
    }

    // test coming into page with url, not from list
    @isTest static void testSelectSurvey(){
        User user = TestingUtils.createStandardUser();
        System.runAs(user){
            TestingUtils.createApiCustomSettings(user);
            //create and submit a survey record
            Survey__c survey = new Survey__c();
            //set status to panel created
            survey.Status__c = 'Panel Created';
            //set the panel id for it
            survey.Panel_ID__c = '989898';
            insert survey;
            Test.setCurrentPage(Page.SelectSurvey);
            ApexPages.currentPage().getParameters().put('surveyid', survey.Id);

            SendSurveyButtonController controller = new SendSurveyButtonController(); 
            controller.init();
            System.assertEquals(survey.Id, controller.survey.Id);
        }
    }

    @isTest static void testInvalidSelectSurvey(){
        User user = TestingUtils.createStandardUser();
        System.runAs(user){
            TestingUtils.createApiCustomSettings(user);
            //tests the invalid conditions when entering the page 
            Survey__c survey = new Survey__c();
            //set the survey to something other that 'Panel Created' 
            survey.Status__c = 'Message';
            insert survey;
            Test.setCurrentPage(Page.SelectSurvey);
            ApexPages.currentPage().getParameters().put('surveyid', survey.Id);
            SendSurveyButtonController controller = new SendSurveyButtonController(); 
            controller.init();
            //pass in valid id, but not for an actual record
            ApexPages.currentPage().getParameters().put('surveyid', 'a055000000bBbQMAA0');
            controller = new SendSurveyButtonController(); 
            controller.init();
            System.assertEquals('No survey found with the supplied id.',controller.ErrorList[0]);
        }
    }

    @isTest static void testQueryAllSurveys(){
        //doesn't cover all lines, but if you create user and api settings in order to test other lines in the method, the call to queryAll causes uncommited work error for calling out after dml 
        SendSurveyButtonController controller = new SendSurveyButtonController();
        Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
        PageReference pageRef = controller.queryAllSurveys();
    }

    @isTest static void testMisc(){
        User user = TestingUtils.createStandardUser();
        System.runAs(user){
            TestingUtils.createApiCustomSettings(user);
            SendSurveyButtonController controller = new SendSurveyButtonController(); 
            SendSurveyButtonController controllerThis = controller.getPageCont();       
            controller.createNewSurvey = true;
            controller.requestParamMap = new map<String, String>();
            controller.requestParamJSON = 'eeee';
            List<SurveyResultWrapper.Surveys> surveylist = controller.surveys;
             Campaign campaign = new Campaign(Name = 'test campaign');//TODO add details
            insert campaign;
            //add memebers
            Lead lead1 = new Lead(LastName ='lead1', Company = 'test');
            insert lead1;
            Contact contact1 = new Contact(LastName = 'contact1');
            insert contact1;

            CampaignMember cm1 = new CampaignMember(campaignId = campaign.Id, ContactId = contact1.Id);
            CampaignMember cm2 = new CampaignMember(LeadId = lead1.Id, campaignId = campaign.Id);
            insert cm1;
            insert cm2;
            List<Contact> contactList = controller.queryContacts(campaign.Id);
            System.assertEquals(1, contactList.size());
            List<Lead> leadList = controller.queryLeads(campaign.Id);
            System.assertEquals(1, leadList.size());
            Integer count =  controller.getPanelMemberSkippedCount(new List<Campaign>{campaign});
            Integer skippedCount =  controller.getPanelMemberCount(new List<Campaign>{campaign});
            System.assertEquals(2, count);
            System.assertEquals(2, skippedCount);
        }
    }

}