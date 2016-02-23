public with sharing class SurveyMessageController {
    public Survey__c survey {get;set;}
	public String SurveyId {get;set;}
	public String MessageSubject {get;set;}
	public String FromEmail {get;set;}
	public String SentFromAddress {get;set;}
	public String FromName {get;set;}
	public String SendDate {get;set;}
	public String MessageName {get;set;}
	public String MessageContent {get;set;}
	public String MessageContentHolder {get;set;}
	public String Category {get;set;}
    public List<QualtricsAPI.LibraryMessage> messages {get; private set;}
	public Boolean isComplete {get; private set;}
	public String defaultDate {get; private set;}
    public String messageChosen {get;set;}
	public String defaultContent {get; private set;}
	public Boolean messageSent {get;set;}
	public Boolean showCampaignMessage {get;set;}
	public String customMessageName {get;set;}
	public Qualtrics_Preferences__c qualtricsSetting {get;set;}
	public Boolean hasQualtricsAdminPermission {get;set;}

	private final String DEFAULT_FROM_EMAIL = 'noreply@qemailserver.com'; 

    public List<String> ErrorList {
        get {
            if(this.ErrorList == null) {   
                this.ErrorList = new List<String>();
            }            
            return this.ErrorList;
        }
        set;
    }

    public List<String> validationErrors {
        get {
            if(this.validationErrors == null) {   
                this.validationErrors = new List<String>();
            }            
            return this.validationErrors;
        }
        set;
    }

    public SurveyMessageController() {
		hasQualtricsAdminPermission = Utils.userHasQualtricsAdminPermission();
        getQualtricsPreferences();
    }

	public List<SelectOption> getMessageOptions() {
 	 	List<SelectOption> options = new List<SelectOption>();
 	 	if(hasQualtricsAdminPermission) {
 	 		options.add(new SelectOption('','New Custom Message'));
 	 	}
 	 	for (QualtricsAPI.LibraryMessage message : this.messages){
 	 		string messageId = message.Id;
 	 		if(!string.isBlank(message.libraryID)) {
 	 			messageId += '@#' + message.libraryId;
 	 		}

	 	 	options.add(new SelectOption(messageId, message.name));
		}
 	 	return options;
  	}

    private void getQualtricsPreferences() {
    	qualtricsSetting = Qualtrics_Preferences__c.getInstance('Default');
		if(qualtricsSetting == null) {
			this.ErrorList.add('There are currently no default message settings specified. Please contact your Administrator.');
		}
		else {
			MessageSubject = qualtricsSetting.Default_Subject__c;
			if(qualtricsSetting.Default_Message_From_Type__c == QualtricsConstants.MessageFromType.RunningUser.Name()) {
				FromEmail = UserInfo.getUserEmail();
				SentFromAddress = DEFAULT_FROM_EMAIL;
				FromName = UserInfo.getName();
			}
			else if(qualtricsSetting.Default_Message_From_Type__c == QualtricsConstants.MessageFromType.Custom.Name()) {
				FromEmail = qualtricsSetting.Default_Reply_To_Email__c;
				SentFromAddress = DEFAULT_FROM_EMAIL;
				FromName = qualtricsSetting.Default_From_Name__c;
			}
			else if(qualtricsSetting.Default_Message_From_Type__c == QualtricsConstants.MessageFromType.OrgWideDefault.Name()) {
				if(string.isBlank(qualtricsSetting.Default_Org_Wide_Email_Id__c)) {
					this.ErrorList.add('Message defaults have been set to Organization Wide Email, but no Organization Wide Email has been selected. Please contact your Administrator.');
					return;
				}
				OrgWideEmailAddress owa = [select id, Address, DisplayName from OrgWideEmailAddress where Id = :qualtricsSetting.Default_Org_Wide_Email_Id__c];
				if(owa == null) {
					this.ErrorList.add('There is no Organization Wide Email Setting available. Please contact your Administrator.');
					return;
				}
				FromEmail = owa.Address;
				SentFromAddress = DEFAULT_FROM_EMAIL;
				FromName = owa.DisplayName;
			}
		}
    }

	public PageReference init(){
		this.SurveyId = apexpages.currentpage().getparameters().get('surveyid');
		this.messageSent = false;
		this.showCampaignMessage = false;
		this.Category = 'GeneralMessages'; 
		this.isComplete = false;
		datetime myDate = datetime.now();
		this.defaultDate  = myDate.format('YYYY-MM-dd HH:mm');
		this.SendDate = defaultDate;
		if(this.SurveyId == null || !Utils.isValidId(this.surveyid)){
			this.ErrorList.add('Missing or invalid survey id.');
		}
		else{
			List<Survey__c> surveyList = [SELECT Id, Name, Status__c, Survey_ID__c, Panel_ID__c, Sent_Date__c, Panel_Name__c, Panel_Count__c, OwnerID, Panel_Type__c 
											FROM Survey__c 
											WHERE Id =:this.surveyId];
			if(surveyList.size() > 0){
				this.survey = surveyList[0];
                    if(this.survey.OwnerID != UserInfo.getUserId()){
                        this.ErrorList.add('This survey does not belong to you.');
                    }
                    else if(this.survey.Status__c != 'Message'){
					this.ErrorList.add('This survey does not have the correct status for this step.');
				}
			}
			else{
                this.ErrorList.add('No Survey found for the id supplied.');
			}
			
		}
		if(!Test.isRunningTest()){
			try{
				this.messages = QualtricsAPI.getLibraryMessages();
			}
			catch(QualtricsAPI.ApiException e){
				this.ErrorList.add(e.getMessage());
			}
		}
		else {
			List<QualtricsAPI.LibraryMessage> testMessages = new List<QualtricsAPI.LibraryMessage>();
	  		testMessages.add(new QualtricsAPI.LibraryMessage());
	  		testMessages[0].Id = 'testId';
	  		testMessages[0].Name = 'Test Label';
	  		this.messages = testMessages;			
		}
		if(hasQualtricsAdminPermission) {
	        this.defaultContent = 'Follow this link to the Survey:<br/>${l://SurveyLink?d=Take the Survey}<br/><br/>Or copy and paste the URL below into your internet browser:<br/>${l://SurveyURL}<br/><br/>Follow the link to opt out of future emails:<br/>${l://OptOutLink?d=Click here to unsubscribe}';
		    messageContent = this.defaultContent;
	    }
	    else {
	    	if(this.messages.size() > 0) {
		    	messageContent = changeMessage(this.messages[0].id);
		    }
		}
		return null;
	}

	public PageReference save(){
		this.validationErrors.clear();
		if(!hasQualtricsAdminPermission && String.isBlank(messageChosen)) {
			this.validationErrors.add('Please select a saved message.');
		}
		if(String.isBlank(SendDate)){
			this.validationErrors.add('Please enter Date to send on.');
		}
		if( String.isBlank(SentFromAddress)){
			this.validationErrors.add('Please enter a From Address.');
		}
		if( String.isBlank(FromName)){
			this.validationErrors.add('Please enter a From Name.');
		}
		if( String.isBlank(FromEmail)){
			this.validationErrors.add('Please enter a Reply-To Address.');
		}
		if( String.isBlank(MessageSubject)){
			this.validationErrors.add('Please enter a Subject.');
		}
		if( String.isBlank(MessageContentHolder)){
			this.validationErrors.add('Please enter a Message.');
		}
		if( String.isBlank(survey.Panel_ID__c)){
			this.validationErrors.add('There is no Panel associated with this message.');
		}
		if( String.isBlank(survey.Survey_ID__c)){
			this.validationErrors.add('There is no Survey associated with this message.');
		}
		if( String.isBlank(messageChosen) && String.isBlank(this.customMessageName)){
			this.validationErrors.add('You must name your New Custom Message or Select a saved message');
		}
		if(this.validationErrors.size()== 0){
			String messageId;
			if(String.isBlank(messageChosen)){
				messageId = QualtricsAPI.createLibraryMessage(this.customMessageName, this.MessageContentHolder);
			}
			else{
				messageId = this.messageChosen;
			}
			sendDate = sendDate + ':00';
			if(!String.isBlank(messageid)){
				if(survey.Panel_Type__c == 'Campaign'){
					// Show the delay message
					this.showCampaignMessage = true;
					// Add the delay
					Datetime sendDateTime = DateTime.valueOf(sendDate);
					sendDate = sendDateTime.addMinutes(10).format('YYYY-MM-dd HH:mm:ss');
				}
				List<String> responseIds = QualtricsAPI.sendSurveyToPanel(sendDate, FromEmail, FromName, MessageSubject, MessageId, survey.Panel_ID__c,  survey.Survey_ID__c, SentFromAddress);

				if (responseIds.size() == 0){
					this.ErrorList.add('Unable to send survey');
					survey.Status__c = 'Error';
				}
				else {
					ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.CONFIRM,'Survey Sent' );
					ApexPages.addmessage(msg);
					messageSent = true;
					this.isComplete = true;
					survey.Message_ID__c = messageId;
					if(messageId.contains('@#')){
						survey.Message_ID__c = messageId.substringBefore('@#');
					}
					survey.Status__c = 'Sent';
				}
			}
			else {
				this.ErrorList.add('Unable to save message to Qualtrics api');
				survey.Status__c = 'Error';

			}

			update survey;
		}
		return null;

	}

	public PageReference selectSurvey(){
		return routeSurvey('Panel Created');
	}
	public PageReference editSurvey(){
		return routeSurvey('Edit Survey');
	}
	public PageReference editResponseMapping(){
		return routeSurvey('Edit Response Mappings');
	}
	public PageReference routeSurvey(String type){
        PageReference routePage = new PageReference('/apex/SelectSurvey?surveyid='+Survey.Id);
        try {
            Survey.Status__c = type;
            update Survey;
        }
        catch (Exception e) {
            this.ErrorList.add(e.getMessage());
            System.debug(e.getMessage());
        }
        routePage.setRedirect(true);
        return routePage;
    }

	@RemoteAction
	public static String changeMessage(String messageId){
		return QualtricsAPI.getLibraryMessage(messageId);
	}
}