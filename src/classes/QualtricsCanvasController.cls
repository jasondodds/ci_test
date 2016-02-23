public with sharing class QualtricsCanvasController {

	public final Survey__c survey {get;set;}
	private final ApexPages.StandardController stdCtrl {get;set;}
    private Boolean hasQualtricsAdminPermission;
	public Boolean showSurveyDetail {get;set;}
	public Boolean showCanvas {get;set;}
	public Map<String,String> requestParamMap {get;set;}
	public String requestParamJSON {get;set;}

	public QualtricsCanvasController(ApexPages.StandardController stdController) {
		setHasQualtricsAdminPermission();
		this.stdCtrl = stdController;
		this.showSurveyDetail = false;
		this.showCanvas = false;
		this.survey = [SELECT Id, Name, Survey_ID__c, Status__c FROM Survey__c WHERE Id = :stdController.getId() LIMIT 1];
	}

    private void setHasQualtricsAdminPermission() {
        CustomPermissionsReader cpr = new CustomPermissionsReader(Survey__c.sObjectType);
        hasQualtricsAdminPermission = cpr.hasPermission('Qualtrics_Admin');
    }

	public PageReference routeSurvey() {
		PageReference routePage;
		if(survey.Id != null){
			if(survey.Status__c == 'Panel Created' || survey.Status__c == 'Edit Survey' || survey.Status__c == 'Edit Response Mappings'){
	        	routePage = new PageReference('/apex/SelectSurvey?surveyid='+survey.Id);
	        	routePage.setRedirect(true);
	        }
	        else if(survey.Status__c == 'Message'){
	        	routePage = new PageReference('/apex/SurveyMessage?surveyid='+survey.Id);
	        	routePage.setRedirect(true);
	        }
	        else{
	        	showSurveyDetail = true;
	        	renderCanvas(survey.Survey_ID__c,null);
	        	routePage = null;
	        }
		}
        else {
        	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: No valid Survey Id.');
            ApexPages.addMessage(myMsg);
        }
        return routePage;
    }

    public void renderCanvas(String surveyId, String section){
		requestParamMap = new Map<String,String>();
		requestParamMap.put('qualtricsUserToken',Qualtrics_API_Settings__c.getInstance(UserInfo.getUserId()).API_Token__c);
		requestParamMap.put('surveyId',surveyId);
		if(section != null){
			requestParamMap.put('section', section);
		}
		requestParamJSON = JSON.serialize(requestParamMap);
	}
}