public with sharing class SendSurveyButtonController {

    private ApexPages.StandardController standardController;
    private ApexPages.StandardSetController standardSetController;
    //public List<PanelMember> panelMembers {get; private set;}
    public transient List<String> panelMembers {get; private set;}
    public String panelId {get; set;}
    public String panelName {get; set;}
    public Integer panelCount {get; set;}
    public Boolean panelCreated {get; private set;}
    public Boolean panelExisted {get; private set;}
    public List<SurveyResultWrapper.Surveys> surveys  {get; private set;}
    public Map<String, String> surveyNameMap {get; private set;}
    public String selectedValue { get; set; }
    public Integer leadsSkipped {get;set;} //this represents leads AND contacst skipped because they do not have an email address
    public Map<String, String> quickStartMap {get; private set;}
    public List<String> quickStartNames {get; private set;}
    public Survey__c survey {get;set;}
    public Boolean createNewSurvey {get;set;}

    public Boolean showSelectSurvey {get;set;}
    public Boolean showEditSurveyCanvas {get;set;}
    public Boolean showResponseMappingCanvas {get;set;}
    public Map<String,String> requestParamMap {get;set;}
    public String requestParamJSON {get;set;}
    public List<String> ErrorList {
        get {
            if(this.ErrorList == null) {   
                this.ErrorList = new List<String>();
            }            
            return this.ErrorList;
        }
        set;
    }
    public Boolean hasCredentials {
        get {
            if(this.hasCredentials == null) {   
                this.hasCredentials = Utils.userHasQualtricsSettings(UserInfo.getUserId());
            }            
            return this.hasCredentials;
        }
        set;
    }
    //used by QualtricsLoginForm.component
    public SendSurveyButtonController getPageCont(){
        return this;
    }
    private List<String> embeddedDataFields = new List<String>();
    private List<String> contactFields = new List<String>{'Account.Name', 'name', 'email', 'title', 'description','birthdate', 'accountid', 'leadsource' , 'mailingstreet', 'mailingcity' , 'mailingstate' , 'mailingpostalcode' ,'mailingcountry', 'mobilephone', 'firstname', 'lastname', 'otherstreet' , 'othercity', 'otherstate' ,'otherpostalcode', 'othercountry' ,'otherphone', 'homephone', 'donotcall', 'hasoptedoutofemail'}; 
    private List<String> leadFields = new List<String>{'company', 'description', 'industry', 'leadsource', 'status', 'email','annualrevenue', 'company', 'fax', 'mobilephone', 'name', 'firstname', 'lastname', 'numberofemployees', 'phone', 'rating', 'title', 'website' , 'hasoptedoutoffax', 'donotcall', 'hasoptedoutofemail'}; 
    private List<String> campaignFields = new List<String>{'enddate', 'startdate', 'status', 'name'};

    public SendSurveyButtonController(){

    }

    public SendSurveyButtonController(ApexPages.StandardSetController controller){
        this.standardSetController = controller;
        if (!Test.isRunningTest()){
            this.standardSetController.addFields(new List<String>{'Name'});
        }
        sObject theObject = this.standardSetController.getRecord();

        if(theObject.getSObjectType() == Campaign.sObjectType){
            if (!Test.isRunningTest()){
                this.standardSetController.addFields(campaignFields);
           }

        }

        if(theObject.getSObjectType() == Contact.sObjectType){
            if (!Test.isRunningTest()){
                this.standardSetController.addFields(contactFields);
           }
        }

        if(theObject.getSObjectType() == Lead.sObjectType ){
            if (!Test.isRunningTest()){
                this.standardSetController.addFields(leadFields);
           }
        }
        this.panelCreated = false;
        init();       
    }

    public SendSurveyButtonController(ApexPages.StandardController controller) {
        //currently this method only works for single campaign (not contact or lead)
        this.standardController = controller;       
        if (!Test.isRunningTest()){
            this.standardController.addFields(new List<String>(this.campaignFields));
        }
        sObject theObject = this.standardController.getRecord();
        this.panelCreated = false;
        init();       
    }

    public PageReference init(){
        String surveyId = apexpages.currentpage().getparameters().get('surveyid');
        this.showSelectSurvey = true;
        this.showEditSurveyCanvas = false;
        this.showResponseMappingCanvas = false;
        surveyNameMap = new Map<String, String>();
        if(surveyId != null){
            if(Utils.isValidId(surveyId)){
                List<Survey__c> surveyList = [SELECT Id, Name, Status__c, Survey_ID__c, Panel_ID__c, Panel_Name__c, Panel_Count__c, OwnerID
                                                FROM Survey__c 
                                                WHERE Id =:surveyId];
                if(surveyList.size() > 0){
                    this.survey = surveyList[0];
                    if(this.survey.OwnerID != UserInfo.getUserId()){
                        this.ErrorList.add('This survey does not belong to you.');
                    }
                    else if(this.survey.Status__c != 'Panel Created'){
                        this.ErrorList.add('This survey does not have the correct status for this step.');
                    }
                    this.panelCreated = false;
                    this.panelExisted = true;
                    this.panelId = this.survey.Panel_ID__c;
                    this.panelName = this.survey.Panel_Name__c;
                    this.panelCount = Integer.valueOf(this.survey.Panel_Count__c);
                    this.leadsSkipped = 0;
                    //this.panelMembers = new List<PanelMember>(); 
                    this.panelMembers = new List<String>(); 
                }
                else {
                    this.ErrorList.add('No survey found with the supplied id.');
                }
            }
            else {
                this.ErrorList.add('Invalid survey id.');
            }

        }
        else{//no surveyid on the url, starting fresh
            this.survey = new Survey__c();
            this.panelCreated = false;
            this.panelExisted = false;
            //this.panelMembers = new List<PanelMember>();
            this.panelMembers = new List<String>(); 
            this.panelName = '';
            this.panelCount = 0;
            this.panelId = '';
       }

        this.quickStartMap = new Map<String, String>();
        this.quickStartNames = new List<String>(); 
        if(!Test.isRunningTest()){
            if(this.hasCredentials){
                queryAllSurveys();   
            }
            else{
                //create default so page will display
                this.quickStartNames = new List<String>(); 
            }
                
        }
        return null;
    }


    public PageReference createPanelFromContactList(){
        Boolean success;
        if(this.hasCredentials){
            this.leadsSkipped = 0;
            this.panelName = 'Contact List ' + Datetime.now();
            List<Contact> contacts = (List<Contact>) standardSetController.getSelected();
            if(contacts.size() > 0){
                for(Contact contact : contacts){
                    if(!String.isBlank(contact.Email)){          
                        //this.panelmembers.add(new PanelMember(contact));           
                        this.panelmembers.add(PanelMember.makeMemberString(contact));
                    }
                    else{
                        this.leadsSkipped++;
                    }
                }
                if(contacts.size() > this.leadsSkipped){
                    success = createPanel(this.panelName, this.panelMembers);
                    //Technically, panel created should not be set until a future method has checked the status of the call to createpanel
                    this.survey.Status__c = 'Panel Created';
                    upsert survey;
                }
                else{
                    this.ErrorList.add('No contacts with email adresses were selected, so no panel  was created.');
                }
            }
            else{
                this.ErrorList.add('No contacts selected.');
            }
        }
        //else do nothing
        return null;
    }

    public PageReference createPanelFromLeadList(){
        Boolean success;
        if(this.hasCredentials){

            this.leadsSkipped = 0;
            this.panelName = 'Lead List ' + Datetime.now();
            List<Lead> leads = (List<Lead>) StandardSetController.getSelected();
            if (leads.size() > 0){
                for (Lead lead : leads){
                    if(!String.isBlank(lead.Email)){
                        //this.panelMembers.add(new PanelMember(lead));
                        this.panelMembers.add(PanelMember.makeMemberString(lead));
                    }
                    else{
                        this.leadsSkipped++;
                    }
                }
                if(leads.size() > this.leadsSkipped){
                    success = createPanel(this.panelName, this.panelMembers);
                    //Technically, panel created should not be set until a future method has checked the status of the call to createpanel
                    this.survey.Status__c = 'Panel Created';
                    upsert survey;
                }
                else {
                    this.ErrorList.add('No leads with email addresses were selected, so no panel was created.');
                }
            }
            else{
                this.ErrorList.add('No leads selected.');
            }
        }//else do nothing
        return null;
    }

    public PageReference createPanelFromCampaign(){
        if(this.hasCredentials){
            Campaign campaign = (Campaign)standardController.getRecord();
            List<Campaign> campaigns = new List<Campaign>{campaign};
            this.panelName = campaign.name + ' ' + DateTime.now();
            if(campaigns.size() > 0){
                // should we count panel members where email != null
                // to make sure we have SOME recipients 
                this.panelId = QualtricsAPI.createPanel(this.panelName);
                if(this.panelId != null){
                   panelCreated = true;
                    this.survey.Panel_ID__c = panelId;
                    this.survey.Panel_Name__c = panelName;
                    this.panelMembers = addPanelMembers(campaigns);
                    //
                    this.survey.Status__c = 'Panel Created';
                    upsert survey;
                }
                //else{
                //    this.ErrorList.add('No recipients found for this campaign.');
                //}
            }
        }//else do nothing
        return null;    
    }

    //public PageReference createPanelFromCampaign(){
    //    if(this.hasCredentials){
    //        Campaign campaign = (Campaign)standardController.getRecord();
    //        List<Campaign> campaigns = new List<Campaign>{campaign};
    //        this.panelName = campaign.name + ' ' + DateTime.now();
    //        if(campaigns.size() > 0){
    //            this.panelMembers = queryPanelMembers(campaigns);
    //            if (panelMembers.size() > 0){
    //                Boolean success = createPanel(this.panelName, this.panelMembers);
    //                //Technically, panel created should not be set until a future method has checked the status of the call to createpanel
    //                this.survey.Status__c = 'Panel Created';
    //                upsert survey;
    //            }
    //            else{
    //                this.ErrorList.add('No recipients found for this campaign.');
    //            }
    //        }
    //    }//else do nothing
    //    return null;    
    //}

    public PageReference createPanelFromCampaignList(){
        PageReference pageRef;
        if(this.hasCredentials){

            List<Campaign> campaigns = (List<Campaign>) standardSetController.getSelected(); 
            System.debug('$$$ campaigns.size is ' + campaigns.size());
            
            if(campaigns.size() > 0){
                this.panelName = campaigns.size() + ' Selected Campaigns ' + Datetime.now();
                this.panelMembers = queryPanelMembers(campaigns);
                if (panelMembers.size() > 0){
                    Boolean success = createPanel(this.panelName, this.panelMembers);
                    //Technically, panel created should not be set until a future method has checked the status of the call to createpanel
                    this.survey.Status__c = 'Panel Created';
                    upsert survey;
                }
                else{
                    this.ErrorList.add('No recipients with email addresses found for the campaign(s) selected.');
                }
            }
            else{
                this.ErrorList.add('No campaigns selected.');
            }
        }

        return pageRef;    
    }

//placeholder to be able to save during changes
public List<String> queryPanelMembers(List<Campaign> theCampaignList){
//    public List<PanelMember> queryPanelMembers(List<Campaign> theCampaignList){
        List<String> memberStrings = new List<String>(); 
        List<PanelMember> members = new List<PanelMember>(); 
        Integer skippedCount = 0;
        for(Campaign campaign : theCampaignList){
            for(Contact contact : queryContacts(campaign.Id)){
                if(contact.Email != null){
                    memberStrings.add(PanelMember.makeMemberString(contact, campaign));
                    //members.add(new PanelMember(contact, campaign));
                }
                else {
                    skippedCount += 1;
                }
            }
            for(Lead lead : queryLeads(campaign.Id)){
                if(lead.Email != null){
                    memberStrings.add(PanelMember.makeMemberString(lead, campaign));
                    //members.add(new PanelMember(lead));

                }
                else {
                    skippedCount += 1;
                }
            }       
        }
        leadsSkipped = skippedCount;
        //return members;
        return memberStrings;
    }

    public List<String> addPanelMembers(List<Campaign> theCampaignList){
//    public List<PanelMember> queryPanelMembers(List<Campaign> theCampaignList){
        List<String> memberStrings = new List<String>(); 
        List<PanelMember> members = new List<PanelMember>(); 
        Integer skippedCount = 0;
        for(Campaign campaign : theCampaignList){
            for(Contact contact : [SELECT Id, FirstName, LastName, Phone, Email, Account.Name, AccountID, Birthdate, Description, DoNotCall, HasOptedOutOfEmail, HomePhone, LeadSource, MailingStreet, MailingState, MailingCity, MailingPostalCode, MailingCountry, MobilePhone, Name, OtherPhone, OtherStreet, OtherState, OtherCity, OtherCountry, OtherPostalCode, Title  FROM Contact WHERE Id IN
                                 (SELECT ContactId FROM CampaignMember WHERE CampaignId= :campaign.Id AND contactId != null) ]){            
                if(contact.Email != null){                    
                   memberStrings.add(PanelMember.makeMemberString(contact, campaign));
                    //members.add(new PanelMember(contact, campaign));
                }
                else {
                    skippedCount += 1;
                }
                System.debug('$$$ approximate amount of memory (in bytes) that has been used for the heap: '+Limits.getHeapSize()); 
                System.debug('$$$ total amount of memory (in bytes) that can be used for the heap: '+Limits.getLimitHeapSize()); 

                 if (Limits.getHeapSize() > 275000)  { 
                        //6,000,000 is allowed total
                    QualtricsAPI.addPanelMembers(this.panelId, memberStrings);
                    memberStrings.clear();
                }


            }
            for(Lead lead : [SELECT Id, FirstName, LastName, Phone, AnnualRevenue, Company, Description, Email, Fax, Industry, LeadSource, Status, MobilePhone, Name, NumberOfEmployees, Rating, Title, Website, DoNotCall, HasOptedOutOfFax, HasOptedOutOfEmail FROM Lead WHERE Id In (SELECT LeadId FROM CampaignMember WHERE CampaignId = :campaign.Id AND LeadId != null ) ]){
                    if(lead.Email != null){
                        //members.add(new PanelMember(lead));
                        memberStrings.add(PanelMember.makeMemberString(lead, campaign));

                    }
                    else {
                        skippedCount += 1;
                    }
                 System.debug('$$$ approximate amount of memory (in bytes) that has been used for the heap: '+Limits.getHeapSize()); 
                System.debug('$$$ total amount of memory (in bytes) that can be used for the heap: '+Limits.getLimitHeapSize()); 
                   if (Limits.getHeapSize() > 275000)  { 
                        //6,000,000 is allowed total
                    QualtricsAPI.addPanelMembers(this.panelId, memberStrings);
                    memberStrings.clear();
                }

            }       
        }
        QualtricsAPI.addPanelMembers(this.panelId, memberStrings);
                    
        leadsSkipped = skippedCount;
        //return members;
        return memberStrings;
    }


    public Boolean createPanel(String panelName, List<String> memberList){
    //public Boolean createPanel(String panelName, List<PanelMember> memberList){
         Integer membersAdded = 0;
        if(memberList.size() > 0 && !String.isBlank(panelName)){
            panelId = QualtricsAPI.createPanel(panelName);
            if(panelId != null){
                //membersAdded =  
                QualtricsAPI.addPanelMembers(panelId, memberList);
                 System.debug('$$$ membersAdded is ' + membersAdded);
                 //Technically, panel created should not be set until a future method has checked the status of the call to createpanel
                panelCreated = true;
                this.survey.Panel_ID__c = panelId;
                this.survey.Panel_Name__c = panelName;
                ///TODO determine Panel Count and use future call to assign it to survey
                upsert survey;
           }
        }
        return true;
    }

    public PageReference queryAllSurveys(){
        this.quickStartNames = new List<String>(); 
        if (this.ErrorList.size() == 0 && this.hasCredentials){
            this.surveys = QualtricsAPI.queryActiveSurveys();
            if(this.surveys.size() > 0){
                for(SurveyResultWrapper.Surveys survey : this.surveys){
                    surveyNameMap.put(survey.SurveyID, survey.SurveyName);// survey.SurveyID);
                }
            }
            Map<String, Quick_Start_Survey__c> quickStartsMap = Quick_Start_Survey__c.getAll();
            for(Quick_Start_Survey__c quickStart : quickStartsMap.values()){
               this.quickStartNames.add(quickStart.Name);
            }
        }
        return null;
    }

    public List<Contact> queryContacts(Id campaignId){
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Phone, Email, Account.Name, AccountID, Birthdate, Description, DoNotCall, HasOptedOutOfEmail, HomePhone, LeadSource, MailingStreet, MailingState, MailingCity, MailingPostalCode, MailingCountry, MobilePhone, Name, OtherPhone, OtherStreet, OtherState, OtherCity, OtherCountry, OtherPostalCode, Title  FROM Contact WHERE Id IN
                                 (SELECT ContactId FROM CampaignMember WHERE CampaignId= :campaignId AND contactId != null) ];
        System.debug('$$$ contacts.size = '+ contacts.size());
        return contacts;
    }

    public List<Lead> queryLeads(Id campaignId){
        List<Lead> leads = [SELECT Id, FirstName, LastName, Phone, AnnualRevenue, Company, Description, Email, Fax, Industry, LeadSource, Status, MobilePhone, Name, NumberOfEmployees, Rating, Title, Website, DoNotCall, HasOptedOutOfFax, HasOptedOutOfEmail FROM Lead WHERE Id In
                            (SELECT LeadId FROM CampaignMember WHERE CampaignId = :campaignId AND LeadId != null ) ];
        System.debug('$$$ leads.size = ' + leads.size());
        return leads;
    }

    public PageReference save(){
        String surveyId = '';
        Set<String> quickStartSurveyNames = new Set<String>();
        quickStartSurveyNames.addAll(this.quickStartNames);
        String surveyName;
        System.debug('$$$ selected value is ' + selectedValue);
        if(surveyNameMap.containsKey(selectedValue)){
            surveyId = selectedValue;//surveyNameMap.get(selectedValue);
            surveyName = surveyNameMap.get(selectedValue);
        }
        else if(quickStartSurveyNames.contains(selectedValue)){
            surveyId = QualtricsAPI.importSurvey('New '+selectedValue, selectedValue);
            surveyName = 'New '+ selectedValue;
        }
        this.survey.Survey_ID__c = surveyId;
        this.survey.Status__c = 'Message';
        this.survey.Survey_Title__c = surveyName;
        upsert survey; 

        PageReference pageRef = Page.SurveyMessage;
        pageRef.getParameters().put('surveyid', survey.Id); 
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference editSurvey(){
        String surveyId = '';
        Set<String> quickStartSurveyNames = new Set<String>();
        quickStartSurveyNames.addAll(this.quickStartNames);
        String surveyName;
        System.debug('$$$ selected value is ' + selectedValue);
        if(surveyNameMap.containsKey(selectedValue)){
            surveyId = selectedValue;
            surveyName = surveyNameMap.get(selectedValue);
        }
        else if(quickStartSurveyNames.contains(selectedValue)){
            surveyId = QualtricsAPI.importSurvey('New '+selectedValue, selectedValue);
            surveyName = 'New '+ selectedValue;
        }else if(selectedValue == 'New Survey'){
            surveyId = QualtricsAPI.importSurvey('New Blank Survey', selectedValue);
            surveyName = 'New Blank Survey';
        }
        System.debug('***** survetId = '+surveyId);
        this.survey.Survey_ID__c = surveyId;
        this.survey.Status__c = 'Message';
        this.survey.Survey_Title__c = surveyName;
        upsert survey; 

        PageReference routePage;
        this.showSelectSurvey = false;
        this.showEditSurveyCanvas = true;
        this.showResponseMappingCanvas = false;
        renderCanvas(survey.Survey_ID__c,null);
        routePage = null;
        return routePage;
    }

    public PageReference editResponseMapping(){
        PageReference routePage;
        showSelectSurvey = false;
        showEditSurveyCanvas = false;
        showResponseMappingCanvas = true;
        renderCanvas(survey.Survey_ID__c,'ResponseMappingsEditor');
        routePage = null;
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
        System.debug(requestParamJSON);
    }
}