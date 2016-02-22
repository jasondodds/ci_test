@isTest(seeAllData=false)
public class Test_PopulateLeadLicense {

    static testMethod void  testLicenseLeadCreate (){
    
        //Create Account license can be attached to
        Account acct = new Account (Name = 'test');

        //create package
        sfLma__Package__c pack = new sfLma__Package__c(
                Name = 'Test',
                sfLma__Developer_Name__c = 'test',
                sfLma__Latest_Version__c = '3',
                sfLma__Lead_Manager__c = UserInfo.getUserId(),
                sfLma__Package_ID__c = '3',
                sfLma__Release_Date__c = system.today().addDays(-30)
        );
        insert pack;
        insert acct;

        //create package version
        sfLma__Package_Version__c packageVersion = new sfLma__Package_Version__c(
              Name = 'Test',
              sfLma__Package__c = pack.Id,
              sfLma__Is_Beta__c = false,
              sfLma__Release_Date__c = system.today(),
              sfLma__Sequence__c = 1,
              sfLma__Version__c = '3',
              sfLma__Version_ID__c = '3'

          );
        insert packageVersion;

        //create license record
        test.startTest();
        Id recordTypeId = [ SELECT Id
                            FROM RecordType 
                            WHERE Name = 'Active' AND SobjectType = 'sfLma__License__c'].Id;
        Lead newLead = new Lead(
          LastName = 'Tester',
          Company = acct.Name,
          LeadSource = 'Package Installation');
       insert newLead;

       sfLma__License__c lic = new sfLma__License__c(
              RecordTypeId = recordTypeId,
              sfLma__Status__c = 'Active',
              sfLma__Seats__c = 1,
              sfLma__License_Type__c = 'Editable',
              sfLma__Account__c = acct.Id,
              sfLma__Expiration__c = system.today().addDays(30),
              sfLma__Install_Date__c = system.today(),
              sfLma__Package_Version__c = packageVersion.Id,
              sfLma__Subscriber_Org_ID__c = 'ABC123',
              sfLma__Lead__c = newLead.Id

       );  
       insert lic;  

     test.stopTest();

     Id result = [SELECT Id FROM sfLma__License__c].Id;
     Id result2 = [SELECT License__c FROM Lead].License__c;

     system.assertEquals(result,result2);

    }
    // Now Contact's Turn
    static testMethod void  testLicenseContactCreate (){
    
        //Create Account license can be attached to
        Account acct = new Account (Name = 'test');

        //create package
        sfLma__Package__c pack = new sfLma__Package__c(
                Name = 'Test',
                sfLma__Developer_Name__c = 'test',
                sfLma__Latest_Version__c = '3',
                sfLma__Lead_Manager__c = UserInfo.getUserId(),
                sfLma__Package_ID__c = '3',
                sfLma__Release_Date__c = system.today().addDays(-30)
        );
        insert pack;
        insert acct;

        //create package version
        sfLma__Package_Version__c packageVersion = new sfLma__Package_Version__c(
              Name = 'Test',
              sfLma__Package__c = pack.Id,
              sfLma__Is_Beta__c = false,
              sfLma__Release_Date__c = system.today(),
              sfLma__Sequence__c = 1,
              sfLma__Version__c = '3',
              sfLma__Version_ID__c = '3'

          );
        insert packageVersion;

        //create Contact & license record
        test.startTest();
        Contact newContact = new Contact(
        //  Account = acct.Id,
          LastName = 'Tester');
       insert newContact;
        Id recordTypeId = [ SELECT Id
                            FROM RecordType 
                            WHERE Name = 'Active' AND SobjectType = 'sfLma__License__c'].Id;
       sfLma__License__c lic = new sfLma__License__c(
              RecordTypeId = recordTypeId,
              sfLma__Status__c = 'Active',
              sfLma__Seats__c = 1,
              sfLma__License_Type__c = 'Editable',
              sfLma__Account__c = acct.Id,
              sfLma__Expiration__c = system.today().addDays(30),
              sfLma__Install_Date__c = system.today(),
              sfLma__Package_Version__c = packageVersion.Id,
              sfLma__Subscriber_Org_ID__c = 'ABC123',
              sfLma__Contact__c = newContact.Id

       );  
       insert lic;  

     test.stopTest();

     Id result = [SELECT Id FROM sfLma__License__c].Id;
     Id result2 = [SELECT License__c FROM Contact].License__c;

     system.assertEquals(result,result2);
   }
  }