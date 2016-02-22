public class LicenseManagement {

	public LicenseManagement() 
	{	}

	public void LicenseProtection(List<sfLma__License__c> license)
	{
    for(sfLma__License__c lic: license)
      if(lic.sfLma__Lead__c != NULL)  
      	{
          lic.addError('To prevent errors, License records may not be deleted under any conditions.');  
        }
	}

	public void PopulateLeadLicense(List<sfLma__License__c> license)
	{
		//create a List of Leads
   	List<Lead> leads = new List<Lead>();
    //Create a map of IDs from License --> License ID and License.Lead__c ID
    Map<Id,Id> association = new Map<Id,Id>();
    for (sfLma__License__c lic : license)
    	{
        if(lic.sfLma__Lead__c != NULL)             
        {
          association.put(lic.sfLma__Lead__c, lic.Id);               
        }
    	}
    leads = [SELECT License__c
            FROM Lead
            WHERE Id IN :association.keySet()];    
    for(Lead bossLeads : leads)
    {
       bossLeads.License__c = association.get(bossLeads.Id);
    }
    update leads;


    //doing the same for Contacts as for Leads
    List<Contact> contact = new List<Contact>();
    Map<Id,Id> association2 = new Map<Id,Id>();

    for (sfLma__License__c lic :license)
    {
      if(lic.sfLma__Contact__c != NULL)
        {
            association2.put(lic.sfLma__Contact__c,lic.Id);
        }
    }
    contact = [ SELECT License__c
                FROM Contact
                WHERE Id IN :association2.keySet()];
    for(Contact bossContacts : contact)
    {
      bossContacts.License__c = association2.get(bossContacts.Id);
    }
    update contact;
	}
}