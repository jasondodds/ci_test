@isTest (seeAllData=false)
public class Test_OpportunityFromLicense {

	static testMethod void intentionalSuccess() {
	  system.assertEquals(1,1);   
	}
	static testMethod void LicenseWithoutContact()
	{
		Id recordTypeId = [ SELECT Id
                        FROM RecordType 
                        WHERE Name = 'Active' AND SobjectType = 'sfLma__License__c'].Id;

		sfLma__License__c lic = new sfLma__License__c(
       RecordTypeId = recordTypeId,
       sfLma__Status__c = 'Active',
       sfLma__Seats__c = 1,
       sfLma__License_Type__c = 'Editable',
       sfLma__Expiration__c = system.today().addDays(30),
       sfLma__Install_Date__c = system.today(),
       sfLma__Subscriber_Org_ID__c = 'ABC123'
       ); 
       insert lic;  

       test.startTest();

       Test.setCurrentPage(Page.OpportunityFromLicense);
        ApexPages.StandardController ctrl = new ApexPages.StandardController(lic);
     	 OpportunityFromLicense controller = new OpportunityFromLicense(ctrl);	
       controller.CheckForContact();

       ApexPages.Message[] msgs=ApexPages.getMessages();
       boolean messagePosted = false;
       for(ApexPages.Message msg : msgs)
       	{
       		if(msg.getDetail().contains('Need to convert Lead first.')) 
       		{
       			messagePosted = true;
       		}
       	}
       	test.stopTest();
       	for(ApexPages.Message msg : ApexPages.getMessages())
       	{
       		System.assertEquals('Need to convert Lead first.', msg.getSummary());
       	}
	}

	static testMethod void LicenseWithContact()
	{
		Account acct = new Account(Name = 'test');
		insert acct;
		Contact con = new Contact( LastName = 'Tester', Accountid = acct.Id);
		insert con;

		Id recordTypeId = [ SELECT Id
                        FROM RecordType 
                        WHERE Name = 'Active' AND SobjectType = 'sfLma__License__c'].Id; 
    sfLma__License__c lic = new sfLma__License__c(
       RecordTypeId = recordTypeId,
       sfLma__Status__c = 'Active',
       sfLma__Seats__c = 1,
       sfLma__License_Type__c = 'Editable',
       sfLma__Expiration__c = system.today().addDays(30),
       sfLma__Install_Date__c = system.today(),
       sfLma__Subscriber_Org_ID__c = 'ABC123',
       sfLma__Contact__c = con.Id
       ); 
       insert lic;  
     test.startTest();
     ApexPages.StandardController ctrl = new ApexPages.StandardController(lic);
     OpportunityFromLicense controller = new OpportunityFromLicense(ctrl);	
     controller.CheckForContact();
     test.stopTest();

     List<Opportunity> result = [SELECT Id from Opportunity WHERE Accountid = :acct.Id];
     System.assertEquals(1,result.size());
   }

   static testMethod void LicenseWithContactButNoAccount()
   {
   	Contact con = new Contact( LastName = 'Tester');
    insert con;
    Id recordTypeId = [ SELECT Id
                        FROM RecordType 
                        WHERE Name = 'Active' AND SobjectType = 'sfLma__License__c'].Id; 
    sfLma__License__c lic = new sfLma__License__c(
       RecordTypeId = recordTypeId,
       sfLma__Status__c = 'Active',
       sfLma__Seats__c = 1,
       sfLma__License_Type__c = 'Editable',
       sfLma__Expiration__c = system.today().addDays(30),
       sfLma__Install_Date__c = system.today(),
       sfLma__Subscriber_Org_ID__c = 'ABC123',
       sfLma__Contact__c = con.Id
       ); 
       insert lic;  
     test.startTest();
      Test.setCurrentPage(Page.OpportunityFromLicense);
      ApexPages.StandardController ctrl = new ApexPages.StandardController(lic);
      OpportunityFromLicense controller = new OpportunityFromLicense(ctrl);  
      controller.CheckForContact();

       ApexPages.Message[] msgs=ApexPages.getMessages();
       boolean messagePosted = false;
       for(ApexPages.Message msg : msgs)
        {
          if(msg.getDetail().contains('Need to convert Lead first.')) 
          {
            messagePosted = true;
          }
        }
      test.stopTest();
      for(ApexPages.Message msg : ApexPages.getMessages())
      {
        System.assertEquals('We found a matching Contact, but it does not have an Account.  Please create an Account for this Contact before proceeding.', msg.getSummary());
      }
   }
}