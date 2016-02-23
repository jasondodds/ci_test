@IsTest
private class QualtricsVocalizeController_Test {
	@IsTest
	static void testVocalizeController() {
		User user = TestingUtils.createTestUser();
		TestingUtils.createApiCustomSettings(user);
		System.runAs(user){
			Test.startTest();
			//Set API Mock
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
			//Constructor
			QualtricsVocalizeController controller = new QualtricsVocalizeController();
			System.assertEquals(true,controller.hasCredentials);
			System.assertEquals(false,controller.userHasVocalizeAccess);
			//checkVocalizePermissions
			controller.checkVocalizePermissions();
			System.assertEquals(true,controller.userHasVocalizeAccess);
			System.assert(controller.requestParamJSON.contains('Vocalize'));
			//getPageCont
		    QualtricsVocalizeController controllerThis = controller.getPageCont();
		    System.assert(controllerThis != null);
	    	Test.stopTest();
	    }
	}

	@IsTest
	static void testVocalizeController_Negative() {
		User user = TestingUtils.createTestUser();
		TestingUtils.createApiCustomSettings(user);
		System.runAs(user){
			Test.startTest();
			//Set API Mock
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockNegativeTest());

			QualtricsVocalizeController controller = new QualtricsVocalizeController();
			//checkVocalizePermissions
			controller.checkVocalizePermissions();
			System.assertEquals(false,controller.userHasVocalizeAccess);
			Test.stopTest();
		}
	}
}