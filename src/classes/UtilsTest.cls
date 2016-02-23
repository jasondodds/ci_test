@isTest
private class UtilsTest {
	
	@isTest static void testPositive() {
		String id ='01I50000000GHja';
		System.assert(Utils.isValidId(id));
	}
	
	@isTest static void testNegative() {
		String id ='44542727';
		System.assert(!Utils.isValidId(id));
	}
	
	@isTest(SeeAllData=true) static void testUsersCustomSettings(){

		User user = TestingUtils.createTestUser();
		System.assertEquals(false, Utils.userHasQualtricsSettings(user.Id));
		TestingUtils.createApiCustomSettings(user);
		System.assertEquals(true, Utils.userHasQualtricsSettings(user.Id));

	}
	@isTest static void testSendDebugEmail(){
		Utils.sendDebugEmail(new String[] {'fake@example.com'},'string test');

	}

	@isTest static void testUserHasQualtricsAdminPermission() {
		User user = TestingUtils.createAdminUserWithAdminPermSet();
		System.runAs(user) {
			system.assert(Utils.userHasQualtricsAdminPermission());
		}
	}

	@isTest static void clearEmailOptOutSettingForMissingField() {
		Utils.clearEmailOptOutSettingForMissingField();
	}
}