 @isTest
private class QualtricsRestSvc_Test {

	@isTest
	static void testQualtricsPostPositive() {
		User user = TestingUtils.createStandardUser();
		TestingUtils.createApiCustomSettings(user);
		System.runAs(user) {

			RestRequest req = new RestRequest(); 
			RestResponse res = new RestResponse();

			req.requestURI = System.Url.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Qualtrics/connectionUpdater';
			req.httpMethod = 'POST';
			RestContext.request = req;
			RestContext.response = res;

			String results = QualtricsRestSvc.connectionUpdater(1);

			System.assertEquals('Success', results);
		}

	}

	@isTest
	static void testQualtricsPostWithError() {
		//NOT CREATING API Settings should throw an error (because of the Update)
		User user = TestingUtils.createStandardUser();
		System.runAs(user) {
			RestRequest req = new RestRequest(); 
			RestResponse res = new RestResponse();

			req.requestURI = System.Url.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Qualtrics/connectionUpdater';
			req.httpMethod = 'POST';
			RestContext.request = req;
			RestContext.response = res;

			String results = QualtricsRestSvc.connectionUpdater(0);

			System.assert(results.contains('Failure'));
		}
	}

}