@isTest (seeAllData=false)

public class Test_BOSSLeadMerge {

	static testMethod void intentionalSuccess(){  system.assertEquals(1,1);    }

	static testMethod void testCompanyIsMergedToMaster()
	{
		Global_Settings__c settings = new Global_Settings__c();
		settings.BOSS_Convert_Lead_To_Contact__c = FALSE;
		settings.BOSS_Lead_Merge__c = TRUE;
		insert settings;

        Lead lead1 = new Lead(LastName = 'Master',
                              Email = 'oldlead@lead.com',
                              Company = 'Test1',
                              LeadSource = 'SFDC-IN|Boss,Dummy',
                              Phone = '8885551234',
                              Industry ='');
        Lead lead2 = new Lead(LastName = 'NOT Duplicate 1',
                              Email = 'tonedeaf@musichall.com', 
                              Company = 'NO INTEREST LEAD',
                              LeadSource = 'Trainwreck');
        Lead lead3 = new Lead(LastName = 'Not Duplicate 2',
                              Company = 'NO INTEREST LEAD',
                              Email = 'toolegit@toquit.com');
        Lead lead4 = new Lead(LastName = 'NOT Duplicate 3',
                              Email = 'goodLead@leads.com',
                              LeadSource = 'SFDC-DM| Boss,Dummy',
                              Company = 'Good Leads');
    	Lead[] leads = new Lead[]{lead1,lead2, lead3, lead4};			
  		  insert leads;						
        Lead dup1 = new Lead(FirstName = 'Duplicate',                       //BOSS Duplicate
        	                 LastName = 'New Lead',
        	                 Email = 'oldlead@lead.com',
        	                 Company = 'Rock N Stomp Em',
                             LeadSource = 'Package Installation',
                             Phone = '8885551235',
                             Industry = 'Other'
                                );
        Lead dup2 = new Lead(LastName = 'Not Duplicate3',                   //normal duplicate
                             Email = 'toolegit@toquit.com',
                             Company = 'NO INTEREST LEAD'
                             );
        Lead[] dups = new Lead[]{dup1,dup2}; 

        test.startTest();
        Long startingTime = System.now().getTime();
        Integer delayInMilliseconds = 1000;
        while(System.Now().getTime() - startingTime < delayInMilliseconds){
        	 //Do nothing until 1 second has passed
        }
       	insert dups;
        BOSSBatchSchedulable batch = new BOSSBatchSchedulable();
		Database.executeBatch(batch);
        test.stopTest();
        String result = [SELECT LastName FROM Lead WHERE Company = 'Rock N Stomp Em' ORDER BY CreatedDate ASC LIMIT 1].LastName;
        system.assertEquals('Master', result);

	}

	static testMethod void testToConfirmMergeRecordsDeleted()
	{
		Global_Settings__c settings = new Global_Settings__c();
		settings.BOSS_Convert_Lead_To_Contact__c = FALSE;
		settings.BOSS_Lead_Merge__c = TRUE;
		insert settings;
		Lead masterLead = new Lead(LastName = 'MasterLead',
									Email = 'easy5@company.com',
									LeadSource = 'SFDC-IN|',
									Company = 'Unknown',
									Industry = 'IT');
		Long startingTime = System.now().getTime();
        insert masterLead;
        Integer delayInMilliseconds = 1000;

		while(System.Now().getTime() - startingTime < delayInMilliseconds)
        	{
        	 //Do nothing until 1 second has passed
        	}
		Lead mergeLead1 = new Lead(LastName = 'DuplicateLead1',
									Email = 'easy5@company.com',
									LeadSource = 'SFDC-TS|',
									Company = 'Easy Company',
									Industry = ''
									);
		Lead mergeLead2 = new Lead(LastName = 'DuplicateLead2',
									Email = 'easy5@company.com',
									LeadSource = 'Package Installation',
									Company = 'Easy Company',
									Industry = '');
		Lead[] dupes = new Lead[] {mergeLead1,mergeLead2};
		test.startTest();
		insert dupes;

		BOSSBatchSchedulable batch = new BOSSBatchSchedulable();
		Database.executeBatch(batch,5);

		test.stopTest();

		List<Lead> result = [SELECT Id FROM Lead WHERE Email = 'easy5@company.com'];
		Lead[] results2 = [SELECT Id, Name FROM Lead WHERE Id= :mergeLead1.Id];

		System.assertEquals(1,result.size());
		System.assertEquals(0,results2.size());	
	}
	//@isTest(seeAllData=true)
	static void testChildRelationshipsReparented()
	{
		Global_Settings__c settings = new Global_Settings__c();
		settings.BOSS_Convert_Lead_To_Contact__c = FALSE;
		settings.BOSS_Lead_Merge__c = TRUE;
		insert settings;

		Lead masterLead = new Lead(LastName = 'MasterLead',
									Email = 'easy5@company.com',
									LeadSource = 'SFDC-IN|',
									Company = 'Unknown',
									Industry = 'IT');
		Long startingTime = System.now().getTime();
        Integer delayInMilliseconds = 1000;

        while(System.Now().getTime() - startingTime < delayInMilliseconds)
        	{
        	 //Do nothing until 1 second has passed
        	}
        insert masterLead;
		Lead mergeLead1 = new Lead(LastName = 'DuplicateLead1',
									Email = 'easy5@company.com',
									LeadSource = 'SFDC-TS|',
									Company = 'Easy Company',
									Industry = ''
									);
		Lead mergeLead2 = new Lead(LastName = 'DuplicateLead2',
									Email = 'easy5@company.com',
									LeadSource = 'Package Installation',
									Company = 'Easy Company',
									Industry = '');
		Lead[] dupes = new Lead[] {mergeLead1,mergeLead2};
		insert dupes;

		Task task1 = new Task(WhoId = mergeLead2.Id, 
							  Subject = 'Other', 
							  ActivityDate = Date.today().addDays(7),
							  Priority = 'Normal', 
							  Status = 'Not Started',
							  OwnerId = UserInfo.getUserId());
		insert task1;

		test.startTest();
		BOSSBatchSchedulable batch = new BOSSBatchSchedulable();
		Database.executeBatch(batch,5);
		test.stopTest();

		System.assertEquals(masterLead.Id, task1.WhoId);

	}

	static testMethod void testProperFieldUpdatedOnMaster()
	{	
		Global_Settings__c settings = new Global_Settings__c();
		settings.BOSS_Convert_Lead_To_Contact__c = FALSE;
		settings.BOSS_Lead_Merge__c = TRUE;
		insert settings;
		Lead masterLead = new Lead(	FirstName = '',
									LastName = 'MasterLastName',
									Email = 'easy7@company.com',
									LeadSource = 'SFDC-IN|',
									Company = 'Easy',
									Phone = '',
									Industry = 'IT');
		insert masterLead;
		Long startingTime = System.now().getTime();
		Integer delayInMilliseconds = 1000;
        while(System.Now().getTime() - startingTime < delayInMilliseconds)
        	{
        	 //Do nothing until 1 second has passed
        	}
        test.startTest();

		Lead mergeLead1 = new Lead( FirstName = 'Sam',
									LastName = 'DuplicateLead1LastName',
									Email = 'easy7@company.com',
									LeadSource = 'SFDC-TS|',
									Company = 'Easy Company',
									Industry = '',
									Phone = ''
									);
		Lead mergeLead2 = new Lead(	FirstName = 'Jones',
									LastName = 'DuplicateLead2LastName',
									Email = 'easy7@company.com',
									LeadSource = 'Package Installation',
									Company = 'The Easy Company',
									Phone = '8675309',
									Industry = '');
		Lead[] dupes = new Lead[] {mergeLead1,mergeLead2};
		insert dupes;
		BOSSBatchSchedulable batch = new BOSSBatchSchedulable();
		Database.executeBatch(batch,5);
		test.stopTest();

		String result = [SELECT Company FROM Lead WHERE LastName = 'MasterLastName'].Company;
		String result2 = [SELECT Phone FROM Lead WHERE LastName = 'MasterLastName'].Phone;
		String result3 = [SELECT FirstName FROM Lead WHERE LastName = 'MasterLastName'].FirstName;				

		System.assertEquals('The Easy Company',result);
		System.assertEquals('8675309', result2);
		System.assertEquals('Sam', result3);

	}

	static testMethod void testMoreThanThreeDuplicatesToMerge()
	{	
		Global_Settings__c settings = new Global_Settings__c();
		settings.BOSS_Convert_Lead_To_Contact__c = FALSE;
		settings.BOSS_Lead_Merge__c = TRUE;
		insert settings;
		Lead masterLead = new Lead(	FirstName = '',
									LastName = 'MasterLastName',
									Email = 'easy7@company.com',
									LeadSource = 'SFDC-IN|',
									Company = 'Easy',
									Phone = '',
									Industry = 'IT');
		insert masterLead;
		Long startingTime = System.now().getTime();
		Integer delayInMilliseconds = 1000;
        while(System.Now().getTime() - startingTime < delayInMilliseconds)
        	{
        	 //Do nothing until 1 second has passed
        	}
        test.startTest();

		Lead mergeLead1 = new Lead( FirstName = 'Sam',
									LastName = 'DuplicateLead1LastName',
									Email = 'easy7@company.com',
									LeadSource = 'SFDC-TS|',
									Company = 'Easy Company',
									Industry = '',
									Phone = ''
									);
		Lead mergeLead2 = new Lead(	FirstName = 'Jones',
									LastName = 'DuplicateLead2LastName',
									Email = 'easy7@company.com',
									LeadSource = 'SFDC-TD|',
									Company = 'The Easy Company',
									Phone = '8675309',
									Industry = '');
		Lead mergeLead3 = new Lead(	FirstName = 'Jones',
									LastName = 'DuplicateLead3LastName',
									Email = 'easy7@company.com',
									LeadSource = 'Package Installation',
									Company = 'Making It Easy');
		Lead[] dupes = new Lead[] {mergeLead1,mergeLead2,mergeLead3};
		insert dupes;
		BOSSBatchSchedulable batch = new BOSSBatchSchedulable();
		Database.executeBatch(batch,10);
		test.stopTest();

		String result = [SELECT Company FROM Lead WHERE LastName = 'MasterLastName'].Company;

		System.assertEquals('Making It Easy', result);
	}

	static testMethod void testLeadConvertToContact()
	{
		Global_Settings__c settings = new Global_Settings__c();
		settings.BOSS_Convert_Lead_To_Contact__c = TRUE;
		settings.BOSS_Lead_Merge__c = TRUE;
		insert settings;

		Account testAccount = new Account(Name = 'BOSS Test' );
		insert testAccount;

		Lead testLead = new Lead(LastName = 'Tester', Company = 'Test1', LeadSource = 'SFDC-TS|', Email = 'Test1@test.com');
		insert testLead;

		Contact oldContact = new Contact(LastName = 'Tester', Email = 'Test1@test.com'); //, AccountId = testAccount.Id
		insert oldContact;

		Task task1 = new Task(WhoId = testLead.Id, 
							  Subject = 'Other', 
							  ActivityDate = Date.today().addDays(7),
							  Priority = 'Normal', 
							  Status = 'Not Started',
							  OwnerId = UserInfo.getUserId());
		insert task1;
		test.startTest();
		BOSSBatchSchedulable batch = new BOSSBatchSchedulable();
		Database.executeBatch(batch,10);
		test.stopTest();
		List<Lead> result = [SELECT Id FROM Lead WHERE isConverted = TRUE];
		System.Debug('******************** RESULT: ' + result);
		System.assertEquals(1,result.size());
		//System.assert(oldContact.Id == task1.WhoId);
	}

}