public with sharing class QualtricsAPI {

	public QualtricsAPI() {	
	}
	
	public QualtricsAPI(Qualtrics_API_Settings__c settings){
	}

	public static String createPanel(String name){
		String panelId;
		String requestString = 'Request=createPanel&Name=SFDC'+name;
		HttpResponse response = QualtricsAPI.processApiRequest(requestString);
		return QualtricsAPI.parseJSONValue(response, 'PanelID');
	}

	public static HttpResponse processApiRequest(String requestPayload){
		System.debug('** QTRIX: API Request Body = ' + requestPayload);
		HttpResponse response = QualtricsAPI.makeApiRequest(requestPayload, true, true);
		System.debug('** QTRIX: API Response Body = ' + response.getBody());
		return response;
	}

	public static HttpResponse processApiRequest(String requestPayload, Boolean useLibraryId){
		System.debug('** QTRIX: API Request Body = ' + requestPayload);
		HttpResponse response = QualtricsAPI.makeApiRequest(requestPayload, useLibraryId, true);
		System.debug('** QTRIX: API Response Body = ' + response.getBody());
		return response;
	}

	public static List<SurveyResultWrapper.Surveys> queryActiveSurveys(){
		List<SurveyResultWrapper.Surveys> allSurveys = queryAllSurveys();
		List<SurveyResultWrapper.Surveys> activeSurveys = new List<SurveyResultWrapper.Surveys>();
		for(SurveyResultWrapper.Surveys survey : allSurveys){			
			if(survey.SurveyStatus == 'Active'){
				activeSurveys.add(survey);
			}
		}
		return activeSurveys;
	}

	public static List<SurveyResultWrapper.Surveys> queryAllSurveys(){
		HttpResponse response = QualtricsAPI.processApiRequest('Request=getSurveys');
		SurveyResultWrapper resultWrapper = SurveyResultWrapper.parse(response.getBody());
		return resultWrapper.result.surveys;
	} 

	public static List<QualtricsAPI.LibraryMessage> getLibraryMessages(){
		Qualtrics_API_Settings__c settings = Qualtrics_API_Settings__c.getInstance(UserInfo.getUserId());
		String settingUsername = settings.User_Name__c;
		String settingToken = settings.API_Token__c;		

		List<LibraryMessage> messages = new List<LibraryMessage>();
		Map<String,String> tempUserInfo = new Map<String,String>();
		if(Test.isRunningTest()) { 
			tempUserInfo.put('response.getBody','{"Meta":{"Status":"Success","Debug":""},"Result":{"UserData":{"UserID":"UR_88uCZoW8wlvqdPT","UserName":"jon.doe@example.com","UserFirstName":"Jon","UserLastName":"Doe","UserAccountType":"Standard - Qualtrics","UserAccountTypeID":"UT_3dBUKOs5wAT2mLW","UserAccountBrandID":"gobbletygook","UserAccountExpirationDate":"0000-00-00","UserAccountCreationDate":"2015-01-05 17:05:32","DivisionID":null,"UserLanguage":"EN","UserEmail":"jon.doe@example.com","PasswordLastChanged":"2015-04-14 19:33:16","UserAccountStatus":"Active","LoginHistory":[1429736113,1429729712,1429729702,1429659835,1429656943,1429656936,1429651800,1429651674,1429648481,1429641440,1429638435,1429636197,1429634109,1429633010,1429570063,1429563112,1429558096,1429474325,1429287750,1429287689,1429219078,1429214744,1429213359,1429213185,1429213164,1429213163,1429209875,1429207445,1429204691,1429195009],"UserUnsubscribed":0,"UdsRestricted":false,"AvailableProducts":["ControlPanel"],"Users":{"ControlPanel":{"salesforceappdev":{"AccountStatus":"Active","UserId":"UR_88uCZoW8wlvqdPT"}}},"SFData":{"refreshToken":"5Aep861eWO5D.7wJBvGnbfPvhcIgMIavomlO8Dnw_Rjm7LWMnJ2fzmIFVtMy7YGIFde0JX3P_TVb0LveT1.YT3A","sessionToken":"null","instanceUrl":"https:na3.salesforce.com"}},"Libraries":[{"Name":"Jon Doe","ID":"UR_88uCZoW8wlvqdPT"},{"Name":"Qualtrics Library","ID":"GR_0rJTu2lC3cYWmrO"}]}}');
		}
		else {
			tempUserInfo = retrieveUserId(settingUsername,settingToken);
		}
		Set<String> libraryIds = parseLibraryIds(tempUserInfo.get('response.getBody'));

		For(String libraryId : libraryIds) {
		    HttpResponse libResponse = QualtricsAPI.processApiRequest('Request=getLibraryMessages&LibraryID=' + libraryId);
		    String responseBody = libResponse.getBody();
		    JSONParser libParser = JSON.createParser(responseBody);
		    
		    while(libParser.nextToken() != null){ 
		        if((libParser.getCurrentToken() == JSONToken.FIELD_NAME) ){
		            String fieldName = libParser.getText();
		            JSONToken nextToken = libParser.nextToken();
		            if(fieldName == 'INVITE'){
		                if(nextToken == JSONToken.START_OBJECT){
		                    while(libParser.nextToken() != JSONToken.END_OBJECT){
		                        QualtricsAPI.LibraryMessage newMsg = new QualtricsAPI.LibraryMessage();
		                        newMsg.LibraryId = libraryId;
		                        newMsg.Id = libParser.getText();
		                        libParser.nextToken();
		                        newMsg.Name = libParser.getText();
		                        messages.add(newMsg);
		                    }
		                    break;
		                }
		                else if(nextToken == JSONToken.START_ARRAY ){
		                    break;
		                }
		            }
		        }
		    }
		}
		if(messages.size() == 0) {
            QualtricsAPI.LibraryMessage nullMessage = new QualtricsAPI.LibraryMessage();
            nullMessage.id = 'nullPlaceholder';
            nullMessage.name = 'No Invite Messages in your Account';
            messages.add(nullMessage);
		}
		return messages;
	}  

	private static Set<String> parseLibraryIds(string responseBody) {
		Set<String> libraryIds = new Set<String>();
		JSONParser parser = JSON.createParser(responseBody);

		while(parser.nextToken() != null){ 
		    if((parser.getCurrentToken() == JSONToken.FIELD_NAME) ){
		        String fieldName = parser.getText();
		        JSONToken nextToken = parser.nextToken();
		        if(fieldName == 'Libraries'){
		            if(nextToken == JSONToken.START_ARRAY){
		                while(parser.nextToken() != JSONToken.END_ARRAY){
		                    if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'Name'){
		                        parser.nextToken();
		                        string tempLibName = parser.getText();
		                        parser.nextToken();
		                        if(parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'ID'){
		                            parser.nextToken();
		                            libraryIds.add(parser.getText());
		                        }
		                    }                           
		                }
		            }
		        }
		    }
		}
		return libraryIds;
	}

	public static String getLibraryMessage(String messageId){
		String message;
		Boolean useLibraryId = true;
		if(messageId !='nullPlaceholder'){
			String requestVal = 'Request=getLibraryMessage&MessageID=';
			if(messageId.contains('@#')){
				List<String> messageItems = messageId.split('@#');
				requestVal += messageItems[0]; //messageId
				requestVal += '&LibraryId=' + messageItems[1];
				useLibraryId = false;
			}
			else {
				requestVal += messageId;
			}
			HttpResponse response = QualtricsAPI.processApiRequest(requestVal,useLibraryId);
			JSONParser parser = JSON.createParser(response.getBody());
				while(parser.nextToken() != null){ 

					if(parser.getCurrentToken() == JSONToken.FIELD_NAME ){
						String fieldName = parser.getText();
						parser.nextToken();
						if(fieldName == 'Result'){//handles first case
							parser.nextToken();
							message = parser.getText();
							if(message == 'EN'){ //handles second case
								parser.nextToken();
								message = parser.getText();
							}
							break;
						}
					}
				}				
			}
		return message;

	}

	public static String createLibraryMessage(String messageName, String message){
		Boolean hadErrors = false;
		HttpResponse response = QualtricsAPI.processApiRequest('Request=createLibraryMessage&Name='+EncodingUtil.urlEncode(messageName, 'UTF-8')+'&Message='+EncodingUtil.urlEncode(message, 'UTF-8')+'&Category=InviteEmails');
		String messageId = QualtricsAPI.parseJSONValue(response, 'MessageId');
		if(messageId == null){ 
			hadErrors = true;
		}
		else {
			hadErrors = false;
		}
		return messageId;
	}
	
	/* email distribution id, distribution queue id*/
	public static List<String> sendSurveyToPanel(String sendDate, String fromEmail, String fromName, String subject, String messageId, String panelId, String surveyId){
		return sendSurveyToPanel(sendDate, fromEmail, fromName, subject, messageId, panelId, surveyId, '');
	}

	public static List<String> sendSurveyToPanel(String sendDate, String fromEmail, String fromName, String subject, String messageId, String panelId, String surveyId, String sentFromEmail) {
		Boolean hadErrors = false; //Not actually doing anything with this yet
		Boolean hasLibraryId = false;
		String libraryId = '';
		String UserId = Qualtrics_API_Settings__c.getInstance(UserInfo.getUserId()).User_Id__c;
		List<String> idList = new List<String>();

		if(messageId.contains('@#')){
			List<String> messageItems = messageId.split('@#');
			messageId = messageItems[0]; //messageId
			libraryId = messageItems[1];
			hasLibraryId = true;
		}
		Map<String, String> jsonPayload = new Map<String, String>();
		jsonPayload.put('Request','sendSurveyToPanel');
		jsonPayload.put('SendDate',sendDate);
		jsonPayload.put('SentFromAddress',sentFromEmail);
		jsonPayload.put('FromEmail',fromEmail);
		jsonPayload.put('FromName',fromName);
		jsonPayload.put('Subject',subject);
		jsonPayload.put('MessageID',messageId);
		jsonPayload.put('MessageLibraryID',(hasLibraryId ? libraryId : UserId));
		jsonPayload.put('PanelID',panelId);
		jsonPayload.put('PanelLibraryID',UserId);
		jsonPayload.put('SurveyID',surveyId);

		String parameters; 
		for(String field: jsonPayload.keySet()){
			parameters += '&'+field+'='+EncodingUtil.urlEncode(jsonPayload.get(field), 'UTF-8');
		}
		HttpResponse response = QualtricsAPI.processApiRequest(parameters);

		String emailDistributionId = QualtricsAPI.parseJSONValue(response, 'EmailDistributionID');
		String distributionQueueId = QualtricsAPI.parseJSONValue(response, 'DistributionQueueID');
		if(emailDistributionId == null){ 
			hadErrors = true;
		}
		else {
			hadErrors = false;
 		}
 		idList.add(emailDistributionId);
 		idList.add(distributionQueueId);
		return idList;

	}

	public static String importSurvey(String surveyName, String quickStartName){
		String UserId = Qualtrics_API_Settings__c.getInstance(UserInfo.getUserId()).User_Id__c;
		String importFormat = 'MSQ';
		String url = '';
		String requestString = '';
		String surveyId = '';
		if(quickStartName != null){
			Map<String, Quick_Start_Survey__c> quickStartsMap = Quick_Start_Survey__c.getAll();
			Quick_Start_Survey__c quickStart = quickStartsMap.get(quickStartName);
			if(quickStart != null){
				importFormat = 'QSF';
				url = quickStart.Static_Resource_Location__c;
				System.debug('Importing QSF from: '+url);
			} 
			else {
				System.debug('Cannot find Quick Start Survey with name of '+quickStartName);
			}
		}

		requestString = 'Request=importSurvey&Name=SFDC'+surveyName+'&Activate=1'+'&OwnerID='+UserId+'&ImportFormat='+importFormat;
		if(url != ''){
			requestString += '&URL='+url;
		}
		HttpResponse response = QualtricsAPI.processApiRequest(requestString);
		surveyId = QualtricsAPI.parseJSONValue(response, 'SurveyID');
		if(surveyId == null){
			//TODO error 
		}
		return surveyId;
	}

	//returns Status and Data values in map. Success , userId OR Exception, xml back from call OR Error, errormessage
	public static Map<String, String> retrieveUserApiToken(String userName, String password){
		String apiEndPoint = 'https://survey.qualtrics.com/WRAPI/ControlPanel/api.php';
		String endpoint = apiEndPoint + '?';
		Map<String, String> endpointParams = new Map<String, String>();
		endpointParams.put('&Format=','JSON');
		endpointParams.put('&User=', EncodingUtil.urlEncode(userName, 'UTF-8' ));
		endpointParams.put('&Password=',EncodingUtil.urlEncode(Password , 'UTF-8' ));
		endpointParams.put('&Request=','getUserToken');
		endpointParams.put('&Version=','2.5');
		endpointParams.put('&AutoGenerate=','1');
		String data = '';
		for(String key : endpointParams.keySet()){
			data += key + endpointParams.get(key);
			endpoint += key + endpointParams.get(key);
		}
		HttpRequest request = new HttpRequest();
		request.setBody(data);
		request.setMethod('POST');
		request.setEndPoint(endpoint);
		request.setHeader('Content-type', 'application/x-www-form-urlencoded');
		HttpResponse response = new Http().send(request);
		String status;
		String message;
		if(response.getBody().startsWith('<XML>')){
			status = 'Exception';
		}
		else{
			status =  QualtricsAPI.parseJSONValue(response, 'Status');
		}
		if(status.equals('Exception')){
			message= response.getBody();
		}
		else if(status.equals('Error')){
			message =  QualtricsAPI.parseJSONValue(response, 'ErrorMessage');
		}
		else{
			 message = QualtricsAPI.parseJSONValue(response, 'Result');
		}		
		return new Map<String, String>{status => message, 'request.getBody' => request.getBody(), 'response.getBody' => response.getBody() }; 
	}

	public static Map<String,String> retrieveUserId(String userName, String apiToken){
		String apiEndPoint = 'https://survey.qualtrics.com/WRAPI/ControlPanel/api.php';
		String endpoint = apiEndPoint + '?';
		Map<String, String> endpointParams = new Map<String, String>();
		endpointParams.put('&Request=','getUserInfo');
		endpointParams.put('&Format=','JSON');
		if(!string.isBlank(userName)) {
			endpointParams.put('&User=', EncodingUtil.urlEncode(userName, 'UTF-8' ));
		}
		if(!string.isBlank(apiToken)) {
			endpointParams.put('&Token=',EncodingUtil.urlEncode(apiToken , 'UTF-8' ));
		}
		endpointParams.put('&Version=','2.5');
		String data = '';
		for(String key : endpointParams.keySet()){
			data += key + endpointParams.get(key);
			endpoint += key + endpointParams.get(key);
		}

		HttpRequest request = new HttpRequest();
		request.setBody(data);
		request.setMethod('POST');
		request.setEndPoint(endpoint);
		request.setHeader('Content-type', 'application/x-www-form-urlencoded');
		HttpResponse response = new Http().send(request);
		String message;
		String status;
		if(response.getBody().startsWith('<XML>')) {
			status = 'Exception';
			message = response.getBody();
		}
		else{
			status =  QualtricsAPI.parseJSONValue(response, 'Status');		
		}
		if(status.equals('Error')){
			message =  QualtricsAPI.parseJSONValue(response, 'ErrorMessage');
		}
		else if (status.equals('Success')){
			message = QualtricsAPI.parseJSONValue(response, 'UserID');

		}
		return new Map<String, String>{status => message, 'request.getBody' => request.getBody(), 'response.getBody' => response.getBody() }; 
	}

	public static Boolean retrieveUserVocalizePermissions() {
		Qualtrics_API_Settings__c settings = Qualtrics_API_Settings__c.getInstance(UserInfo.getUserId());
		String settingToken = settings.API_Token__c;
		String settingUserId = settings.User_Id__c;
		if(String.isBlank(settingToken) || String.isBlank(settingUserId) ){
			throw new ApiException('Missing Qualtrics API Settings for current user.');
		}
		String endpoint = 'https://s.qualtrics.com/API/v3/users/' + settingUserId;
		HttpRequest request = new HttpRequest();
		request.setMethod('GET');
		request.setEndPoint(endpoint);
		request.setHeader('X-API-TOKEN', settingToken);
		HttpResponse response = new Http().send(request);
		String useVocalize = QualtricsAPI.parseJSONArray(response, 'useVocalize', 'calculatedState');
		if(useVocalize == 'on') {
			return true;
		}
		return false;
	}

	public static void addPanelMembers(String panelId, List<String> panelMembers){
		if(panelMembers.size() > 0){
			//need to pass into api call 10,000 at a time (or less if we run into heap/cpu limits)
			Integer loopLimit = 10000;//10000;
			Integer numberAdded = 0;
			List<String> groupedList = new List<String>();

			Integer loops = (Integer)Math.ceil(panelMembers.size() / loopLimit) + 1;
			
			Integer counter = 0;
			Integer innerMax = 0;
			for(Integer i=0; i < loops; i++){
				groupedList.clear();
				innerMax = panelMembers.size() - counter > loopLimit ? loopLimit : panelMembers.size() - counter;
				
				for(Integer j = 0; j < innerMax ; j++ ){
					groupedList.add(panelMembers[counter]);
					counter++;
				}

		 		HttpResponse response;
				String requestString = '['; 
				for(Integer k = 0;  k < groupedList.size(); k++){
					requestString += groupedList[k];
					if(k < groupedList.size() -1){
						requestString += ',';
					}
				} 		
				requestString += ']';
				requestString = '&panelMembers='+EncodingUtil.urlEncode(requestString, 'UTF-8');		
				response = QualtricsAPI.doRequestNewAPI('/v1/panels/'+panelId+'/members', requestString);
				numberAdded += innerMax;
			}
		}
	}

	public static integer getPanelMemberCount(String panelId, String libraryId){
		Integer panelMemberCount = 0;
		String apiEndPoint = 'https://survey.qualtrics.com/WRAPI/ControlPanel/api.php';
		String endpoint = apiEndPoint + '?';
		Qualtrics_API_Settings__c settings = Qualtrics_API_Settings__c.getInstance(UserInfo.getUserId());
		String settingUsername = settings.User_Name__c;
		String settingToken = settings.API_Token__c;
		String settingUserId = settings.User_Id__c;
		Map<String, String> endpointParams = new Map<String, String>();
		endpointParams.put('&Request=','getPanelMemberCount');
		endpointParams.put('&Format=','JSON');
		endpointParams.put('&User=', EncodingUtil.urlEncode(settingUsername, 'UTF-8' ));
		endpointParams.put('&Token=',EncodingUtil.urlEncode(settingToken , 'UTF-8' ));
		endpointParams.put('&Version=','2.5');
		endpointParams.put('&PanelID=',panelId);
		endpointParams.put('&LibraryID=',String.isBlank(libraryId) ? settingUserId : libraryId);
		String data = '';
		for(String key : endpointParams.keySet()){
			data += key + endpointParams.get(key);
			endpoint += key + endpointParams.get(key);
		}

		HttpRequest request = new HttpRequest();
		request.setBody(data);
		request.setMethod('POST');
		request.setEndPoint(endpoint);
		request.setHeader('Content-type', 'application/x-www-form-urlencoded');
		HttpResponse response = new Http().send(request);
		panelMemberCount = integer.valueOf(QualtricsAPI.parseJSONValue(response, 'Count'));
		return panelMemberCount;
	}

	public static HttpResponse doRequestNewAPI( String urlExtension, String data){
		String endPoint = 'https://s.qualtrics.com/API'+ urlExtension; //+ '?';
		Qualtrics_API_Settings__c settings = Qualtrics_API_Settings__c.getInstance(UserInfo.getUserId());
		String settingUsername = settings.User_Name__c;
		String settingToken = settings.API_Token__c;
		String settingUserId = settings.User_Id__c;
		if(String.isBlank(settingUsername) || String.isBlank(settingToken) || String.isBlank(settingUserId) ){
			throw new ApiException('Missing Qualtrics API Settings for current user.');
		}
		data = 'apiToken='+settingToken+data;
		HttpRequest request = new HttpRequest();
		request.setBody(data);
		request.setMethod('POST');
		request.setEndPoint(endpoint);
		request.setHeader('Content-type', 'application/x-www-form-urlencoded');
		HttpResponse response;
		try{
			System.debug('REQUEST: ' + request);
			System.debug('REQUEST BODY: ' + request.getBody());
			response = new Http().send(request);
			System.debug('RESPONSE: ' + response);
			System.debug('RESPONSE BODY: ' + response.getBody());
			ErrorResponseWrapper errorwrapper = ErrorResponseWrapper.parse(response.getBody());
			if(errorwrapper.Meta.Status == 'Error'){
				throw new ApiException('Qualtrics API Error: '+errorwrapper.Meta.QualtricsErrorCode+' - '+errorwrapper.Meta.ErrorMessage);

			}
		}
		catch(Exception e){
			System.debug('EXCEPTION: ' + e.getMessage());
			throw new ApiException(e.getMessage());
		}
		return response;

	}

	public static HttpResponse makeApiRequest(String data){
		return QualtricsAPI.makeApiRequest(data,true);
	}
	public static HttpResponse makeApiRequest(String data, Boolean useLibraryId){ 
		return QualtricsAPI.makeApiRequest(data,true,true);
	}

	public static HttpResponse makeApiRequest(String data, Boolean useLibraryId, Boolean useToken){ 

		String apiEndPoint = 'https://survey.qualtrics.com/WRAPI/ControlPanel/api.php';
		String version  = '2.5';
		String endpoint = apiEndPoint + '?';
		Qualtrics_API_Settings__c settings = Qualtrics_API_Settings__c.getInstance(UserInfo.getUserId());
		String settingUsername = settings.User_Name__c;
		String settingToken = settings.API_Token__c;
		String settingUserId = settings.User_Id__c;
		if(String.isBlank(settingUsername) || String.isBlank(settingToken) || String.isBlank(settingUserId) ){
			throw new ApiException('Missing Qualtrics API Settings for current user.');
		}

		Map<String, String> endpointParams = new Map<String, String>();
		endpointParams.put('&User=',EncodingUtil.urlEncode(settingUsername, 'UTF-8'));
		if(useToken){
			endpointParams.put('&Token=',EncodingUtil.urlEncode(settingToken, 'UTF-8'));
		}
		endpointParams.put('&Format=','JSON');
		endpointParams.put('&Version=',version);
		if(useLibraryId){
			endpointParams.put('&LibraryID=',EncodingUtil.urlEncode(settingUserId, 'UTF-8'));
		}
		else if(data.contains('Request=getLibraryMessage&')) {
			//getting from a different Library!
			String libId = data.substringAfterLast('=');
			endpointParams.put('&LibraryID=',EncodingUtil.urlEncode(libId, 'UTF-8'));	
			data = data.substringBefore('&LibraryId=');
		}
		for(String key : endpointParams.keySet()){
			endpoint += key + endpointParams.get(key);
		}

		HttpRequest request = new HttpRequest();
		request.setBody(data);
		request.setMethod('POST');
		request.setEndPoint(endpoint);
		request.setHeader('Content-type', 'application/x-www-form-urlencoded');
		HttpResponse response;
		try{
			System.debug('ENDPOINT: ' + endpoint);
			System.debug('REQUEST: ' + request);
			System.debug('REQUEST BODY: ' + request.getBody());
			response = new Http().send(request);
			System.debug('RESPONSE: ' + response);
			System.debug('RESPONSE BODY: ' + response.getBody());
			ErrorResponseWrapper errorwrapper = ErrorResponseWrapper.parse(response.getBody());
			//Excluding the error for Library Message for 'No permission to use messages.'
			if(errorwrapper.Meta.Status == 'Error' && !(data.contains('getLibraryMessages') && errorwrapper.Meta.QualtricsErrorCode == 'ESEC17')) {
				throw new ApiException('Qualtrics API Error: '+errorwrapper.Meta.QualtricsErrorCode+' - '+errorwrapper.Meta.ErrorMessage);

			}
		}
		catch(Exception e){
			System.debug('EXCEPTION: ' + e.getMessage());
			throw new ApiException(e.getMessage());
		}
		return response;
	}

	public static String parseJSONValue(HttpResponse response, String fieldToFind ){
		String value;
		JSONParser parser = JSON.createParser(response.getBody());
		while(parser.nextToken() != null){ 

			if((parser.getCurrentToken() == JSONToken.FIELD_NAME) ){
				String fieldName = parser.getText();
		        System.debug('$$$ fieldName: ' + fieldName);
				parser.nextToken();
				System.debug('>>>>>>>>>>>>>>> parser.getText(): ' + parser.getText());
				if(fieldName == fieldToFind){
					value = parser.getText();
					break;
				}
			}
		}
		return value;		
	}

	public static String parseJSONArray(HttpResponse response, String arrayToFind, String fieldToFind ){
		String value;
		JSONParser parser = JSON.createParser(response.getBody());
		while(parser.nextToken() != null){ 

			if((parser.getCurrentToken() == JSONToken.FIELD_NAME) ){
				String fieldName = parser.getText();
		        System.debug('$$$ fieldName: ' + fieldName);
				parser.nextToken();
				System.debug('>>>>>>>>>>>>>>> parser.getText(): ' + parser.getText());
				if(fieldName == arrayToFind){
					while(parser.nextToken() != null){
						system.debug('Current Token: ' + parser.getCurrentToken());
						fieldName = parser.getText();
						System.debug('^^^^^^^^^^^^^^^^^^ fieldName: ' + fieldName);
						if(fieldName == fieldToFind) {
							parser.nextToken();
							value = parser.getText();
							break;
						}
					}
				}
			}
		}
		return value;		
	}

	public class LibraryMessage{
		public String id {get; set;}
		public String name {get; set;}
		public String libraryId {get;set;}
	}

	public class PermissionsMessage {
		public String permissionName {get;set;}
		public Boolean hasPermission {get;set;}
	}
	  
	public class ApiException extends Exception{}
	
}