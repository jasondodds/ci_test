@isTest
private class QualtricsSettingsController_Test {

	@isTest
	private static void TestQualtricsSettingsWithCustomSettingData() {
		Qualtrics_Preferences__c prefs = new Qualtrics_Preferences__c();
		prefs.Name = 'Default';
		prefs.Default_Message_From_Type__c = QualtricsConstants.MessageFromType.RunningUser.Name();
		insert prefs;
		Test.startTest();
			QualtricsSettingsController qsc = new QualtricsSettingsController();
			System.assertEquals(QualtricsConstants.MessageFromType.RunningUser.Name(), qsc.qualtricsSetting.Default_Message_From_Type__c);
		Test.stopTest();
	}

	@isTest
	private static void TestQualtricsSettingsWithOutCustomSettingData() {
		Test.startTest();
			QualtricsSettingsController qsc = new QualtricsSettingsController();
			qsc.qualtricsSetting.Default_Message_From_Type__c = QualtricsConstants.MessageFromType.Custom.Name();
			qsc.qualtricsSetting.Default_From_Name__c = 'Tester Testingson';
			//qsc.qualtricsSetting.Default_From_Email__c = 'test@test.com';
			qsc.qualtricsSetting.Default_Reply_To_Email__c = 'testingson@test.com';
			qsc.qualtricsSetting.Default_Subject__c = 'Test Subject';
			pageReference pr = qsc.savePrefs();
			System.assertEquals(null, pr);
			qsc.qualtricsSetting.Default_From_Name__c = 'Other Testingson';
			pr = qsc.cancelPrefs();
			System.assertEquals('Tester Testingson',qsc.qualtricsSetting.Default_From_Name__c);
		Test.stopTest();
	
		Qualtrics_Preferences__c prefs = Qualtrics_Preferences__c.getInstance('Default');
		System.assertEquals(QualtricsConstants.MessageFromType.Custom.Name(), prefs.Default_Message_From_Type__c);
		System.assertEquals('testingson@test.com',prefs.Default_Reply_To_Email__c);
	}

	@isTest
	private static void TestQualtricsOptOutSettings() {
		TestingUtils.createOptOutCustomSettings();
		Test.startTest();
			QualtricsSettingsController qsc = new QualtricsSettingsController();
			List<QualtricsSettingsController.qualtricsOptOutWrapper> testWrapper = qsc.qualtricsOptOuts.get('Contact');
			testWrapper[1].selected = true;
			pageReference pr = qsc.saveSettings();
			System.assertEquals(null, pr);
			testWrapper = qsc.qualtricsOptOuts.get('Contact');
			System.assert(testWrapper[1].selected);

			testWrapper = qsc.qualtricsOptOuts.get('Lead');
			testWrapper[1].selected = true;
			pr = qsc.cancelSettings();
			testWrapper = qsc.qualtricsOptOuts.get('Lead');
			System.assertEquals(false,testWrapper[1].selected);
		Test.stopTest();
	}

	@isTest
	private static void TestQualtricsSettingsOrgWideDefaultEmail() {
		integer owaCount = [select id, Address, DisplayName from OrgWideEmailAddress].size();
		Test.startTest();
			QualtricsSettingsController qsc = new QualtricsSettingsController();
			List<SelectOption> options = qsc.getOrgWideEmails();
			system.assertEquals(owaCount+1,options.size());
		Test.stopTest();
	}

	@isTest
	private static void TestQualtricsSettingsWithAPISettingData() {
		User user = TestingUtils.createTestUser();
		System.runAs(user) {
			TestingUtils.createApiCustomSettings(user);
			Test.startTest();
			QualtricsSettingsController qsc = new QualtricsSettingsController();
			QualtricsSettingsController testQSC = qsc.getPageCont();
			system.assert(qsc.hasCredentials);
			system.assertEquals(user.Username,qsc.qualtricsUserName);

			PageReference pr = qsc.disconnectQualtricsUser();
			pr = qsc.showConfirmDisconnect();
			system.assert(true, qsc.showDisconnectModal);
			pr = qsc.cancelDisconnect();
			system.assertEquals(false, qsc.showDisconnectModal);
			System.assert(qsc.getRequestParamJSON().contains('AuthOnly'));
			pr = qsc.hideAuthOnlyCanvas();
			Test.stopTest();

		}
	}

}