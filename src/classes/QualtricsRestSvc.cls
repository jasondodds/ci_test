/****************************************************************************************
Name            : QualtricsRestSvc
Revision Log    : 2016-02-11 Steve Swiger - CodeScience
                : 
                : 
Use             : This class handles request from Qualtrics to update the 
                : Qualtrics_Is_Connected__c flag in the Qualtrics_API_Settings__c
                : custom setting
****************************************************************************************/
@RestResource(urlMapping='/Qualtrics/*')
global with sharing class QualtricsRestSvc
{
    @HttpPost
    global static String connectionUpdater(Integer isConnected) {
    	try {
	    	Qualtrics_API_Settings__c qSettings = Qualtrics_API_Settings__c.getInstance(UserInfo.getUserId());
	    	if(isConnected == 1){
	    		qSettings.Qualtrics_Is_Connected__c = true;
	    	}
	    	else {
	    		qSettings.Qualtrics_Is_Connected__c = false;
	    	}
	    	update qSettings;
	        return 'Success';
	    }
	    catch(exception ex) {
	    	System.debug('An Error Occurred: QualtricsService.connectionUpdater(' + ex.getLineNumber() + ') - ' + ex.getMessage());
	    	return 'Failure : An Error Occurred: QualtricsService.connectionUpdater(' + ex.getLineNumber() + ') - ' + ex.getMessage();
	    }
    }
}