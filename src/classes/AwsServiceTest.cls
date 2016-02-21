@isTest
private class AwsServiceTest {
	
        @isTest static void test_updateBuildProperties() {
		      String response = '{"content": {"name": "build.properties","path": "build/build.properties","sha": "yyy"}},"commit": {"sha": "xxx","url": "https://api.github.com/repos/jasondodds/ci_test/git/commits/xxx"}}';
		      Test.setMock(HttpCalloutMock.class, new AwsCalloutMock(response));

		      //TestFactory.factoryAwsSetting(true);
          ProjectDefinition__c projectDef = TestFactory.factoryProjectDefinition(true);

          Test.startTest();
          String testResponse = AwsService.updateBuildProperties(projectDef,null);
          System.assert(testResponse != null, 'The callout should run without an exception');
          Test.stopTest();

        }

        @isTest static void test_addCircleResources() {
          String response = '{"content": {"name": "build.properties","path": "build/build.properties","sha": "yyy"}},"commit": {"sha": "xxx","url": "https://api.github.com/repos/jasondodds/ci_test/git/commits/xxx"}}';
          Test.setMock(HttpCalloutMock.class, new AwsCalloutMock(response));

          //TestFactory.factoryAwsSetting(true);
          ProjectDefinition__c projectDef = TestFactory.factoryProjectDefinition(true);

          Test.startTest();
          String testResponse = AwsService.addCircleResources(projectDef);
          System.assert(testResponse != null, 'The callout should run without an exception');
          Test.stopTest();

        }

        public static testMethod void test_getErrorString() {
          String response = '{"errorMessage":"test message"}';
          String errorMessage = AwsService.getErrorString(response);
          system.assert(errorMessage == 'test message', 'The error message should be parsed, but it was: '+errorMessage);
        }
	
}