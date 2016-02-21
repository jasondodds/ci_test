public with sharing class UserSetupController {
	public String ciToken {get;set;}

    public Boolean githubTokenPresent {
        get{
            UserDefinition__c uds = UserDefinition__c.getInstance(UserInfo.getUserId());
            System.debug(uds);
            if(uds != null){
                //if the code is in the url and its not null we just saved and validated the github token otherwise we validate it 
            	if(uds.VCS_Token__c != null && ApexPages.CurrentPage().getParameters().containsKey('code') || (uds.VCS_Token__c != null && GithubService.isValidToken(uds.VCS_Token__c))) {
                	return true;
            	}
            }
            return false;
    	}
        set;
    }
    public Boolean ciTokenPresent {
        get{
            UserDefinition__c uds = UserDefinition__c.getInstance(UserInfo.getUserId());
            System.debug(uds);
            if(uds != null){
            	if((uds.CI_Token__c != null && ApexPages.CurrentPage().getParameters().containsKey('validToken')) || (uds.CI_Token__c != null && CircleCIService.isValidToken(uds.CI_Token__c))){
                	return true;
            	}
            }
            return false;
    	}
        set;
    }
    public void init() {
        GithubService.createOAuthSettings();
    }

    public PageReference githubOauth() {
        return GithubService.oauthRedirect();
    }

    public PageReference saveCIToken() {
        PageReference ref = Page.UserSetup;
        ref.setRedirect(true);
        if(ciToken != null) {
            if(CircleCIService.isValidToken(ciToken)) {
                UserDefinition__c ud = UserDefinition__c.getInstance(UserInfo.getUserId());
                ud.CI_Token__c = ciToken;
                upsert ud;
                ref.getParameters().put('validToken', 'true');
            }  
        }
        return ref;
    }
}