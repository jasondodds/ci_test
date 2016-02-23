global with sharing class SendSurveyButtonController {

    private ApexPages.StandardController standardController;
    private ApexPages.StandardSetController standardSetController;
    private Boolean hasQualtricsAdminPermission;
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
    public Integer recordsSkipped {get;set;} //this represents leads AND contacst skipped because they do not have an email address
    public Integer recordsTotal {get;set;}
    public Integer recordsNullEmail {get;set;}
    public Integer recordsOptOut {get;set;}
    public Map<String, String> quickStartMap {get; private set;}
    public List<String> quickStartNames {get; private set;}
    public Survey__c survey {get;set;}
    public Boolean createNewSurvey {get;set;}
    public Set<id> missingEmailOptoutFields {get;set;}

    public Boolean showSelectSurvey {get;set;}
    public Boolean showEditSurveyCanvas {get;set;}
    public Boolean showResponseMappingCanvas {get;set;}
    public Boolean showAuthOnlyCanvas {get;set;}
    public Map<String,String> requestParamMap {get;set;}
    public String requestParamJSON {get;set;}

    private Map<String,Boolean> leadOptOutsAccessible {
        get {
            Map<String,Boolean> retMap = new Map<String,Boolean>();
            for(String field : PanelMember.leadOptOutFieldSet) {
                retMap.put(field,PanelMember.leadAccessibleFields.contains(field) ? true : false);
            }
            return retMap;
        }
        set;

    }
    private Map<String,Boolean> contactOptOutsAccessible {
        get {
            Map<String,Boolean> retMap = new Map<String,Boolean>();
            for(String field : PanelMember.contactOptOutFieldSet) {
                retMap.put(field,PanelMember.contactAccessibleFields.contains(field) ? true : false);
            }
            return retMap;
        }
        set;
    }

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
    //used by SelectSurvey page (because it doesn't use this as an extension)
    public Boolean hasAdminPermission {
        get {
            if(this.hasQualtricsAdminPermission == null) {
                setHasQualtricsAdminPermission();
            }
            return this.hasQualtricsAdminPermission;
        }
    }

    //used by QualtricsLoginForm.component
    public SendSurveyButtonController getPageCont(){
        setHasQualtricsAdminPermission();
        return this;
    }

    private List<String> embeddedDataFields = new List<String>();
    private Set<String> contactFields = new Set<String>{'Account.Name', 'name', 'email', 'title', 'description','birthdate', 'accountid', 'leadsource' , 'mailingstreet', 'mailingcity' , 'mailingstate' , 'mailingpostalcode' ,'mailingcountry', 'mobilephone', 'firstname', 'lastname', 'otherstreet' , 'othercity', 'otherstate' ,'otherpostalcode', 'othercountry' ,'otherphone', 'homephone', 'donotcall', 'hasoptedoutofemail'}; 
    private Set<String> leadFields = new Set<String>{'company', 'description', 'industry', 'leadsource', 'status', 'email','annualrevenue', 'company', 'fax', 'mobilephone', 'name', 'firstname', 'lastname', 'numberofemployees', 'phone', 'rating', 'title', 'website' , 'hasoptedoutoffax', 'donotcall', 'hasoptedoutofemail'}; 
    private List<String> campaignFields = new List<String>{'enddate', 'startdate', 'status', 'name'};

    public SendSurveyButtonController(){
        setHasQualtricsAdminPermission();
        missingEmailOptoutFields = new Set<Id>();
    }

    public SendSurveyButtonController(ApexPages.StandardSetController controller){
        setHasQualtricsAdminPermission();
        missingEmailOptoutFields = new Set<Id>();
        this.standardSetController = controller;
        contactFields.addAll(PanelMember.addOptOutFieldsToSet('Contact'));
        leadFields.addAll(PanelMember.addOptOutFieldsToSet('Lead'));

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

                this.standardSetController.addFields(new List<String>(contactFields));
           }
        }

        if(theObject.getSObjectType() == Lead.sObjectType ){
            if (!Test.isRunningTest()){
                this.standardSetController.addFields(new List<String>(leadFields));
           }
        }
        this.panelCreated = false;
        init();       
    }

    private void setHasQualtricsAdminPermission() {
        CustomPermissionsReader cpr = new CustomPermissionsReader(Survey__c.sObjectType);
        hasQualtricsAdminPermission = cpr.hasPermission('Qualtrics_Admin');
    }

    public SendSurveyButtonController(ApexPages.StandardController controller) {
        //currently this method only works for single campaign (not contact or lead)
        setHasQualtricsAdminPermission();
        missingEmailOptoutFields = new Set<Id>();
        this.standardController = controller;       
        if (!Test.isRunningTest()){
            this.standardController.addFields(new List<String>(this.campaignFields));
        }
        sObject theObject = this.standardController.getRecord();
        this.panelCreated = false;
        init();       
    }

    public PageReference init(){
        Id surveyId = apexpages.currentpage().getparameters().get('surveyid');
        if(ApexPages.currentPage().getUrl().split('apex/')[1].contains('SelectSurvey')) {
            checkDeletedCheckboxFields();
        }

        this.showSelectSurvey = true;
        this.showEditSurveyCanvas = false;
        this.showResponseMappingCanvas = false;
        this.showAuthOnlyCanvas = false;
        surveyNameMap = new Map<String, String>();
        if(surveyId != null){
            if(Utils.isValidId(surveyId)){
                List<Survey__c> surveyList = [SELECT Id, Name, Status__c, Survey_ID__c, Panel_ID__c, Panel_Name__c, Panel_Count__c, OwnerID, Panel_Type__c 
                                                FROM Survey__c 
                                                WHERE Id =:surveyId];
                if(surveyList.size() > 0){
                    this.survey = surveyList[0];
                    if(this.survey.OwnerID != UserInfo.getUserId()){
                        this.ErrorList.add('This survey does not belong to you.');
                    }
                    this.panelCreated = true;
                    this.panelExisted = true;

                    if(this.Survey.Status__c == 'Panel Created'){
                        this.showSelectSurvey = true;
                        this.showEditSurveyCanvas = false;
                        this.showResponseMappingCanvas = false;
                    }
                    else if(this.Survey.Status__c == 'Edit Survey'){
                        this.showSelectSurvey = false;
                        this.showEditSurveyCanvas = true;
                        this.showResponseMappingCanvas = false;
                        renderCanvas(this.survey.Survey_ID__c, null);
                    }
                    else if(this.Survey.Status__c == 'Edit Response Mappings'){
                        this.showSelectSurvey = false;
                        this.showEditSurveyCanvas = false;
                        this.showResponseMappingCanvas = true;
                        renderCanvas(this.survey.Survey_ID__c, 'ResponseMappingsEditor');
                    }
                    this.panelId = this.survey.Panel_ID__c;
                    this.panelName = this.survey.Panel_Name__c;
                    this.panelCount = Integer.valueOf(this.survey.Panel_Count__c);
                    this.recordsSkipped = 0;
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
        else{
            this.survey = new Survey__c();
            this.panelCreated = false;
            this.panelExisted = false;
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

    public PageReference checkDeletedCheckboxFields() {
        Utils.clearEmailOptOutSettingForMissingField();
        return null;
    }

    public PageReference createPanelFromContactList(){
        try {
            Boolean success;
            this.recordsSkipped = 0;
            recordsTotal = 0;
            recordsNullEmail = 0;
            recordsOptOut = 0;
            if(this.hasCredentials){
                this.panelName = 'Contact List ' + Datetime.now();
                List<Id> selectedContactIds = new List<Id>();
                for(Contact selectedContact : (List<Contact>)standardSetController.getSelected()){
                    selectedContactIds.add(selectedContact.Id);
                }
                List<Contact> contacts = Database.query('SELECT Account.Name, '+CSUtils.join(PanelMember.contactAccessibleFields, ', ')+' FROM Contact WHERE ID in :selectedContactIds');
                panelMembers = new List<String>();
                if(contacts.size() > 0){
                    for(Contact contact : contacts){
                        recordsTotal++;
                        if(!String.isBlank(contact.Email)){
                            for(String field : contactOptOutsAccessible.keySet()) {

                                if(contactOptOutsAccessible.get(field) == true && contact.get(field) == true) {
                                    recordsOptOut++;
                                    break;
                                }
                            }
                        }
                        else {
                            recordsNullEmail++;
                        }
                    }
                    this.recordsSkipped = recordsNullEmail + recordsOptOut;
                    if(recordsTotal > this.recordsSkipped){
                        this.survey.Status__c = 'Panel Created';
                        this.survey.Panel_Type__c = 'Contact';
                        this.survey.Sent__c = recordsTotal - this.recordsSkipped;
                        this.survey.Email_Missing__c = recordsNullEmail;
                        this.survey.Email_Opt_Out__c = recordsOptOut;
                        upsert survey;
                        for(Contact contact : contacts){
                            if(!String.isBlank(contact.Email)){
                                boolean optOutAccessible = false;
                                boolean optedOut = false;
                                for(String field : contactOptOutsAccessible.keySet()) {
                                    if(contactOptOutsAccessible.get(field) == true) {
                                        optOutAccessible = true;
                                        if(contact.get(field) == true) {
                                            optedOut = true;
                                            break;
                                        }
                                    }
                                }
                                if(!optOutAccessible || (optOutAccessible && !optedOut)) {
                                    panelmembers.add(PanelMember.makeMemberString(contact, survey.Id));
                                }
                            }
                        }
                        createPanel(this.panelName, panelMembers, survey.Id);
                        panelCreated = true;   
                    }
                    else{
                        this.ErrorList.add('There were no records selected where email address was populated and Email Opt-out was false, so no panel was created.');
                    }
                }
                else{
                    this.ErrorList.add('No contacts selected.');
                }
            }
        }
        catch (QualtricsAPI.ApiException e){
            System.debug('QualtricsAPI.ApiException: ' + e.getMessage());
        }
        catch (Exception e) {
            System.debug(e.getMessage());
        }
        
        return null;
    }

    public PageReference createPanelFromLeadList(){
        try {
            Boolean success;
            this.recordsSkipped = 0;
            recordsTotal = 0;
            recordsNullEmail = 0;
            recordsOptOut = 0;
            if(this.hasCredentials){
                this.panelName = 'Lead List ' + Datetime.now();
                List<Id> selectedLeadIds = new List<Id>();
                for(Lead selectedLead : (List<Lead>)standardSetController.getSelected()){
                    selectedLeadIds.add(selectedLead.Id);
                }
                List<Lead> leads = Database.query('SELECT '+CSUtils.join(PanelMember.leadAccessibleFields, ', ')+' FROM Lead WHERE ID in :selectedLeadIds');
                panelMembers = new List<String>();
                if (leads.size() > 0){
                    for (Lead lead : leads){
                        recordsTotal++;
                        if(!String.isBlank(lead.Email)){
                            for(String field : leadOptOutsAccessible.keySet()) {
                                if(leadOptOutsAccessible.get(field) == true && lead.get(field) == true) {
                                    recordsOptOut++;
                                    break;
                                }
                            }
                        }
                        else {
                            recordsNullEmail++;
                        }
                    }
                    this.recordsSkipped = recordsNullEmail + recordsOptOut;
                    if(recordsTotal > this.recordsSkipped){
                        this.survey.Status__c = 'Panel Created';
                        this.survey.Panel_Type__c = 'Lead';
                        this.survey.Sent__c = recordsTotal - this.recordsSkipped;
                        this.survey.Email_Missing__c = recordsNullEmail;
                        this.survey.Email_Opt_Out__c = recordsOptOut;
                        upsert survey;
                        for (Lead lead : leads){
                            if(!String.isBlank(lead.Email)){
                                boolean optOutAccessible = false;
                                boolean optedOut = false;
                                for(String field : leadOptOutsAccessible.keySet()) {
                                    if(leadOptOutsAccessible.get(field) == true) {
                                        optOutAccessible = true;
                                        if(lead.get(field) == true) {
                                            optedOut = true;
                                            break;
                                        }
                                    }
                                }
                                if(!optOutAccessible || (optOutAccessible && !optedOut)) {
                                    panelmembers.add(PanelMember.makeMemberString(lead, survey.Id));
                                }
                            }

                        }
                        createPanel(this.panelName, panelMembers, survey.Id);
                        panelCreated = true;   
                    }
                    else {
                        this.ErrorList.add('There were no records selected where email address was populated and Email Opt-out was false, so no panel was created.');
                    }
                }
                else{
                    this.ErrorList.add('No leads selected.');
                }
            }
        }
        catch (Exception e) {
            this.ErrorList.add(e.getMessage());
            System.debug(e.getMessage());
        }
        
        return null;
    }

    public void createCampaignPanel(List<Campaign> campaigns){
        Set<Id> campaignIds = new Set<Id>();
        for(Campaign campaign : campaigns){
            campaignIds.add(campaign.Id);
        }
        campaigns = [SELECT Id, Name, NumberOfContacts, NumberOfLeads FROM Campaign WHERE Id IN :campaignIds];
        try {
            if(this.hasCredentials){
                Integer numTotalCampaignMembers = 0;
                for(Campaign campaign : campaigns){
                    numTotalCampaignMembers += campaign.NumberOfContacts + campaign.NumberOfLeads;
                }
                if(campaigns.size() > 0){
                    this.panelName = campaigns.size() + ' Selected Campaigns ' + Datetime.now();

                    recordsSkipped = 0;
                    recordsTotal = 0;
                    recordsNullEmail = 0;
                    recordsOptOut = 0;
                    Map<String,Integer> optOutResults = new Map<String,Integer>();
                    Set<Id> leadOrContactIds = new Set<Id>();

                    List<CampaignMember> campaignMembers = [Select Id, LeadId, ContactId from CampaignMember where CampaignId in :campaignIds];
                    for(CampaignMember member : campaignMembers) {
                        if(member.LeadId != null) {
                            leadOrContactIds.add(member.LeadId);
                        }
                        else if(member.ContactId != null) {
                            leadOrContactIds.add(member.ContactId);
                        }
                    }
        
                    optOutResults = checkCampaignLeadContactOptOuts(leadOrContactIds);
                    recordsTotal = optOutResults.get('recordsTotal');
                    recordsNullEmail = optOutResults.get('recordsNullEmail');
                    recordsOptOut = optOutResults.get('recordsOptOut');

                    this.recordsSkipped = recordsNullEmail + recordsOptOut;
                    if(recordsTotal > this.recordsSkipped){
                        this.panelId = QualtricsAPI.createPanel(this.panelName);
                        if(this.panelId != null){
                            panelCreated = true;
                            this.survey.Panel_ID__c = panelId;
                            this.survey.Panel_Name__c = panelName;
                            this.survey.Status__c = 'Panel Created';
                            this.survey.Panel_Type__c = 'Campaign';
                            upsert survey;
                        }
                        else {
                            this.ErrorList.add('There was an error creating the panel in Qualtrics.');
                        }
                    }
                    else{
                        this.ErrorList.add('There were no campaign members where email address was populated and Email Opt-out was false');
                    }
                }
                else{
                    this.ErrorList.add('No campaigns selected.');
                }
                // Add the batch stubs
                if(this.ErrorList.size() == 0){
                    List<Survey_Campaign__c> campaignSurveyJunctions = new List<Survey_Campaign__c>();
                    for(Campaign campaign : campaigns){
                        Survey_Campaign__c junction = new Survey_Campaign__c();
                        junction.Campaign__c = campaign.Id;
                        junction.Survey__c = this.survey.Id;
                        campaignSurveyJunctions.add(junction);
                    }
                    System.debug(campaignSurveyJunctions);
                    if(campaignSurveyJunctions.size() > 0){
                        insert campaignSurveyJunctions;
                    }
                    // schedule the batch
                    SendSurveyBatch.submitBatchJob(this.survey.Id, this.panelId);
                }
            }
        }
        catch (Exception e) {
            this.ErrorList.add(e.getMessage());
            System.debug(e.getMessage());
        }
        
    }

    private Map<String,Integer> checkCampaignLeadContactOptOuts(Set<Id> leadOrContactIds) {
        recordsTotal = 0;
        recordsNullEmail = 0;
        recordsOptOut = 0;
        Set<Id> leadIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        for(Id id : leadOrContactIds) {
            if(CSUtils.getObjectNameFromId(id) == 'Lead') {
                leadIds.add(id);
            }
            else if(CSUtils.getObjectNameFromId(id) == 'Contact') {
                contactIds.add(id);
            }
        }
        if(leadIds.size() > 0) {
            List<Lead> leads = Database.query('SELECT '+CSUtils.join(PanelMember.leadAccessibleFields, ', ')+' FROM Lead WHERE ID in :leadIds');
            if (leads.size() > 0) {
                for (Lead lead : leads) {
                    recordsTotal++;
                    if(!String.isBlank(lead.Email)) {
                        for(String field : leadOptOutsAccessible.keySet()) {
                            if(leadOptOutsAccessible.get(field) == true && lead.get(field) == true) {
                                recordsOptOut++;
                                break;
                            }
                        }
                    }
                    else {
                        recordsNullEmail++;
                    }
                }
            }
        }
        if(contactIds.size() > 0) {
            List<Contact> contacts = Database.query('SELECT Account.Name, '+CSUtils.join(PanelMember.contactAccessibleFields, ', ')+' FROM Contact WHERE ID in :contactIds');
            if(contacts.size() > 0) {
                for(Contact contact : contacts) {
                    recordsTotal++;
                    if(!String.isBlank(contact.Email)) {
                        for(String field : contactOptOutsAccessible.keySet()) {
                            if(contactOptOutsAccessible.get(field) == true && contact.get(field) == true) {
                                recordsOptOut++;
                                break;
                            }
                        }
                    }
                    else {
                        recordsNullEmail++;
                    }
                }
            }
        }
        return new Map<String,Integer> { 'recordsTotal' => recordsTotal, 'recordsNullEmail' => recordsNullEmail, 'recordsOptOut' => recordsOptOut };
    }

    public PageReference createPanelFromCampaignList(){
        List<Campaign> campaigns = (List<Campaign>) standardSetController.getSelected(); 
        createCampaignPanel(campaigns);
        return null;   
    }
    public PageReference createPanelFromCampaign(){
        Campaign campaign = (Campaign)standardController.getRecord();
        List<Campaign> campaigns = new List<Campaign>{campaign}; 
        createCampaignPanel(campaigns);
        return null;    
    }
    public Integer getPanelMemberCount(List<Campaign> campaignList){
        Integer count = 0;
        for(Campaign campaign : campaignList){
            count += queryContacts(campaign.Id).size();
            count += queryLeads(campaign.Id).size();      
        }
        return count;
    }
    public Integer getPanelMemberSkippedCount(List<Campaign> campaignList){
        Integer count = 0;
        for(Campaign campaign : campaignList){
            for(Contact contact : queryContacts(campaign.Id)){
                if(contact.Email == null){
                    count += 1;
                }
            }
            for(Lead lead : queryLeads(campaign.Id)){
                if(lead.Email == null){
                    count += 1;
                }
            }        
        }
        recordsSkipped = count;
        return count;
    }

/* DEPRECATED IN FAVOR OF USING BATCH PROCESS TO ADD LARGE NUMBERS OF PANEL MEMBERS
    @future (callout=true)
    public static void addPanelMembersFuture(String panelId, List<Id> campaignIds, Id surveyId){
        List<Campaign> campaignList = Database.query('SELECT '+CSUtils.join(PanelMember.campaignAccessibleFields, ', ')+' FROM Campaign WHERE ID in :campaignIds');
        addPanelMembers(panelId, campaignList, surveyId);
    }

    public static void addPanelMembers(String panelId, List<Campaign> campaignList, Id surveyId){
        try {
            List<String> memberStrings = new List<String>();
            for(Campaign campaign : campaignList){
                String campaignId = campaign.Id;
                for(Contact contact : Database.query('SELECT Account.Name, '+CSUtils.join(PanelMember.contactAccessibleFields, ', ')+' FROM Contact WHERE Id IN (SELECT ContactId FROM CampaignMember WHERE CampaignId= :campaignId AND contactId != null)')){                         
                    memberStrings.add(PanelMember.makeMemberString(contact, campaign, surveyId));
                }
                for(Lead lead : Database.query('SELECT '+CSUtils.join(PanelMember.leadAccessibleFields, ', ')+' FROM Lead WHERE Id In (SELECT LeadId FROM CampaignMember WHERE CampaignId = :campaignId AND LeadId != null )')){
                    memberStrings.add(PanelMember.makeMemberString(lead, campaign, surveyId));
                }       
            }
            QualtricsAPI.addPanelMembers(panelId, memberStrings);
        }
        catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
*/
    @future(callout=true)
    public static void createPanel(String panelName, List<String> memberList, Id surveyId){
        try {
            Integer membersAdded = 0;
            if(memberList.size() > 0 && !String.isBlank(panelName)){
                Survey__c survey = [SELECT Panel_ID__c, Panel_Name__c FROM Survey__c WHERE Id = :surveyId];
                system.debug('panelName: ' + panelName);
                String panelId = QualtricsAPI.createPanel(panelName);
                if(panelId != null){
                    QualtricsAPI.addPanelMembers(panelId, memberList);
                    System.debug('MEMBERS ADDED: ' + membersAdded);
                    survey.Panel_ID__c = panelId;
                    survey.Panel_Name__c = panelName;
                    update survey;
               }
            }
        }
        catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    public PageReference queryAllSurveys(){
        try {
            this.quickStartNames = new List<String>(); 
            if (this.ErrorList.size() == 0 && this.hasCredentials){
                this.surveys = QualtricsAPI.queryActiveSurveys();
                if(this.surveys.size() > 0){
                    for(SurveyResultWrapper.Surveys survey : this.surveys){
                        surveyNameMap.put(survey.SurveyID, survey.SurveyName);
                    }
                }
                Map<String, Quick_Start_Survey__c> quickStartsMap = Quick_Start_Survey__c.getAll();
                for(Quick_Start_Survey__c quickStart : quickStartsMap.values()){
                   this.quickStartNames.add(quickStart.Name);
                   this.quickStartMap.put(quickStart.Name,quickStart.Preview_Location__c);
                }
            }
        }
        catch (Exception e) {
            this.ErrorList.add(e.getMessage());
            System.debug(e.getMessage());
        }
        
        return null;
    }

    public List<Contact> queryContacts(Id campaignId){
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Phone, Email, Account.Name, AccountID, Birthdate, Description, DoNotCall, HasOptedOutOfEmail, HomePhone, LeadSource, MailingStreet, MailingState, MailingCity, MailingPostalCode, MailingCountry, MobilePhone, Name, OtherPhone, OtherStreet, OtherState, OtherCity, OtherCountry, OtherPostalCode, Title  FROM Contact WHERE Id IN
                                 (SELECT ContactId FROM CampaignMember WHERE CampaignId= :campaignId AND contactId != null) ];
        return contacts;
    }

    public List<Lead> queryLeads(Id campaignId){
        List<Lead> leads = [SELECT Id, FirstName, LastName, Phone, AnnualRevenue, Company, Description, Email, Fax, Industry, LeadSource, Status, MobilePhone, Name, NumberOfEmployees, Rating, Title, Website, DoNotCall, HasOptedOutOfFax, HasOptedOutOfEmail FROM Lead WHERE Id In
                            (SELECT LeadId FROM CampaignMember WHERE CampaignId = :campaignId AND LeadId != null ) ];
        return leads;
    }

    public PageReference selectSurvey(){
        PageReference routePage = new PageReference('/apex/SelectSurvey?surveyid='+Survey.Id);
        try {
            Survey.Status__c = 'Panel Created';
            update Survey;
        }
        catch (Exception e) {
            this.ErrorList.add(e.getMessage());
            System.debug(e.getMessage());
        }
        routePage.setRedirect(true);
        return routePage;
    }

    public PageReference editSurvey(){
        PageReference routePage;
        try {
            String surveyId = '';
            Set<String> quickStartSurveyNames = new Set<String>();
            quickStartSurveyNames.addAll(this.quickStartNames);
            String surveyName;
            if(surveyNameMap.containsKey(selectedValue)){
                surveyId = selectedValue;
                surveyName = surveyNameMap.get(selectedValue);
            }
            else if(quickStartSurveyNames.contains(selectedValue)){
                surveyId = QualtricsAPI.importSurvey('New '+selectedValue, selectedValue);
                surveyName = 'New '+ selectedValue;
            }
            else if(selectedValue == 'New Survey'){
                surveyId = QualtricsAPI.importSurvey('New Blank Survey', selectedValue);
                surveyName = 'New Blank Survey';
            }
            this.survey.Survey_ID__c = surveyId;
            this.survey.Status__c = 'Edit Survey';
            this.survey.Survey_Title__c = surveyName;
            upsert survey; 

            if(hasQualtricsAdminPermission) {
                this.showSelectSurvey = false;
                this.showEditSurveyCanvas = true;
                this.showResponseMappingCanvas = false;
                this.showAuthOnlyCanvas = false;
                renderCanvas(survey.Survey_ID__c,null);
                routePage = null;
            }
            else {
                this.showSelectSurvey = false;
                this.showEditSurveyCanvas = false;
                this.showResponseMappingCanvas = false;
                this.showAuthOnlyCanvas = true;
                renderCanvas(survey.Survey_ID__c,null);
                routePage = null;
            }
        }
        catch (Exception e) {
            this.ErrorList.add(e.getMessage());
            System.debug('At ' + e.getLineNumber() + ': ' + e.getMessage());
        }
        
        return routePage;
    }

    public PageReference moveForward() {
        return sendNotification();
    }

    public PageReference editResponseMapping(){
        PageReference routePage;
        try {
            this.showSelectSurvey = false;
            this.showEditSurveyCanvas = false;
            this.showResponseMappingCanvas = true;
            renderCanvas(survey.Survey_ID__c,'ResponseMappingsEditor');
            this.survey.Status__c = 'Edit Response Mappings';
            upsert survey; 
            routePage = null;
        }
        catch (Exception e) {
            this.ErrorList.add(e.getMessage());
            System.debug(e.getMessage());
        }
        
        return routePage;
    }

    public PageReference sendNotification(){
        PageReference pageRef = Page.SurveyMessage;
        try {
            this.survey.Status__c = 'Message';
            upsert survey;
            pageRef.getParameters().put('surveyid', survey.Id); 
            pageRef.setRedirect(true);
        }
        catch (Exception e) {
            this.ErrorList.add(e.getMessage());
            System.debug(e.getMessage());
        }
        
        return pageRef;
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