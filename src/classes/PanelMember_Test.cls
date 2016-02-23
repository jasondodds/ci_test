@isTest
private class PanelMember_Test {

	@isTest static void testCampaignFields(){
		Map<String, Schema.SObjectField> campaignFieldMap = Schema.SObjectType.Campaign.fields.getMap();
		if(campaignFieldMap.containsKey('name') && campaignFieldMap.get('name').getDescribe().isAccessible()){
			System.assert(PanelMember.campaignAccessibleFields.contains('Name'));
		}
		else{
			System.assert(!PanelMember.campaignAccessibleFields.contains('Name'));
		}
	}

	@isTest static void testLeadFields(){
		Map<String, Schema.SObjectField> leadFieldMap = Schema.SObjectType.Lead.fields.getMap();
		if(leadFieldMap.containsKey('numberofemployees') && leadFieldMap.get('numberofemployees').getDescribe().isAccessible()){
			System.assert(PanelMember.leadAccessibleFields.contains('NumberOfEmployees'));
		}
		else{
			System.assert(!PanelMember.leadAccessibleFields.contains('NumberOfEmployees'));
		}
		//if(leadFieldMap.containsKey('hasoptedoutofemail') && leadFieldMap.get('hasoptedoutofemail').getDescribe().isAccessible()){
		System.assert(PanelMember.leadAccessibleFields.contains('HasOptedOutOfEmail'));
		//}
		//else{
		//	System.assert(!PanelMember.leadAccessibleFields.contains('HasOptedOutOfEmail'));
		//}
	}

	@isTest static void testContactFields(){
		TestingUtils.createOptOutCustomSettings();
		Map<String, Schema.SObjectField> contactFieldMap = Schema.SObjectType.Contact.fields.getMap();
		if(contactFieldMap.containsKey('email') && contactFieldMap.get('email').getDescribe().isAccessible()){
			System.assert(PanelMember.contactAccessibleFields.contains('Email'));
		}
		else{
			System.assert(!PanelMember.contactAccessibleFields.contains('Email'));
		}
		//if(contactFieldMap.containsKey('hasoptedoutofemail') && contactFieldMap.get('hasoptedoutofemail').getDescribe().isAccessible()){
		System.assert(PanelMember.contactAccessibleFields.contains('HasOptedOutOfEmail'));
		System.assert(PanelMember.contactAccessibleFields.contains('DoNotCall'));
		//}
		//else{
		//	System.assert(!PanelMember.contactAccessibleFields.contains('HasOptedOutOfEmail'));
		//}
	}

	@isTest static void testMemberString(){
		Account account = new Account(Name='test account');
		insert account;
		
		Contact contact = new Contact(FirstName = 'Jane', LastName='Doe', AccountID=account.Id, Birthdate = Date.newInstance(1989, 06, 07) );
		insert contact;

		Campaign campaign = new Campaign(Name = 'Test Campaign', IsActive = True, Status = 'Sent', StartDate = Date.newInstance(2020, 01, 01), EndDate = Date.newInstance(2020, 12, 31));
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

		Test.startTest();
			String contactMemberString = PanelMember.makeMemberString(contact, campaign, account.Id);
			String leadMemberString = PanelMember.makeMemberString(l[0], campaign, account.Id);
		Test.stopTest();
		Map<String, Object> jsonMap;
		jsonMap = (Map<String, Object>) JSON.deserializeUntyped(contactMemberString);
		System.assert(jsonMap.get('LastName') == 'Doe', 'The Contacts last name should be Doe');
		jsonMap = (Map<String, Object>) JSON.deserializeUntyped(leadMemberString);
		System.assert(jsonMap.get('LastName') == 'Smith', 'The Contacts last name should be Smith');
	}

	@isTest static void testCheckMissingOptOutFields() {
		TestingUtils.createMissingOptOutCustomSettings();

		Test.startTest();
		Set<Id> testMissingIds = PanelMember.checkMissingOptOutFields();
		System.assertEquals(1,testMissingIds.size());
		Test.stopTest();
	}

}