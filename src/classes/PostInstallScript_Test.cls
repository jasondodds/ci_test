@isTest
private class PostInstallScript_Test
{
    @isTest
    static void itShould_CreateQuickStartCustomSettingsFromInitialInstall()
    {
        // Given
        PostInstallScript postinstall = new PostInstallScript();
        // When
        Test.testInstall(postinstall, null);
        // Then
        List<Quick_Start_Survey__c> quickStartGuides = [SELECT Name__c, Static_Resource_Location__c, Preview_Location__c FROM Quick_Start_Survey__c WHERE Static_Resource_Location__c != null];
        System.debug(quickStartGuides);
        System.assertEquals(quickStartGuides.size(),3,'There should be 3 quick start guides created for a new install, but there were '+quickStartGuides.size());
        Quick_Start_Survey__c testSurvey = quickStartGuides.get(0);
        System.assert(testSurvey.Static_Resource_Location__c != null, 'There should be a value in the Static Resource Location');
        System.assert(testSurvey.Preview_Location__c != null, 'There should be a value in the Preview Location');
        System.debug('*** '+testSurvey.Static_Resource_Location__c + ' | ' + testSurvey.Preview_Location__c);
        Qualtrics_Preferences__c qualtricsSetting = Qualtrics_Preferences__c.getInstance('Default');
        System.assert(qualtricsSetting.Allow_Subject_Override__c);
    }

    @isTest
    static void itShould_UpdateCustomSettingValuesFromUpdate()
    {
        TestingUtils.createOptOutCustomSettings();
        // Given
        PostInstallScript postinstall = new PostInstallScript();
        // When
        Test.testInstall(postinstall, new Version(1,1));
        // Then
        Map<String,Qualtrics_Email_Opt_out__c> curOptouts = Qualtrics_Email_Opt_out__c.getAll();
        System.debug(curOptouts);
        System.assertEquals(1, curOptouts.size());
        System.assertEquals('Contact', curOptouts.values()[0].SObject_Name__c);
        System.assertEquals('DoNotCall', curOptouts.values()[0].Field_Name__c);
        System.assertEquals(Utils.generateBase64UniqueString('Contact|DoNotCall'), curOptouts.values()[0].Name);
    }
}