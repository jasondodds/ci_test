public with sharing class SetupController {
	@TestVisible
	public Boolean hasRemoteSiteSetting {get; private set;}
	public String host {get; private set;}
	public String metadataResponse {get; set;}

	public void initPage() {
		host = ApexPages.currentPage().getHeaders().get('Host');
		
		try {
			httpRequest httpRequest = new HttpRequest();
			httpRequest.setEndpoint('https://' + host); 
			httpRequest.setMethod('GET');
			
			HttpResponse httpResponse = (new Http()).send(httpRequest);
			hasRemoteSiteSetting = true;

			// add the custom setting for GitHub Oauth return url
			OAuth_Settings__c oauth = OAuth_Settings__c.getOrgDefaults();
			oauth.Redirect_Url__c = 'http://security.codescience.com?state=https://'+host+'/apex/UserSetup';
			upsert oauth;

		} catch (Exception e) {
			hasRemoteSiteSetting = false;
		}
	}

	public void handleMetadataResponse() {
		if (String.isBlank(metadataResponse)) {
			hasRemoteSiteSetting = true;
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, metadataResponse));
			hasRemoteSiteSetting = false;
		}
	}
}