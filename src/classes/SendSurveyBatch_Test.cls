@isTest
private class SendSurveyBatch_Test {
	
    @isTest static void testSendSurveyBatch(){
        User user = TestingUtils.createStandardUser();
        System.runAs(user){
            TestingUtils.createApiCustomSettings(user);
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
            Survey__c survey = new Survey__c(Panel_Id__c='testPanel');
            insert survey;

            Campaign campaign = new Campaign(Name = 'test campaign');
            insert campaign;

            Survey_Campaign__c surveyCampaign = new Survey_Campaign__c(
            										Campaign__c=campaign.Id, 
            										Survey__c=survey.Id);
            insert surveyCampaign;

            Contact contact1 = new Contact(LastName = 'contact1', Email='contact1@test.com');
            insert contact1;

            Lead lead1 = new Lead(LastName = 'lead1', company='testCompany', Email='lead1@test.com');
            insert lead1;

            CampaignMember cm1 = new CampaignMember(campaignId = campaign.Id, contactId = contact1.Id);
            CampaignMember cm2 = new CampaignMember(LeadId = lead1.Id, campaignId = campaign.Id);

            List<CampaignMember> memberList = new List<CampaignMember>{cm1,cm2};  
            insert memberList;

            List<Campaign> campaignList = new List<Campaign>{campaign};
            Test.startTest();
            	Id batchId = SendSurveyBatch.submitBatchJob(survey.Id, 'testPanel');
            	system.assert(batchId != null);
            Test.stopTest();
        }
    }

    @isTest static void testSendSurveyBatchAdmin(){
        User user = TestingUtils.createAdminUserWithAdminPermSet();
        System.runAs(user){
            TestingUtils.createApiCustomSettings(user);
            Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
            Survey__c survey = new Survey__c(Panel_Id__c='testPanel');
            insert survey;

            Campaign campaign = new Campaign(Name = 'test campaign');
            insert campaign;

            Survey_Campaign__c surveyCampaign = new Survey_Campaign__c(
                                                    Campaign__c=campaign.Id, 
                                                    Survey__c=survey.Id);
            insert surveyCampaign;

            Contact contact1 = new Contact(LastName = 'contact1', Email='contact1@test.com');
            insert contact1;

            Lead lead1 = new Lead(LastName = 'lead1', company='testCompany', Email='lead1@test.com', HasOptedOutOfEmail = true);
            insert lead1;

            CampaignMember cm1 = new CampaignMember(campaignId = campaign.Id, contactId = contact1.Id);
            CampaignMember cm2 = new CampaignMember(LeadId = lead1.Id, campaignId = campaign.Id);

            List<CampaignMember> memberList = new List<CampaignMember>{cm1,cm2};  
            insert memberList;

            List<Campaign> campaignList = new List<Campaign>{campaign};
            Test.startTest();
                Id batchId = SendSurveyBatch.submitBatchJob(survey.Id, 'testPanel');
                system.assert(batchId != null);
            Test.stopTest();
        }
    }
	
}