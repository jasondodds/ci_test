public with sharing class BOSSOrderController {

	public PageReference GoToOpportunities()
	{
		Id rdObj = [SELECT Id FROM Opportunity LIMIT 1].Id;
			String newURL = String.valueOf(rdObj);
			String rdURL = newURL.left(3);
			PageReference pr = new PageReference('/'+rdURL);
		pr.setRedirect(TRUE);
		return pr;
	}

	public PageReference GoBack()
	{
		Id rdObj = [SELECT Id FROM csboss__BOSS_Order__c LIMIT 1].Id;
			String newURL = String.valueOf(rdObj);
			String rdURL = newURL.left(3);
			PageReference pr = new PageReference('/'+rdURL);
		pr.setRedirect(TRUE);
		return pr;
	}

}