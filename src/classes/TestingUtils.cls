@isTest
public with sharing class TestingUtils {

	public static void createApiCustomSettings(User user){
		Qualtrics_API_Settings__c setting = Qualtrics_API_Settings__c.getInstance(user.Id);
		setting.User_Name__c = user.UserName ;
		setting.API_Token__c = 'etetetetet2';
		setting.User_Id__c = 'userid2';
		upsert setting;
	}

	public static void createOptOutCustomSettings(){
		Qualtrics_Email_Opt_out__c setting = New Qualtrics_Email_Opt_out__c();
		setting.Name = 'Contact|DoNotCall';
		setting.SObject_Name__c = 'Contact';
		setting.Field_Name__c = 'DoNotCall';
		insert setting;
	}

	public static void createMissingOptOutCustomSettings(){
		List<Qualtrics_Email_Opt_out__c> settings = New List<Qualtrics_Email_Opt_out__c>();
		settings.add(
			new Qualtrics_Email_Opt_out__c(
				Name = 'Contact|TestBoolean',
				SObject_Name__c = 'Contact',
				Field_Name__c = 'TestBoolean'
			)
		);
		settings.add(
			new Qualtrics_Email_Opt_out__c(
				Name = 'Contact|DoNotCall',
				SObject_Name__c = 'Contact',
				Field_Name__c = 'DoNotCall'
			)
		);
		insert settings;
	}

	public static User createTestUser(){
		//create a test user
		return TestingUtils.createStandardUser();
	}

	public static User createStandardUser(){
		//create a test user
	    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
		User user = new User(Alias ='testapi', Email='testapi333@test.com',  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='testapi333@testorg.com');
		insert user;
		return user;
	}

	public static User createAdminUser(){
		//create a test user
	    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		User user = new User(Alias ='testapi', Email='testapi333@test.com',  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='testapi444@testorg.com');
		insert user;
		return user;
	}

	public static User createAdminUserWithAdminPermSet(){
		//create a test user
	    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		User user = new User(Alias ='testapi', Email='testapi333@test.com',  EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='testapi555@testorg.com');
		insert user;

		List<PermissionSet> permsets = [Select Id, Name from PermissionSet where name like '%Qualtrics_Admin'];
		if(permsets.size() > 0) {
			PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = permsets[0].Id, AssigneeId = user.Id);
			insert psa;
		}
		return user;
	}


	public static String parseJSONValue(HttpRequest request, String fieldToFind ){
		String value;
		JSONParser parser = JSON.createParser(request.getBody());
		while(parser.nextToken() != null){ 

			if((parser.getCurrentToken() == JSONToken.FIELD_NAME) ){
				String fieldName = parser.getText();
		        System.debug('$$$ fieldName: ' + fieldName);
				parser.nextToken();
				if(fieldName == fieldToFind){
					value = parser.getText();
					break;
				}
			}
		}
		return value;		
	}

}