@isTest (seeAllData=False)
public class Test_LicenseManagement {

	static testMethod void testConfirmCannotDeleteLicense() {
		//Lead newLead = new Lead(LastName = 'Test', Company = 'Tester', Status = 'Open - Not Contacted');
		//insert newLead;
		sfLma__License__c lic = new sfLma__License__c(
					sfLma__Install_Date__c = System.Today(),
					sfLma__Seats__c = 4,
					sfLma__Status__c = 'Active',
					sfLma__Subscriber_Org_ID__c = '00D61000000eWOY'
					//sfLma__Lead__c = newLead.Id
					);

		insert lic;
	test.startTest();

		delete lic;
		ApexPages.Message[] msgs=ApexPages.getMessages();
       	boolean messagePosted = false;
       	for(ApexPages.Message msg : msgs)
       	{ 
       		if(msg.getDetail().contains('To prevent errors, License records may not be deleted under any conditions.')) 
       		{
       			messagePosted = true;
       		}
       	}
     test.stopTest();
       	for(ApexPages.Message msg : ApexPages.getMessages())
       	{
       		System.assertEquals('To prevent errors, License records may not be deleted under any conditions.', msg.getSummary());
       	}	
	}
}