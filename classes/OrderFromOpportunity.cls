public with sharing class OrderFromOpportunity {

	private final Opportunity oppty;


	public OrderFromOpportunity(ApexPages.StandardController controller) 
	{
				oppty =	[SELECT Id, AccountId, csboss__License__c
								 FROM Opportunity 
	  						 WHERE Id = :controller.getId()];
	}

	public PageReference CheckForAccount()
	{
		if(oppty.AccountId != NULL)
			{
				Id newOrderId; 
			  newOrderId = populateOrderFields(oppty);
			 	 if(newOrderId != NULL)
			  	{
			  		PageReference pr = new PageReference('/' + string.valueOf(newOrderId));
			  		pr.setRedirect(TRUE);
			  		return pr;
			  	}
			}
		else
			{
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please add an Account to this Opportunity.'));
			}
		return null;
	}

	private Id populateOrderFields(Opportunity oppty)
	{
		List<Opportunity> workingOppty = new List<Opportunity>();
		workingOppty.add(oppty);
		List<csboss__BOSS_Order__c> newOrder = new List<csboss__BOSS_Order__c>();

		Account acct = [SELECT Id FROM Account WHERE Id = :oppty.AccountId];

		List<Contact> con = new List<Contact>([SELECT Id, AccountId
																					 FROM Contact 
																					 WHERE AccountId = :acct.Id]);

		Map<Id,Id> mapOfAccountAndContact = new Map<Id,Id>();

		if(con.size() > 0)
			{
				for(Contact ct : con)
					{
						mapOfAccountAndContact.put(ct.AccountId,ct.Id);
					}
			}



		for(Opportunity opp : workingOppty)
			{
					csboss__BOSS_Order__c createOrder = new csboss__BOSS_Order__c();
					createOrder.csboss__Opportunity__c = opp.Id;
					createOrder.csboss__Account__c = opp.AccountId; 
					if(mapOfAccountAndContact.containsKey(opp.AccountId))
						{
							createOrder.csboss__Contact__c = mapOfAccountAndContact.get(opp.AccountId);
						}
					if(opp.csboss__License__c != NULL)
						{	
							createOrder.csboss__License__c = opp.csboss__License__c;
						}
					newOrder.add(createOrder);
			}
		if(newOrder.size()>0)
				{
					return createNewOrder(newOrder);
				}
		else
				{
					return null;
				}
	}

	private Id createNewOrder(List<csboss__BOSS_Order__c> newOrder)
	{
		insert newOrder;
		return newOrder[0].Id;
	}
}