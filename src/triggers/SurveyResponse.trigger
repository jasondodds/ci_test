trigger SurveyResponse on Survey_Response__c (before insert) {
	List<Survey_Response__c> responsesToUpdate = new List<Survey_Response__c>();
	Integer nextNumber = 0;
	for(Survey_Response__c response : Trigger.new){
		if(CSUtils.isValidId(response.Name)){
			responsesToUpdate.add(response);
		}
	}

	if(responsesToUpdate.size() > 0){
		List<Survey_Response__c> mostRecentResponses = [SELECT Name FROM Survey_Response__c ORDER BY CreatedDate DESC];
		if(mostRecentResponses.size() > 0){
			// Get the number of the most recent response
			Survey_Response__c mostRecentResponse = mostRecentResponses[0];
			if(mostRecentResponse.Name.left(4) == 'QSR-'){
				String currentSuffix = mostRecentResponse.Name.substring(4,mostRecentResponse.Name.length());
				if(CSUtils.isNumeric(currentSuffix)){
					nextNumber = Integer.valueOf(currentSuffix);
				}
				else {
					System.debug('Encountered a non-numeric QSR suffix: '+currentSuffix);
				}
			}
			else {
				System.debug('Encountered a non-QSR Survey Response name: '+mostRecentResponse.Name.left(4));
			}
		}
		else {
			System.debug('Found no existing Survey Responses');
		}
		// Update the names on the responses using 'QSR'+nextNumber
		for(Survey_Response__c response : responsesToUpdate){
			nextNumber++;
			response.Name = 'QSR-'+nextNumber;
		}
	}
}