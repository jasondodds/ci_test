public with sharing class OpportunityRenewal {
	
/*
	- carry over Product Line Items
*/
	public List<Opportunity> recentClosedWon {get;set;}

	public OpportunityRenewal() {
			
	}
	public static string GetCreateableFieldsSOQL(String objectName, String whereClause)
	{
		String selects = '';
		if(whereClause == NULL || whereClause == '') {return null;}
		Map<String,Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
		List<String> selectFields = new List<String>();

		if(fMap != NULL)
		{
			for (Schema.SObjectField ft : fMap.values())
			{ // loop through all field tokens (ft)
         Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
          if (fd.isCreateable())
          { // field is creatable
              selectFields.add(fd.getName());
          }
       }
		}
		 if (!selectFields.isEmpty())
		 {
        for (string s:selectFields)
        {
          selects += s + ',';
       }
        if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}

        }    
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;   
  }


	public void CreateClone()
	{
		recentClosedWon = [SELECT Id FROM Opportunity WHERE StageName = 'closed won'];
system.debug('recentClosedWon: '+recentClosedWon);
		List<Opportunity> newRecords = new List<Opportunity>();
		system.debug('recentClosedWon: '+recentClosedWon);
		try
			{
				for(Opportunity opp: recentClosedWon)
				{
					Opportunity clone = new Opportunity();
					clone = opp.clone(false,true);
					clone.StageName = 'Renewal';
					newRecords.add(clone);
				}
system.debug('newRecords: '+newRecords);
				insert newRecords;
			}
			catch (DmlException e)
			{
				System.Debug('The following error has occurred: ' +e.getMessage());
			}
	}
}