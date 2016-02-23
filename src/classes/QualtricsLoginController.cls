public with sharing class QualtricsLoginController  {
	public String userName {get;set;}
	public String password {get;set;}
	public String token {get;set;}
	public Boolean isComplete {get;set;}
	public Boolean hasMadeCanvasRequest {get;set;}
    public String requestParamJSON {get;set;}
	public SendSurveyButtonController owningPage {get;set;}
	public QualtricsSettingsController qPage {get;set;}
	public QualtricsVocalizeController vPage {get;set;}

	public List<String> errorList {
        get {
            if(this.errorList == null) {   
                this.errorList = new List<String>();
            }            
            return this.errorList;
        }
        set;
    }
	public QualtricsLoginController() {
		isComplete = false;
		hasMadeCanvasRequest = false;
	}

	public PageReference save(){

		this.errorList.clear();
		//The next two lines are not in keeping with the style guide, but are done nonetheless because of code coverage issues.
		if(String.isBlank(userName)){ this.errorList.add('Please enter a username.'); }
		if(String.isBlank(password) && String.isBlank(token)){ this.errorList.add('Please enter a password or token.'); }

		if(this.errorList.size()== 0){
			Map<String, String> tokenMap;
			if(!String.isBlank(token)){
			 	tokenMap = new Map<String,String>();
			 	tokenMap.put('Success', token);
			}
			else {
				tokenMap = QualtricsAPI.retrieveUserApiToken(userName, password);
			}

			//known possible values for token 'You do not have the required permissions', 'Incorrect Username or Password', the xml returend by the call
			//keys for tokenMap may be Success, Exception, and Error
			if(tokenMap.containsKey('Success')){
				Map<String, String> userIdMap = QualtricsAPI.retrieveUserId(userName, tokenMap.get('Success'));
				if(userIdMap.containsKey('Success')){
					Qualtrics_API_Settings__c settings = Qualtrics_API_Settings__c.getInstance(UserInfo.getUserId());
					settings.User_Name__c = userName;
					settings.API_Token__c = tokenMap.get('Success');
					settings.User_Id__c = userIdMap.get('Success');
					try{
						upsert settings;
					}
					catch(Exception e){
						System.debug('Error (1) ' + e.getMessage() );
						if(e.getMessage().contains('DUPLICATE_VALUE')) {
							this.errorList.add('You have attempted to connect a user which is already authenticated to this salesforce.com org. Please contact your administrator for help or try another username.');
						}
						else {
							this.errorList.add('Unable to save settings. Error: ' + e.getMessage());
						}
					}

				}
				else if(userIdMap.containsKey('Exception')){
					System.debug('Exception (2): ' + userIdMap.get('Exception'));
					this.errorList.add('Exception: ' + userIdMap.get('Exception'));
					Utils.sendDebugEmail(new String[] {'qualtrics@codescience.com'},'userIdmap is ' + String.valueOf(userIdMap));

				}

			}

			else if(tokenMap.containsKey('Error')){
				String message = tokenMap.get('Error');
				System.debug('Error (3) ' + message);
				if(message == 'You do not have the required permissions.'){
					this.errorList.add('Your Qualtrics User doesn\'t appear to have API access. Please check your Qualtrics settings or contact your Qualtrics administrator.');
				
				}
				else{
					this.errorList.add(message);
					//Utils.sendDebugEmail(new String[] {'qualtrics@codescience.com'},'token map is ' + String.valueOf(tokenMap));
				}
			}
			else if(tokenMap.containsKey('Exception')){
				this.errorList.add('Exception: '+ tokenMap.get('Exception'));
				System.debug('Exception (4): ' + tokenMap.get('Exception'));
				Utils.sendDebugEmail(new String[] {'qualtrics@codescience.com'},'token map is ' + String.valueOf(tokenMap));
			}

			else { 
			}

		}
		if(this.errorList.size() == 0){
			this.isComplete = true;
			renderCanvas();
		}

		return null;
	}

	public PageReference setComplete() {
		if(this.errorList.size() == 0){
			this.isComplete = true;
			this.hasMadeCanvasRequest = true;
			//This was modified to handle multiple page controllers
			if(owningPage != null) { 
				owningPage.hasCredentials = true; 
			}
			else if(qPage != null) { 
				qPage.hasCredentials = true; 
			}
			else if(vPage != null) { 
				vPage.hasCredentials = true;
				vPage.checkVocalizePermissions();
			}
		}

		return null;
	}

    //Sets values for Canvas Signed Request
	private void renderCanvas(){
        Map<String,String> requestParamMap = new Map<String,String>();
        requestParamMap.put('qualtricsUserToken',Qualtrics_API_Settings__c.getInstance(UserInfo.getUserId()).API_Token__c);
        requestParamMap.put('AuthOnly','true');
        requestParamJSON = JSON.serialize(requestParamMap);
    }
}