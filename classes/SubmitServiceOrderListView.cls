public with sharing class SubmitServiceOrderListView 
{

	private ApexPages.StandardSetController standardController;
	private List<CHANNEL_ORDERS__Service_Order__c> masterList = new List<CHANNEL_ORDERS__Service_Order__c>();

	public SubmitServiceOrderListView(ApexPages.StandardSetController standardController)
	{
		this.standardController = standardController;
		masterList = standardController.getSelected();
	}

	public PageReference SubmitOrders()
	{
		try
		{
			for(CHANNEL_ORDERS__Service_Order__c s: masterList)
			{
				if(Test.IsRunningTest())
					{
						//this is not bulkified --> because it's for test only.
						s.CHANNEL_ORDERS__Service_Order_Status__c = 'Received';
						update s;
					}
				else
				{
						CHANNEL_ORDERS.ServiceOrderProcessor.sendOrder(s.Id);
				}
			}
			Id rdObj = [SELECT Id FROM CHANNEL_ORDERS__Service_Order__c LIMIT 1].Id;
			String newURL = String.valueOf(rdObj);
			String rdURL = newURL.left(3);
			PageReference pr = new PageReference('/'+rdURL);
			pr.setRedirect(TRUE);
			return pr;
		}
		catch(Exception e)
		{
			System.Debug('======> Exception: ' +e.getMessage());
			return null;
		}
	}
}