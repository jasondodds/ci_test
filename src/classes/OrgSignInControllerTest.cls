@isTest
private class OrgSignInControllerTest {
    public static testMethod void test_redirect() {
        String gcr = '{"ref": "refs/heads/featureA","sha": "aa218f56b14c9653891f9e74264a383fa43fefbd"}';
        String ggr = '{"ref": "refs/heads/featureA","url": "https://api.github.com/repos/octocat/Hello-World/git/refs/heads/featureA","object": {"type": "commit","sha": "aa218f56b14c9653891f9e74264a383fa43fefbd","url": "https://api.github.com/repos/octocat/Hello-World/git/commits/aa218f56b14c9653891f9e74264a383fa43fefbd"}}';
        String tr = '{"id":"https://login.salesforce.com/id/00Dx0000000BV7z/005x00000012Q9P","issued_at":"1278448832702","instance_url":"https://na1.salesforce.com","signature":"0CmxinZir53Yex7nE0TD+zMpvIWYGb/bdJh6XfOH6EQ=","access_token":"00Dx0000000BV7z!AR8AQAxo9UfVkh8AlV0Gomt9Czx9LjHnSSpwBMmbRcgKFmxOtvxjTrKW19ye6PE3Ds1eQz3z8jr3W7_VbWmEu4Q8TVGSTHxs","refresh_token":"12345"}';
        String cr = '{"test": "123"}';
        String qr = '{"totalSize": 1,"done": true,"records": [{"attributes": {"type": "Profile","url": "/services/data/v35.0/sobjects/Profile/00e610000014kQMAAY"},"Id": "00e610000014kQMAAY"}]}';
        String ir = '{"id" : "001D000000IqhSLIAZ","errors" : [ ],"success" : true}';

        Test.setMock(HttpCalloutMock.class, new SignupRequestMocks(tr,cr,gcr,ggr,qr,ir));
        TestFactory.factoryOauthSetting(true);
        TestFactory.factoryUserDefinition(true);

        Contact c = new Contact(FirstName='KC', LastName='Shafer', Email='kc@codescience.com');
        insert c;

        ProjectDefinition__c pd = TestFactory.factoryProjectDefinition(false);
        pd.Name = 'TestProject';
        insert pd;
        Environment__c masterEnv = new Environment__c(Name='Production', Production__c=true, CI_Project_Definition__c=pd.Id);
        insert masterEnv;

        Environment__c env = new Environment__c(Name='KCTest', Branch_Name__c='kctest', CI_Project_Definition__c=pd.Id, Parent_Environment__c=masterEnv.Id, Create_Users__c=true);   
        insert env;

        //SignupRequest request = [SELECT CreatedOrgId FROM SignupRequest WHERE Environment__c = :env.Id LIMIT 1];

        Environment_Refresh_Token__c ert = new Environment_Refresh_Token__c(Name='123', Refresh_Token__c='123');
        insert ert;

        ApexPages.StandardController sc = new ApexPages.standardController(env);
        OrgSignInController osc = new OrgSignInController(sc);
        osc.redirect();

    }
}