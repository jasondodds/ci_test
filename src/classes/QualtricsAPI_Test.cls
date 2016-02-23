@isTest
private class QualtricsAPI_Test {
	@isTest
	static void testCreatePanel() {
		User user = TestingUtils.createTestUser();
		TestingUtils.createApiCustomSettings(user);
	    System.runAs(user) {
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
			String id = QualtricsAPI.createPanel('test panel name');
	        System.assertEquals('9', id);
	        Test.stopTest();
		}
	}
	@isTest
	static void testCreateLibraryMessage(){
		User user = TestingUtils.createTestUser();
		TestingUtils.createApiCustomSettings(user);
		System.runAs(user){
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
			String id = QualtricsAPI.createLibraryMessage('messageName' ,'String message');
			System.assertEquals('MS_5ckH2UkAFq1I6PP', id);
			Test.stopTest();
		}
	}
	@isTest
	static void testGetLibraryMessages(){
		User user = TestingUtils.createTestUser();
		TestingUtils.createApiCustomSettings(user);
		System.runAs(user){
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
			List<QualtricsAPI.LibraryMessage> mylist = QualtricsAPI.getLibraryMessages();
			System.assertEquals(4, mylist.size());
			Test.stopTest();
		}
	}
	@isTest
	static void testGetLibraryMessagesNoneFound(){
		User user = TestingUtils.createTestUser();
		TestingUtils.createApiCustomSettings(user);
		System.runAs(user){
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockNegativeTest());
			List<QualtricsAPI.LibraryMessage> mylist = QualtricsAPI.getLibraryMessages();
			System.assertEquals(1, mylist.size());
			System.assertEquals('nullPlaceholder', mylist[0].id);
			System.assertEquals('No Invite Messages in your Account', mylist[0].name);
			Test.stopTest();
		}
	}
	@isTest
	static void testGetLibraryMessage(){
		User user = TestingUtils.createTestUser();
		TestingUtils.createApiCustomSettings(user);
		System.runAs(user){
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
			String message = QualtricsAPI.getLibraryMessage('messageid');
			System.assertEquals('test message content', message);
			Test.stopTest();
		}
	}
	@isTest
	static void testQueryAllSurveys(){
		User user = TestingUtils.createTestUser();
		TestingUtils.createApiCustomSettings(user);
		System.runAs(user){
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
			List<SurveyResultWrapper.Surveys> allSurveyList = QualtricsAPI.queryAllSurveys();
			System.assertEquals(12, allSurveyList.size());
			
			List<SurveyResultWrapper.Surveys> activeSurveyList = QualtricsAPI.queryActiveSurveys();
			System.assertEquals(1, activeSurveyList.size());
			Test.stopTest();
		}
	}

	@isTest
	static void testSendSurveyToPanel(){
		User user = TestingUtils.createTestUser();
		TestingUtils.createApiCustomSettings(user);
		System.runAs(user){
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
			List<String> idList = QualtricsAPI.sendSurveyToPanel('2015-04-0715:00:00', 'test@test.com', 'test sender', 'test Subject', 'messageid', 'panelId', 'surveyid');
			System.assertEquals(2, idList.size());
			System.assertEquals('EMD_5bEgY6ln4MBhtDD', idList[0]);
			System.assertEquals('EMD_5bEgY6ln4MBhtDD', idList[1]);
			Test.stopTest();
		}
	}

	@isTest
	static void testRetrieveUserId(){
		User user = TestingUtils.createTestUser();
		TestingUtils.createApiCustomSettings(user);
		System.runAs(user){
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
			Map<String,String> userIdMap = QualtricsAPI.retrieveUserId('user@user.com', 'surveyid');
			System.assertEquals('UR_88uCZoW8wlvqdPT', userIdMap.get('Success'));
			Test.stopTest();
		}
	}

	@isTest
	static void testRetrieveUserIdFail(){
		User user = TestingUtils.createTestUser();
		TestingUtils.createApiCustomSettings(user);
		System.runAs(user){
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockNegativeTest());
			Map<String,String> userIdMap = QualtricsAPI.retrieveUserId('user@user.com', 'somefaketokenvalue');
			System.assertEquals('<XML><Test> test failure</Test></XML>', userIdMap.get('Exception'));
			Test.stopTest();
		}
	}

	@isTest
	static void testRetrieveUserApiToken(){
		User user = TestingUtils.createTestUser();
		TestingUtils.createApiCustomSettings(user);
		System.runAs(user){
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
			Map<String, String> tokenMap = QualtricsAPI.retrieveUserApiToken('user@user.com', 'password');
			System.assertEquals('mjiHDKkXSslRPLUhXQjyTc5ouVd8gFt6pZgMZxtf', tokenMap.get('Success'));
			Test.stopTest();
		}
	}
	
	@isTest
	static void testRetrieveUserApiTokenFail(){
		User user = TestingUtils.createTestUser();
		TestingUtils.createApiCustomSettings(user);
		System.runAs(user){
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockNegativeTest());
			Map<String,String> tokenMap = QualtricsAPI.retrieveUserApiToken('user@user.com', 'password');
			System.assertEquals('You do not have the required permissions.', tokenMap.get('Error'));
			Test.stopTest();
		}
	}

	@isTest
	static void testRetrieveUserVocalizePermissions() {
		User user = TestingUtils.createTestUser();
		TestingUtils.createApiCustomSettings(user);
		System.runAs(user){
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
			Boolean returnVal = QualtricsAPI.retrieveUserVocalizePermissions();
			System.assertEquals(true, returnVal);
			Test.stopTest();
		}
	}

	@isTest
	static void testRetrieveUserVocalizePermissionsFail() {
		User user = TestingUtils.createTestUser();
		TestingUtils.createApiCustomSettings(user);
		System.runAs(user){
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockNegativeTest());
			Boolean returnVal = QualtricsAPI.retrieveUserVocalizePermissions();
			System.assertEquals(false, returnVal);
			Test.stopTest();
		}
	}

	//Constructors
	@isTest
	static void testConstructors() {
		User user = TestingUtils.createTestUser();
		System.runAs(user){
			TestingUtils.createApiCustomSettings(user);
			Test.startTest();
			QualtricsAPI qAPI = new QualtricsAPI();
			qAPI = new QualtricsAPI(Qualtrics_API_Settings__c.getInstance(user.Id));
			Test.stopTest();
		}
	}

	//public static String importSurvey(String surveyName, String quickStartName)
	@isTest
	static void testImportSurvey() {
		User user = TestingUtils.createTestUser();
		TestingUtils.createApiCustomSettings(user);
		System.runAs(user){
            TestingUtils.createApiCustomSettings(user);
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
            Test.startTest();
			QualtricsAPI.importSurvey('New Blank Survey', null);
            Test.stopTest();
		}
	}

	//public static void addPanelMembers(String panelId, List<String> panelMembers)
	@isTest
	static void testAddPanelMembers() {
		User user = TestingUtils.createTestUser();
		TestingUtils.createApiCustomSettings(user);
		System.runAs(user){
			Account account = new Account(Name='test account');
			insert account;
			
			Contact contact = new Contact(FirstName = 'Jane', LastName='Doe', AccountID=account.Id, Birthdate = Date.newInstance(1989, 06, 07) );
			insert contact;

			Campaign campaign = new Campaign(Name = 'Test Campaign', IsActive = True, Status = 'Sent');
			insert campaign;
			 
			Lead[] l = new Lead[]{
				new Lead(FirstName = 'Bob', LastName = 'Smith', State = 'NJ', Status = 'Active', Company = 'Company A'),
				new Lead(FirstName = 'Janet', LastName = 'Pom', State = 'OH', Status = 'Active', Company = 'Company B')
			};
			insert l;
			 
			CampaignMember[] cm = new CampaignMember[]{
				new CampaignMember(CampaignId = campaign.Id, LeadId = l[0].Id),
				new CampaignMember(CampaignId = campaign.Id, LeadId = l[1].Id)
			};			 

			List<String> leadMemberStrings = new List<String>{PanelMember.makeMemberString(l[0], campaign, account.Id), PanelMember.makeMemberString(l[0], campaign, account.Id)};
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
			QualtricsAPI.addPanelMembers(account.Id, leadMemberStrings);
			Test.stopTest();
		}
	}

	//public static HttpResponse doRequestNewAPI( String urlExtension, String data)
	@isTest
	static void doRequestNewAPI() {
		User user = TestingUtils.createTestUser();
		TestingUtils.createApiCustomSettings(user);
	    System.runAs(user) {
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
			HttpResponse response = QualtricsAPI.doRequestNewAPI('/v1/panels/testPanel/members', 'test request');
			Test.stopTest();
		}
	}

	//public static HttpResponse makeApiRequest(String data)
	@isTest
	static void testMakeApiRequestOneParam() {
		User user = TestingUtils.createTestUser();
		TestingUtils.createApiCustomSettings(user);
	    System.runAs(user) {
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
			String requestString = 'Request=createPanel&Name=SFDCtest panel name';
			HttpResponse response = QualtricsAPI.makeApiRequest(requestString);
	        System.assertEquals('9', QualtricsAPI.parseJSONValue(response, 'PanelID'));
	        Test.stopTest();
		}
	}
	//public static HttpResponse makeApiRequest(String data, Boolean useLibraryId)
	@isTest
	static void testMakeApiRequestTwoParams() {
		User user = TestingUtils.createTestUser();
		TestingUtils.createApiCustomSettings(user);
	    System.runAs(user) {
			Test.startTest();
			Test.setMock(HttpCalloutMock.class, new QualtricsAPIMockTest());
			String requestString = 'Request=createPanel&Name=SFDCtest panel name';
			HttpResponse response = QualtricsAPI.makeApiRequest(requestString, true);
	        System.assertEquals('9', QualtricsAPI.parseJSONValue(response, 'PanelID'));
	        Test.stopTest();
		}
	}


}