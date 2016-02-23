/****************************************************************************************
Name            : QualtricsVocalizeController
Revision Log    : 2016-02-02 Steve Swiger - CodeScience
                : 
                : 
Use             : This class handles request for Vocalize permission from QualtricsAPI
                : displaying different regions on QualtricsVocalize.page based on the
                : value(s) returned, and updating user and org custom settings. 
****************************************************************************************/
public with sharing class QualtricsVocalizeController {
    public String requestParamJSON {get;set;}
    public Boolean userHasVocalizeAccess {get;set;}
    public Boolean orgHasVocalizeAccess {get;set;}

    public Boolean hasCredentials {
        get {
            if(this.hasCredentials == null) {   
                this.hasCredentials = Utils.userHasQualtricsSettings(UserInfo.getUserId());
            }            
            return this.hasCredentials;
        }
        set;
    }

	public QualtricsVocalizeController() {
		userHasVocalizeAccess = false;
        orgHasVocalizeAccess = Qualtrics_API_Settings__c.getOrgDefaults().Has_Vocalize_Permission__c;
	}

    //Called by action on QualtricsVocalize.page
	public void checkVocalizePermissions() {
        Qualtrics_API_Settings__c settings = Qualtrics_API_Settings__c.getInstance(UserInfo.getUserId());
        if(settings != null && !String.isBlank(settings.API_Token__c) && !String.isBlank(settings.User_Id__c)) {
    		userHasVocalizeAccess = QualtricsAPI.retrieveUserVocalizePermissions();
    		if(userHasVocalizeAccess) {
    			renderCanvas();
    		}
            updateSettings(userHasVocalizeAccess);
        }
        else {
            userHasVocalizeAccess = false;
        }
	}

    //used by QualtricsLoginForm.component
    public QualtricsVocalizeController getPageCont(){
        return this;
    }

    //Sets values for Canvas Signed Request
	private void renderCanvas(){
        Map<String,String> requestParamMap = new Map<String,String>();
        Qualtrics_API_Settings__c setting = Qualtrics_API_Settings__c.getInstance(UserInfo.getUserId());
        if(setting != null) {
            requestParamMap.put('qualtricsUserToken',setting.API_Token__c);
            requestParamMap.put('product','Vocalize');
            requestParamJSON = JSON.serialize(requestParamMap);
        }
    }

    //Update vocalize permission value on API Custom Setting(s)
    private void updateSettings(Boolean hasVocalizeAccess) {
        Qualtrics_API_Settings__c settings = Qualtrics_API_Settings__c.getInstance(UserInfo.getUserId());
        settings.Has_Vocalize_Permission__c = hasVocalizeAccess;
        upsert settings;

        if(hasVocalizeAccess) {
            settings = Qualtrics_API_Settings__c.getOrgDefaults();
            if(string.isBlank(settings.User_Name__c)) {
                settings.User_Name__c = 'OrgDefault';
            }
            settings.Has_Vocalize_Permission__c = hasVocalizeAccess;
            upsert settings;
        }        
    }
}