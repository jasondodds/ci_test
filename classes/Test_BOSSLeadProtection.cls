@isTest (seeAllData=false)
private class Test_BOSSLeadProtection {
    
	static testMethod void  testLeadWithNoLicense ()
    {
        List<Lead> leads = new List<Lead>();
        leads.add(new Lead(
        	LastName = 'Test',
            Company = 'Test1'
        ));
        insert leads;
        test.startTest();
        delete leads;
        test.stoptest();
        
        integer results = database.countQuery('SELECT count() FROM Lead');
        
        system.assertEquals(0,results);
    }
    
    static testMethod void testLeadWithLicense (){
        List<sfLma__License__c> newLicense = new List<sfLma__License__c>();
            newLicense.add(new sfLma__License__c(
                sfLma__License_Type__c = 'Application Installation'
                ));
            insert newLicense;
        List<Lead> addLead = new List<Lead>();
            addLead.add(new Lead(LastName='Test',
                        Company='Test1',
                        License__c = [SELECT Id FROM sfLma__License__c LIMIT 1].Id));
            insert addLead;
        try{
       	 delete addLead;
        } catch (DMLException ex){
        	System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
      		System.assertEquals('To prevent errors, Leads may not be deleted when associated to a License.', ex.getDmlMessage(0));
        }
    }
     static testMethod void testDeleteLeadThatIsPopulatedInLicense (){
        List<Lead> theLead = new List<Lead>();
        theLead.add(new Lead(LastName = 'Test', Company='Test1'));
        insert theLead;
        //create a new License where the LicenseLead.Id = Lead.Id
        List<sfLma__License__c> theLicense = new List<sfLma__License__c>();
            theLicense.add(new sfLma__License__c(sfLma__Lead__c = [SELECT Id FROM Lead WHERE LastName = 'Test' LIMIT 1].Id));
        insert theLicense;

        try{
            delete theLead;
        } catch (DMLException e){
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, e.getDmlType(0));
            System.assertEquals('To prevent errors, Leads may not be deleted when associated to a License.', e.getDmlMessage(0));
        }



     }
   
}