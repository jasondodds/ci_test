@isTest
private class UserSetupControllerTest {
        
    @isTest static void test_TokenBooleansGitHub() {
        TestFactory.factoryUserDefinition(true);
        String orgResp = '[{"login": "github","id": 1,"url": "https://api.github.com/orgs/github","avatar_url": "https://github.com/images/error/octocat_happy.gif","description": "A great organization"}]';
        Test.setMock(HttpCalloutMock.class, new GithubCalloutMock(orgResp)); 

        Test.startTest();
        UserSetupController uc = new UserSetupController();
        System.assert(uc.githubTokenPresent == true, 'The GitHub token should be populated');
        Test.stopTest();
    }
    @isTest static void test_TokenBooleansCI() {
        TestFactory.factoryUserDefinition(true);
        Test.setMock(HttpCalloutMock.class, new CircleCICalloutMock('{"basic_email_prefs" : "smart","login" : "kcshafer"}'));
        
        Test.startTest();
        UserSetupController uc = new UserSetupController();
        System.assert(uc.ciTokenPresent == true, 'The CI token should be populated');
        Test.stopTest();
    }
    
    public static testMethod void save_ci_token_valid_test() {
        Test.setMock(HttpCalloutMock.class, new CircleCICalloutMock('{"basic_email_prefs" : "smart","login" : "kcshafer"}'));
        
        test.startTest();
            UserSetupController usc = new UserSetupController();
            usc.ciToken = '123';
            PageReference ref = usc.saveCIToken();

            UserDefinition__c ud = UserDefinition__c.getInstance(UserInfo.getUserId());

            system.assertEquals(ud.CI_Token__c, '123');

        test.stopTest();
    }

    public static testMethod void save_ci_token_invalid_test() {
        Test.setMock(HttpCalloutMock.class, new CircleCICalloutMock('{"message" : "Invalid token"}'));
        
        test.startTest();
            UserSetupController usc = new UserSetupController();
            usc.ciToken = '123';
            PageReference ref = usc.saveCIToken();

            UserDefinition__c ud = UserDefinition__c.getInstance(UserInfo.getUserId());

            system.assertEquals(ud.CI_Token__c, null);

        test.stopTest();
    }

    public static testMethod void github_token_present_valid_test() {
        String orgResp = '[{"login": "github","id": 1,"url": "https://api.github.com/orgs/github","avatar_url": "https://github.com/images/error/octocat_happy.gif","description": "A great organization"}]';
        Test.setMock(HttpCalloutMock.class, new GithubCalloutMock(orgResp));    
        TestFactory.factoryUserDefinition(true);

        test.startTest();
            UserSetupController usc = new UserSetupController();
            system.assertEquals(usc.githubTokenPresent, true);
        test.stopTest();
    }

    public static testMethod void github_token_present_invalid_test() {
        String orgResp = '[]';
        Test.setMock(HttpCalloutMock.class, new GithubCalloutMock(orgResp));    

        TestFactory.factoryUserDefinition(true);

        test.startTest();
            UserSetupController usc = new UserSetupController();
            system.assertEquals(usc.githubTokenPresent, false);
        test.stopTest();
    }

    public static testMethod void circleci_token_present_valid_test() {
        Test.setMock(HttpCalloutMock.class, new CircleCICalloutMock('{"basic_email_prefs" : "smart","login" : "kcshafer"}'));
        TestFactory.factoryUserDefinition(true);

        test.startTest();
            UserSetupController usc = new UserSetupController();
            system.assertEquals(usc.ciTokenPresent, true);
        test.stopTest();
    }

    public static testMethod void circleci_token_present_invalid_test() {
        Test.setMock(HttpCalloutMock.class, new CircleCICalloutMock('{"message" : "Invalid token"}'));
        TestFactory.factoryUserDefinition(true);

        test.startTest();
            UserSetupController usc = new UserSetupController();
            system.assertEquals(usc.ciTokenPresent, false);
        test.stopTest();
    }
}