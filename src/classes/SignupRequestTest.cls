@isTest
private class SignupRequestTest {
     
    public static testMethod void test_create_signup_request() {
        ////////////////////////////////////////////
        //// test successful creation of signup ////
        //// request via env insertion /////////////
        ////////////////////////////////////////////
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

        Environment__c masterEnv = new Environment__c(Name='Production', Production__c=true, CI_Project_Definition__c=pd.Id, Branch_Name__c='master');
        insert masterEnv;

        Environment__c env = new Environment__c(Name='KCTest', Branch_Name__c='kctest', CI_Project_Definition__c=pd.Id, Parent_Environment__c=masterEnv.Id, Create_Users__c=true);

        Team_Member__c tm = TestFactory.factoryTeamMember(true, pd, c, 'KC', 'kcshafer');

        test.startTest();
            insert env;

            //assert that the signuprequest was created
            List<SignupRequest> sr = [SELECT Id FROM SignupRequest WHERE Environment__c=:env.Id];
            //system.assertEquals(1, sr.size());

            //assert that a scheduled job was created
            List<CronJobDetail> cjd = [SELECT Id FROM CronJobDetail];
            //system.assertEquals(1, cjd.size());

            Id srId = sr.isEmpty() ? null : sr[0].Id;
            SignupRequestService.storeRefreshToken(srId);

            // TODO: Test the following
            //SignupRequestService.scheduleJob(srId, 'test');

        test.stopTest();

    }

    public static testmethod void test_login() {

        Test.startTest();

        // TODO: Setup mocks
        //SignupRequestService.login('testUsername', 'testPasswd', 'testConsumerKey', 'testConsumerSecret');

        Test.stopTest();
    }

    public static testmethod void test_exchangeRefreshToken() {

        Test.startTest();

        // TODO: Setup mocks
        SignupRequestService.exchangeRefreshToken('test');

        Test.stopTest();
    }

    public static testmethod void test_signup_request_wrapper() {

        // Test the non-test scenarios
        SignupRequestService.bypassSRInsertForTest = false;
        SignupRequestWrapper srWrapper = new SignupRequestWrapper(new SignupRequest(
            Create_Users__c = true
        ));

        Test.startTest();

        system.assertEquals(srWrapper.getField('Environment', null), null);
        system.assertEquals(srWrapper.getField('Create_Users', null), true);
        system.assertEquals(srWrapper.getField('Id', null), null);

        Test.stopTest();
    }
}