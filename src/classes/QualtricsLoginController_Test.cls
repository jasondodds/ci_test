@isTest
private class QualtricsLoginController_Test {
	
	@isTest static void testInit() {
		// Implement test code
		PageReference pageRef = Page.QualtricsLogin;
		Test.setCurrentPage(pageRef);
		User user = TestingUtils.createTestUser();
		//if we test save, we need the user to NOT have settings yet
		//TestingUtils.createApiCustomSettings(user);
	    System.runAs(user) {
	    	Test.startTest();
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
	    	QualtricsLoginController controller = new QualtricsLoginController();
	    	//this page needs an owning page of type SendSurveyButtonController
	    	SendSurveyButtonController owner = new SendSurveyButtonController();
	    	controller.owningPage = owner;
			controller.username = 'laura@codescience.com';
			controller.password = 'test';
			controller.save();
			Test.stopTest();
	    }
	}


	@isTest static void testPositiveToken() {
		// Implement test code
		PageReference pageRef = Page.QualtricsLogin;
		Test.setCurrentPage(pageRef);
		User user = TestingUtils.createTestUser();
		//if we test save, we need the user to NOT have settings yet
		//TestingUtils.createApiCustomSettings(user);
	    System.runAs(user) {
	    	Test.startTest();
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
	    	QualtricsLoginController controller = new QualtricsLoginController();
	    	//this page needs an owning page of type SendSurveyButtonController
	    	SendSurveyButtonController owner = new SendSurveyButtonController();
	    	controller.owningPage = owner;
			controller.username = 'laura@codescience.com';
			controller.token = '098jfqp89qp2;lqf98hw45pqhfqfjqosifjp98hw';
			controller.save();
			Test.stopTest();
	    }
	}

	@isTest static void testNegativeTokenMap() {
		// Implement test code
		PageReference pageRef = Page.QualtricsLogin;
		Test.setCurrentPage(pageRef);
		User user = TestingUtils.createTestUser();
		//if we test save, we need the user to NOT have settings yet
		//TestingUtils.createApiCustomSettings(user);
	    System.runAs(user) {
	    	Test.startTest();
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockNegativeTest());
	    	QualtricsLoginController controller = new QualtricsLoginController();
	    	//this page needs an owning page of type SendSurveyButtonController
	    	SendSurveyButtonController owner = new SendSurveyButtonController();
	    	controller.owningPage = owner;
			controller.username = 'laura@codescience.com';
			controller.password = 'test';
			controller.save();
			Test.stopTest();
	    }
	}

	@isTest static void testNegativeUserId() {
		// Implement test code
		PageReference pageRef = Page.QualtricsLogin;
		Test.setCurrentPage(pageRef);
		User user = TestingUtils.createTestUser();
		//if we test save, we need the user to NOT have settings yet
		//TestingUtils.createApiCustomSettings(user);
	    System.runAs(user) {
	    	Test.startTest();
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockNegativeTest());
	    	QualtricsLoginController controller = new QualtricsLoginController();
	    	//this page needs an owning page of type QualtricsSettingsController
	    	QualtricsSettingsController owner = new QualtricsSettingsController();
	    	controller.qPage = owner;
			controller.username = 'laura@codescience.com';
			controller.password = 'test';
			controller.save();
			Test.stopTest();
	    }
	}

}