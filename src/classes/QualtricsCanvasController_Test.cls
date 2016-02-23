@isTest
private class QualtricsCanvasController_Test
{
	@isTest
	static void itShould_testPanelCreatedJump()
	{
		// Given
		User user = TestingUtils.createTestUser();
		TestingUtils.createApiCustomSettings(user);
  		
		// When
		System.runAs(user) {
			Survey__c survey = new Survey__c();
			survey.Survey_ID__c = 'test';
			survey.Panel_ID__c = 'test';
			survey.Message_ID__c = 'test';
			survey.Status__c = 'Panel Created';
			insert survey;

			Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(survey);
			QualtricsCanvasController controller = new QualtricsCanvasController(sc);
			String nextPage = controller.routeSurvey().getUrl();
			survey = [SELECT Id, Name, Survey_ID__c, Status__c FROM Survey__c WHERE Id = :sc.getId() LIMIT 1];
			//System.assertEquals('/apex/qualtrics__SelectSurvey?surveyid='+survey.Id, nextPage);
			System.assert(nextPage.contains('SelectSurvey?surveyid='+survey.Id));
			Test.stopTest();
		}
	}

	@isTest
	static void itShould_testAdminSurveyDetailJump()
	{
		// Given
		User user = TestingUtils.createAdminUserWithAdminPermSet();
  		
		// When
		System.runAs(user) {
			TestingUtils.createApiCustomSettings(user);
			Survey__c survey = new Survey__c();
			survey.Survey_ID__c = 'test';
			survey.Panel_ID__c = 'test';
			survey.Message_ID__c = 'test';
			survey.Status__c = 'Survey Detail';
			insert survey;

			Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(survey);
			QualtricsCanvasController controller = new QualtricsCanvasController(sc);
			PageReference nextPage = controller.routeSurvey();
			survey = [SELECT Id, Name, Survey_ID__c, Status__c FROM Survey__c WHERE Id = :sc.getId() LIMIT 1];
			//System.assertEquals('/apex/qualtrics__SelectSurvey?surveyid='+survey.Id, nextPage);
			System.assert(nextPage == null);
			Test.stopTest();
		}
	}

	@isTest
	static void itShould_testSendMessageJump()
	{
		// Given
		User user = TestingUtils.createTestUser();
		TestingUtils.createApiCustomSettings(user);
  		
		// When
		System.runAs(user) {
			Survey__c survey = new Survey__c();
			survey.Survey_ID__c = 'test';
			survey.Panel_ID__c = 'test';
			survey.Message_ID__c = 'test';
			survey.Status__c = 'Message';
			insert survey;

			Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(survey);
			QualtricsCanvasController controller = new QualtricsCanvasController(sc);
			String nextPage = controller.routeSurvey().getUrl();
			survey = [SELECT Id, Name, Survey_ID__c, Status__c FROM Survey__c WHERE Id = :sc.getId() LIMIT 1];
			//System.assertEquals('/apex/qualtrics__SurveyMessage?surveyid='+survey.Id, nextPage);
			System.assert(nextPage.contains('SurveyMessage?surveyid='+survey.Id));
			Test.stopTest();
		}
	}

	@isTest
	static void itShould_renderCanvas()
	{
		// Given
		User user = TestingUtils.createTestUser();
		TestingUtils.createApiCustomSettings(user);
  		
		// When
		System.runAs(user) {
			Survey__c survey = new Survey__c();
			survey.Survey_ID__c = 'test';
			survey.Panel_ID__c = 'test';
			survey.Message_ID__c = 'test';
			survey.Status__c = 'Message';
			insert survey;

			Test.startTest();
			ApexPages.StandardController sc = new ApexPages.StandardController(survey);
			QualtricsCanvasController controller = new QualtricsCanvasController(sc);
			controller.renderCanvas(survey.Id,null);
			Test.stopTest();
		}
	}
}