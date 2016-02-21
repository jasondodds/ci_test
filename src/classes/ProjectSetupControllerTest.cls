@isTest
private class ProjectSetupControllerTest {
    public static testMethod void test_githubTokenPresent() {
        TestFactory.factoryUserDefinition(true);
        ProjectDefinition__c projectDefinition = TestFactory.factoryProjectDefinition(true);
        String orgResp = '[{"login": "github","id": 1,"url": "https://api.github.com/orgs/github","avatar_url": "https://github.com/images/error/octocat_happy.gif","description": "A great organization"}]';
        Test.setMock(HttpCalloutMock.class, new GithubCalloutMock(orgResp)); 

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(projectDefinition);
        ProjectSetupController psc = new ProjectSetupController(stdCtrl);
        System.assert(psc.githubTokenPresent == true, 'The GitHub token should be populated');
        Test.stopTest();
    }

    public static testMethod void test_ciTokenPresent() {
        TestFactory.factoryUserDefinition(true);
        ProjectDefinition__c projectDefinition = TestFactory.factoryProjectDefinition(true);
        Test.setMock(HttpCalloutMock.class, new CircleCICalloutMock('{"basic_email_prefs" : "smart","login" : "kcshafer"}'));

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(projectDefinition);
        ProjectSetupController psc = new ProjectSetupController(stdCtrl);
        System.assert(psc.ciTokenPresent == true, 'The CI token should be populated');
        Test.stopTest();
    }

    public static testMethod void test_routeToUserSetup() {
        test.startTest();
            ProjectDefinition__c projectDefinition = TestFactory.factoryProjectDefinition(true);

            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(projectDefinition);
            ProjectSetupController psc = new ProjectSetupController(stdCtrl);
        
            PageReference pr = psc.routeToUserSetup();
            system.assertEquals(pr.getUrl(), '/apex/UserSetup');
        test.stopTest();
    }

    public static testMethod void test_checkRouteToUserSetup() {
        test.startTest();
            ProjectDefinition__c projectDefinition = TestFactory.factoryProjectDefinition(true);

            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(projectDefinition);
            ProjectSetupController psc = new ProjectSetupController(stdCtrl);
        
            PageReference pr = psc.checkRouteToUserSetup();
            system.assertEquals(pr.getUrl(), '/apex/UserSetup');
        test.stopTest();
    }
}