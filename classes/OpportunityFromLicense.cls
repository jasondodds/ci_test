public with sharing class OpportunityFromLicense {

	private final sfLma__License__c license;

		public OpportunityFromLicense(ApexPages.StandardController controller)
	{
		license =[SELECT Id, sfLma__Contact__c 
							FROM sfLma__License__c 
	  					WHERE Id = :controller.getId()];
	}

	public PageReference CheckForContact()
	{
		if(license.sfLma__Contact__c != NULL)
			{
				Id newOpportunityId; 
			  newOpportunityId = populateOpportunityFields(license);
			  if(newOpportunityId != NULL)
			  	{
			  		PageReference pr = new PageReference('/' + string.valueOf(newOpportunityId));
			  		pr.setRedirect(TRUE);
			  		return pr;
			  	}
			}
		else
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Need to convert Lead first, and insure Lead has a Contact.'));
			}
		return null;
	}

	private Id populateOpportunityFields(sfLma__License__c license) {
		List<sfLma__License__c> inboundLicense = new List<sfLma__License__c>();
		inboundLicense.add(license);

		List<Contact> licenseContacts = new List<Contact>([SELECT Id, AccountId FROM Contact
																												WHERE License__c != NULL]);
		List<Opportunity> newOpportunity = new List<Opportunity>();

		for(Contact c :licenseContacts)
		 {
			if(c.AccountId != NULL)
			 {
			  for(sfLma__License__c l: inboundLicense)
			   {
				  if(l.sfLma__Contact__c == c.Id)
				   {		
						Integer numberOfDays = Date.daysInMonth(System.Today().year(), System.Today().month());
						Date lastDayOfMonth  = Date.newInstance(System.Today().year(), System.Today().month(), numberOfDays);		
						
						Opportunity newOpp = new Opportunity();
						//We will need to massage this later: with Account Name in it. 
						newOpp.Name = 'New LMA Opportunity';
						newOpp.License__c = license.Id;
						newOpp.CloseDate = lastDayOfMonth;
						newOpp.StageName = 'Prospecting';
						newOpp.AccountId = c.AccountId;
						newOpportunity.add(newOpp);
				   }
			   }
		   }
		   else
		   {
		   	//provide a message stating the Contact needs an Account.  
		   	//'We found a matching Contact, but it does not have an Account.  Please create an Account for this Contact 
		   	//before proceeding.'
		   	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'We found a matching Contact, but it does not have an Account.  Please create an Account for this Contact before proceeding.'));
		   }
		 }
		 if(newOpportunity.size()>0)
		 {
		 	return createNewOpportunity(newOpportunity);
		 } 
		 else 
			{
				return null;
			}
	}

	private ID createNewOpportunity(List<Opportunity> newOpportunity)
	{
		insert newOpportunity;
		return newOpportunity[0].Id;
	}
}