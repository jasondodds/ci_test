public with sharing class BOSSLeadMerge {

	/*
		Now we have the Lead Merge && the Lead Conversion utilizing the Scope lead list.
			- create a method to take in the scope and parse the results out into a series of lists
			that can be absorbed by the LeadMerge and the ContactConversion.
	*/

	public BOSSLeadMerge(){
		//Constructor
	}

	public void LeadMerge(List<Lead> scope){

	List<AggregateResult> listOfDupEmails = [SELECT Email
																					 FROM Lead 
																					 WHERE (LeadSource LIKE 'SFDC-IN|%' 
											 											OR  LeadSource LIKE 'SFDC-DM|%' 
																						OR  LeadSource LIKE 'SFDC-TD|%' 
																						OR  LeadSource LIKE 'SFDC-TS|%' 
																						OR  LeadSource LIKE 'Package Installation%' 
																						OR  LeadSource LIKE 'SFDC-dup-IN|%'
																						OR  LeadSource LIKE 'SFDC-dup-DM|%'
																						OR  LeadSource LIKE 'SFDC-dup-TD|%'
																						OR  LeadSource LIKE 'SFDC-dup-TS|%')
																						AND IsConverted = FALSE
																					 GROUP BY Email 
																					 HAVING Count(Id)>1];

	List<Lead> bucketOfLeads = new List<Lead>();	
	List<Lead> leadsToMerge = new List<Lead>();	
	Lead masterLead;
		if(listOfDupEmails.size() > 0)
		 {
			Object duplicateLead = listOfDupEmails[0].get('Email');
			for(Lead results :scope)	
				{
					if(! listOfDupEmails.isEmpty())
					{
						if(results.Email == duplicateLead)		
						{
							bucketOfLeads.add(results);	
						}
					}
				}
			}
		
		if(bucketOfLeads.size() > 1)
			{
				masterLead = bucketOfLeads[0];
				for(integer i = 1; i < bucketOfLeads.size(); i++)
				{
					leadsToMerge.add(bucketOfLeads[i]);

					if(math.mod(i,2) == 0  || i == bucketOfLeads.size()-1)
						{	
							//I realize doing a DML operation within a FOR loop is generally bad for
							//but we are expecting these merges to be very selective and few & far inbetween.
							updateToMergeFields(leadsToMerge,masterLead); 
							mergeOperation(leadsToMerge,masterlead);
							leadsToMerge.clear();
						}
				}
			}
	}

	public void LeadConvertToContact(List<Lead> scope)
	{	
		/*
		We are only attempting to convert an LMA lead if it already shares an email address with an Existing Contact. 
		*/
		List<String> leadEmail = new List<String>();
		for(Lead l : scope)
			{
				leadEmail.add(l.Email);
			}
		List<Contact> con = [SELECT Id,Email,AccountId 
													FROM Contact
													WHERE Email IN :leadEmail];
	  Map<Id,Account> mapOfContactIdToAccount = new Map<Id,Account>();
	  Map<Id,Id> mapOfContactIdToLeadId = new Map<Id,Id>();
	  Map<Id,Lead> scopeToMap = new Map<Id,Lead>(scope);
	  List<Lead> updateLeads = new List<Lead>();
	  List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
		for(Contact c : con)
		{
			for(Lead l :scope)
			{ 
				if(c.Email == l.Email)	
				{
					if(c.AccountId == NULL)
						{
							Account newAccount = new Account(Name = l.Company);
							mapOfContactIdToAccount.put(c.Id,newAccount);
							mapOfContactIdToLeadId.put(c.Id,l.Id);	
						}
				}
			}
		}
		if(mapOfContactIdToAccount.size()>0)
		{			insert mapOfContactIdToAccount.values();
			LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE Limit 1];
			for(Contact c : con)
			{
				if(mapOfContactIdToAccount.containsKey(c.Id))
				{
					c.AccountId = mapOfContactIdToAccount.get(c.Id).Id;
					updateLeads.add(new Lead(Id = mapOfContactIdToLeadId.get(c.Id), Company =  mapOfContactIdToAccount.get(c.Id).Id));
					Database.LeadConvert lc = new Database.LeadConvert();
					lc.setDoNotCreateOpportunity(TRUE);
					lc.setConvertedStatus(convertStatus.MasterLabel);
					lc.setLeadId(mapOfContactIdToLeadId.get(c.Id));
					lc.setContactId(c.Id);
					lc.setAccountId(c.AccountId);
					leadsToConvert.add(lc);
				}
			}
			update con;
			update updateLeads;

			List<Database.LeadConvertResult> lcr =  Database.convertLead(leadsToConvert);
    	//System.assert(lcr.isSuccess());
		}
	}


	private void updateToMergeFields(List<Lead> leadsToMerge, Lead masterlead)
	{

		for(Lead l :leadsToMerge)
				{
					//Rule for Company__c
					if(masterLead.LeadSource != 'Package Installation' && l.LeadSource =='Package Installation')
						{
								masterLead.Company = l.Company;
						}
					//Rule for FirstName
					if(masterLead.FirstName == NULL && l.FirstName != NULL)
						{
								masterLead.FirstName = l.FirstName;
						}
					//Rule for Phone
					if(masterLead.Phone == NULL && l.Phone != NULL)
						{
							masterLead.Phone = l.Phone;
						}
					//Rule for License
					if(masterLead.License__c == NULL && l.License__c != NULL)
						{
							masterLead.License__c = l.License__c;
							l.License__c = NULL;
					//IF MERGE HAS LICENSE && MASTER DOES NOT --> ADD LICENSE TO MASTER
					//UNSURE if Master Lead && Merge Lead can have separate Licenses, which to take over the other. 
						}
				}				
	}

	private void mergeOperation(List<Lead> leadsToMerge, Lead masterlead)
	{
		if(masterLead != NULL)
		{
			update masterLead;
			try
			{
				Database.merge(masterLead,leadsToMerge);
			}
			catch(DmlException e)
			{		
				System.Debug('An expection occurred: '+ e.getMessage());
			}	
		}
	}
}