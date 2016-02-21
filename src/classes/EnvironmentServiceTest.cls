@isTest
private class EnvironmentServiceTest {
	
	/*@isTest static void expect_production_branch_to_be_master() {
		User testUser = TestFactory.factoryUser(true, 'System Administrator');
		System.runAs(testUser){
			TestFactory.factoryOauthSetting(true);
			TestFactory.factoryUserDefinition(true);
			Test.startTest();
			Environment__c env = TestFactory.factoryEnvironment(true, null, null, 'Production', 'testnamepsace', true, true);
			Test.stopTest();
			env = [SELECT Branch_Name__c FROM Environment__c WHERE Id = :env.Id];
			System.assert(env.Branch_Name__c == 'master', 'The Production environment should have a branch name of "Master", but instead it was '+env.Branch_Name__c);
		}
	}
	
	@isTest static void expect_custom_branch_to_be_resolved_correctly() {
		User testUser = TestFactory.factoryUser(true, 'System Administrator');
		System.runAs(testUser){
			TestFactory.factoryOauthSetting(true);
			TestFactory.factoryUserDefinition(true);
			Test.startTest();
			Environment__c env = TestFactory.factoryEnvironment(true, null, null, 'Sp3c!@l chars', 'testnamepsace', false, true);
			Test.stopTest();
			env = [SELECT Branch_Name__c FROM Environment__c WHERE Id = :env.Id];
			System.assert(env.Branch_Name__c == 'Sp3c__l_chars', 'The Production environment should have a branch name of "Sp3c__l_chars", but instead it was '+env.Branch_Name__c);
		}
	}*/
}