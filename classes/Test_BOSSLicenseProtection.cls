@isTest (seeAllData=false)
private class Test_BOSSLicenseProtection {

    static testMethod void  testDeletionOfLicense (){
    
      List<sfLma__License__c> license = new List<sfLma__License__c>();
        license.add(new sfLma__License__c(
            sfLma__License_Type__c = 'Test License'
        ));
        insert license;

        List<sfLma__License__c> existing = [
                                    SELECT ID
                                    FROM sfLma__License__c
                                    WHERE sfLma__License_Type__c = 'Test License'];
         try{
                delete existing;
        } catch (DMLException ex){
            System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, ex.getDmlType(0));
            System.assertEquals('To prevent errors, License records may not be deleted under any conditions.', ex.getDmlMessage(0));
        }
    }
}