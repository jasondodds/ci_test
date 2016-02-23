@isTest
private class SurveyMessageController_Test {

	@isTest static void testError(){
		User user = TestingUtils.createTestUser();
	    System.runAs(user) {
			TestingUtils.createApiCustomSettings(user);
			PageReference pageRef = Page.SurveyMessage;
			Test.setCurrentPage(pageRef);
	  		SurveyMessageController controller = new SurveyMessageController();
	  		Test.startTest();
	 		Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
	  		controller.init();
	  		System.assertEquals(1, controller.ErrorList.size());
	  		System.assertEquals('Missing or invalid survey id.', controller.ErrorList[0]);

	        ApexPages.currentPage().getParameters().put('surveyid', '9893493');
			controller = new SurveyMessageController();
			controller.init();
	  		System.assertEquals(1, controller.ErrorList.size());
	  		System.assertEquals('Missing or invalid survey id.', controller.ErrorList[0]);		

	        ApexPages.currentPage().getParameters().put('surveyid', 'a055000000bBbQMAA0');
			controller = new SurveyMessageController();
			controller.init();
	  		System.assertEquals(1, controller.ErrorList.size());
	  		System.assertEquals('No Survey found for the id supplied.', controller.ErrorList[0]);
			Test.stopTest();
		}
	}
	
	@isTest static void testInit() {
		User user = TestingUtils.createTestUser();
	    System.runAs(user) {
			TestingUtils.createApiCustomSettings(user);
			Survey__c survey = new Survey__c();
			survey.Survey_ID__c = 'test';
			survey.Panel_ID__c = 'test';
			survey.Message_ID__c = 'test';
			insert survey;
			//create panel or pass fake id
			//create 
			
			//currently page reads ids off url param 
			PageReference pageRef = Page.SurveyMessage;
			Test.setCurrentPage(pageRef);
	  		ApexPages.currentPage().getParameters().put('surveyid', survey.Id);
	  		System.assertEquals(survey.Id,ApexPages.currentPage().getParameters().get('surveyid'));		
	  		SurveyMessageController controller = new SurveyMessageController();
	  		Test.startTest();
	 		Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
	  		controller.init();
	  		System.assertEquals(survey.Id, controller.SurveyId);
	  		//set up some values
			controller.MessageName = 'message name';
	  		controller.MessageContent = 'message content';
	  		controller.MessageContentHolder = 'message content';
	  		controller.customMessageName = 'test message';
	  		controller.MessageSubject = 'message subject';
	  		controller.messageChosen = controller.messages[0].Id;
	  		controller.FromEmail = 'test@test.com';
	  		controller.SentFromAddress = 'test@test.com';
	  		controller.FromName = 'test person';
	  		controller.SendDate = '2015-04-14 12:30:00';
	  		controller.survey.Panel_Type__c = 'Campaign';
	  		//save has callout so can't test it - creating 1 for testing in init
	  		System.assertEquals(1, controller.messages.size());
	  		System.assertEquals('testId', controller.messages[0].Id);
	  		controller.save();
	  	}
	  	test.stopTest();
	}

	@isTest static void testSaveValidationForCoverage() {
		User user = TestingUtils.createTestUser();
	    System.runAs(user) {
			TestingUtils.createApiCustomSettings(user);
			Survey__c survey = new Survey__c();
			survey.Survey_ID__c = 'test';
			survey.Panel_ID__c = 'test';
			survey.Message_ID__c = 'test';
			insert survey;
			//create panel or pass fake id
			//create 
			
			//currently page reads ids off url param 
			PageReference pageRef = Page.SurveyMessage;
			Test.setCurrentPage(pageRef);
	  		ApexPages.currentPage().getParameters().put('surveyid', survey.Id);
	  		System.assertEquals(survey.Id,ApexPages.currentPage().getParameters().get('surveyid'));		
	  		SurveyMessageController controller = new SurveyMessageController();
	  		Test.startTest();
	 		Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
	  		controller.init();
	  		System.assertEquals(survey.Id, controller.SurveyId);
	  		//set up no values - for validation coverage
	  		controller.FromEmail = '';
	  		controller.SentFromAddress = '';
	  		controller.FromName = '';
	  		controller.SendDate = '';
	  		controller.survey.Panel_ID__c = '';
	  		controller.survey.Survey_ID__c = '';
	  		//save has callout so can't test it - creating 1 for testing in init
	  		System.assertEquals(1, controller.messages.size());
	  		System.assertEquals('testId', controller.messages[0].Id);
	  		controller.save();
	  	}
	  	Test.stopTest();
	}

	@isTest static void testMessageOptionsUser() {
		User user = TestingUtils.createTestUser();
	    System.runAs(user) {
			TestingUtils.createApiCustomSettings(user);
	 		Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
			Survey__c survey = new Survey__c();
			survey.Survey_ID__c = 'test';
			survey.Panel_ID__c = 'test';
			survey.Message_ID__c = 'test';
			insert survey;
			//create panel or pass fake id
			//create 
			
			//currently page reads ids off url param 
			PageReference pageRef = Page.SurveyMessage;
			Test.setCurrentPage(pageRef);
	  		ApexPages.currentPage().getParameters().put('surveyid', survey.Id);
	  		System.assertEquals(survey.Id,ApexPages.currentPage().getParameters().get('surveyid'));		
	  		SurveyMessageController controller = new SurveyMessageController();
	  		Test.startTest();
	  		controller.init();
	  		List<SelectOption> testOptions = controller.getMessageOptions();
	  		system.assertEquals('Test Label',testOptions[0].getLabel());
	  		Test.stopTest();
	  	}
	}

	@isTest static void testMessageOptionsAdmin() {
		User user = TestingUtils.createAdminUserWithAdminPermSet();
	    System.runAs(user) {
			TestingUtils.createApiCustomSettings(user);
			Survey__c survey = new Survey__c();
			survey.Survey_ID__c = 'test';
			survey.Panel_ID__c = 'test';
			survey.Message_ID__c = 'test';
			insert survey;
			//create panel or pass fake id
			//create 
			
			//currently page reads ids off url param 
			PageReference pageRef = Page.SurveyMessage;
			Test.setCurrentPage(pageRef);
	  		ApexPages.currentPage().getParameters().put('surveyid', survey.Id);
	  		System.assertEquals(survey.Id,ApexPages.currentPage().getParameters().get('surveyid'));		
	  		SurveyMessageController controller = new SurveyMessageController();
	 		Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
	  		controller.init();
	  		Test.startTest();
	  		List<SelectOption> testOptions = controller.getMessageOptions();
	  		system.assertEquals('New Custom Message',testOptions[0].getLabel());
	  	}
  		Test.stopTest();
	}

	@isTest static void testRunningUserMessageSettings() {
		User user = TestingUtils.createTestUser();
	    System.runAs(user) {
			TestingUtils.createApiCustomSettings(user);
			Survey__c survey = new Survey__c();
			survey.Survey_ID__c = 'test';
			survey.Panel_ID__c = 'test';
			survey.Message_ID__c = 'test';
			insert survey;
			//create panel or pass fake id
			//create 
			
			//currently page reads ids off url param 
			PageReference pageRef = Page.SurveyMessage;
			Test.setCurrentPage(pageRef);
	  		ApexPages.currentPage().getParameters().put('surveyid', survey.Id);
	  		System.assertEquals(survey.Id,ApexPages.currentPage().getParameters().get('surveyid'));		
	  		SurveyMessageController controller = new SurveyMessageController();
	  		Test.startTest();
	 		Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
	  		controller.init();
	  		system.assertEquals(user.Email,controller.FromEmail);
	  	}
	  	Test.stopTest();
	}

	@isTest static void testCustomMessageSettings() {
		User user = TestingUtils.createTestUser();
	    System.runAs(user) {
			TestingUtils.createApiCustomSettings(user);
			
			Qualtrics_Preferences__c prefs = Qualtrics_Preferences__c.getInstance('Default');
			prefs.Default_Message_From_Type__c = QualtricsConstants.MessageFromType.Custom.Name();
			prefs.Default_From_Name__c = 'Tester Testingson';
			//prefs.Default_From_Email__c = 'Tester.Testingson@test.com';
			prefs.Default_Reply_To_Email__c = 'Tester.Testingson@test.com';
			update prefs;

			Survey__c survey = new Survey__c();
			survey.Survey_ID__c = 'test';
			survey.Panel_ID__c = 'test';
			survey.Message_ID__c = 'test';
			insert survey;
			//create panel or pass fake id
			//create 
			
			//currently page reads ids off url param 
			PageReference pageRef = Page.SurveyMessage;
			Test.setCurrentPage(pageRef);
	  		ApexPages.currentPage().getParameters().put('surveyid', survey.Id);
	  		System.assertEquals(survey.Id,ApexPages.currentPage().getParameters().get('surveyid'));		
	  		SurveyMessageController controller = new SurveyMessageController();
	  		Test.startTest();
	 		Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
	  		controller.init();
	  		system.assertEquals('Tester.Testingson@test.com',controller.FromEmail);
	  	}
	  	Test.stopTest();
	}

	@isTest static void testRouteSurvey() {
		User user = TestingUtils.createAdminUserWithAdminPermSet();
	    System.runAs(user) {
			TestingUtils.createApiCustomSettings(user);
			Survey__c survey = new Survey__c();
			survey.Survey_ID__c = 'test';
			survey.Panel_ID__c = 'test';
			survey.Message_ID__c = 'test';
			insert survey;
			//create panel or pass fake id
			//create 
			
			//currently page reads ids off url param 
			PageReference pageRef = Page.SurveyMessage;
			Test.setCurrentPage(pageRef);
	  		ApexPages.currentPage().getParameters().put('surveyid', survey.Id);
	  		System.assertEquals(survey.Id,ApexPages.currentPage().getParameters().get('surveyid'));		
	  		SurveyMessageController controller = new SurveyMessageController();
	  		Test.startTest();
	 		Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
	  		controller.init();
	  		controller.selectSurvey();
	  		survey = [Select Id, Status__c from Survey__c where Id = :survey.Id];
	  		system.assertEquals('Panel Created', survey.Status__c);
	  		controller.editSurvey();
	  		survey = [Select Id, Status__c from Survey__c where Id = :survey.Id];
	  		system.assertEquals('Edit Survey', survey.Status__c);
	  		controller.editResponseMapping();
	  		survey = [Select Id, Status__c from Survey__c where Id = :survey.Id];
	  		system.assertEquals('Edit Response Mappings', survey.Status__c);
	  		controller.routeSurvey('');
	  		system.assertEquals(1, controller.ErrorList.size());
	  	}
	  	Test.stopTest();
	}


	@testSetup static void setupCustomSettings() {
		Qualtrics_Preferences__c prefs = new Qualtrics_Preferences__c();
		prefs.Name = 'Default';
		prefs.Default_Message_From_Type__c = QualtricsConstants.MessageFromType.RunningUser.Name();
		insert prefs;
	}
}