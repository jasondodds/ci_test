@isTest
private class SurveyResponse_Test {
	
	@isTest static void test_NameAutoNumberNew() {
		Survey__c survey = new Survey__c();
		insert survey;
		Survey_Response__c response1 = new Survey_Response__c();
		response1.Name = survey.Id;
		Test.startTest();
			insert response1;
		Test.stopTest();
		response1 = [SELECT Name FROM Survey_Response__c LIMIT 1];
		System.assertEquals('QSR-1', response1.Name, 'This should be QSR-1, but it was '+response1.Name);
	}

	@isTest static void test_NameAutoNumberExisting() {
		Survey__c survey = new Survey__c();
		insert survey;
		Survey_Response__c response1 = new Survey_Response__c();
		response1.Name = 'QSR-1';
		insert response1;
		Survey_Response__c response2 = new Survey_Response__c();
		response2.Name = survey.Id;
		Test.startTest();
			insert response2;
		Test.stopTest();
		response2 = [SELECT Name FROM Survey_Response__c WHERE Id = :response2.Id];
		System.assertEquals('QSR-2', response2.Name, 'This should be QSR-2, but it was '+response2.Name);
	}

	@isTest static void test_NameAutoNumberMulti() {
		Survey__c survey = new Survey__c();
		insert survey;
		List<Survey_Response__c> responses = new List<Survey_Response__c>();
		for(Integer i=0; i<10; i++){
			Survey_Response__c response = new Survey_Response__c();
			response.name = survey.Id;
			responses.add(response);
		}
		Test.startTest();
			insert responses;
		Test.stopTest();
		responses = [SELECT Name FROM Survey_Response__c ORDER BY Name ASC];
		System.assertEquals('QSR-1', responses.get(0).Name, 'This should be QSR-1, but it was '+responses.get(0).Name);
		System.assertEquals('QSR-10', responses.get(1).Name, 'This should be QSR-10, but it was '+responses.get(1).Name);
		System.assertEquals('QSR-2', responses.get(2).Name, 'This should be QSR-2, but it was '+responses.get(2).Name);
		System.assertEquals('QSR-9', responses.get(9).Name, 'This should be QSR-9, but it was '+responses.get(9).Name);
	}

	@isTest static void test_NameAutoNumberNegative() {
		Survey__c survey = new Survey__c();
		insert survey;
		Survey_Response__c response1 = new Survey_Response__c();
		response1.Name = 'QSR-XXX';
		insert response1;
		Survey_Response__c response2 = new Survey_Response__c();
		response2.Name = survey.Id;
		Test.startTest();
			insert response2;
		Test.stopTest();
		response2 = [SELECT Name FROM Survey_Response__c WHERE Id = :response2.Id];
		System.assertEquals('QSR-1', response2.Name, 'This should be QSR-1, but it was '+response2.Name);
	}
}