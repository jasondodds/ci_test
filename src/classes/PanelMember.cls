public with sharing class PanelMember {
    public static String orgName {
        get {
            if(orgName == null){
                Organization orgDetails = [SELECT Id, NAME FROM Organization WHERE Id = :UserInfo.getOrganizationId()];
                orgName = orgDetails.Name;
            }
                return orgName;
        }
        set;
    }
    public static Set<String> contactFieldSet = new Set<String>{'id', 'name', 'email', 'title', 'birthdate', 'accountid', 'firstname', 'lastname', 'leadsource' , 'mailingstreet', 'mailingcity' , 'mailingstate' , 'mailingpostalcode' ,'mailingcountry', 'mobilephone', 'otherstreet', 'othercity', 'otherstate' ,'otherpostalcode', 'othercountry' ,'otherphone', 'homephone', 'donotcall', 'hasoptedoutofemail'}; 
    public static Set<String> contactOptOutFieldSet = new Set<String>();
    public static Set<String> leadFieldSet = new Set<String>{'id', 'email', 'firstname', 'lastname', 'name', 'leadsource', 'status','company', 'annualrevenue', 'industry', 'fax', 'mobilephone', 'numberofemployees', 'phone', 'rating', 'title', 'website' , 'hasoptedoutoffax', 'donotcall', 'hasoptedoutofemail'}; 
    public static Set<String> leadOptOutFieldSet = new Set<String>();
    public static Set<String> campaignFieldSet = new Set<String>{'enddate', 'startdate', 'status', 'name'};
    public static Set<String> contactAccessibleFields {
        get {
            if(contactAccessibleFields == null){
                Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Contact.fields.getMap();
                Set<String> fieldSet = PanelMember.contactFieldSet;
                contactOptOutFieldSet = addOptOutFieldsToSet('Contact');
                System.debug('contactOptOutFieldSet: ' + contactOptOutFieldSet);
                fieldSet.addAll(contactOptOutFieldSet);
                contactAccessibleFields = new Set<String>();
                for(String fieldKey : fieldMap.keySet()){
                    String fieldName = fieldMap.get(fieldKey).getDescribe().getName();
                    //OptOut fields should ALWAYS be accessible, regardless of FLS (Story #52)!
                    if(contactOptOutFieldSet.contains(fieldName)) {
                        System.debug('contactOptOutFieldSet.contains(' + fieldName + '): ' + contactOptOutFieldSet.contains(fieldName));
                        System.debug('fieldSet.contains(' + fieldName + '): ' + fieldSet.contains(fieldName));
                        System.debug('fieldSet.contains(' + fieldName + '.toLowerCase()): ' + fieldSet.contains(fieldName.toLowerCase()));
                    }
                    if(contactOptOutFieldSet.contains(fieldName) && fieldSet.contains(fieldName)) {
                        System.debug('adding ' + fieldName + ' to contactAccessibleFields from OptOut');
                        contactAccessibleFields.add(fieldName);
                    }
                    else if(fieldMap.get(fieldName).getDescribe().isAccessible() && fieldSet.contains(fieldName.toLowerCase())){
                        contactAccessibleFields.add(fieldName);
                    }
                }
                //system.debug('contactAccessibleFields: ' + contactAccessibleFields);
            }
            //system.debug('contactAccessibleFields: ' + contactAccessibleFields);
            return contactAccessibleFields;
        }
        set;
    }
    public static Set<String> leadAccessibleFields {
        get {
            if(leadAccessibleFields == null){
                Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Lead.fields.getMap();
                Set<String> fieldSet = PanelMember.leadFieldSet;
                leadOptOutFieldSet = addOptOutFieldsToSet('Lead');
                System.debug('leadOptOutFieldSet: ' + leadOptOutFieldSet);
                fieldSet.addAll(leadOptOutFieldSet);
                leadAccessibleFields = new Set<String>();
                for(String fieldKey : fieldMap.keySet()){
                    String fieldName = fieldMap.get(fieldKey).getDescribe().getName();
                    //OptOut fields should ALWAYS be accessible, regardless of FLS (Story #52)!
                    if(leadOptOutFieldSet.contains(fieldName)) {
                        System.debug('leadOptOutFieldSet.contains(' + fieldName + '): ' + leadOptOutFieldSet.contains(fieldName));
                        System.debug('fieldSet.contains(' + fieldName + '): ' + fieldSet.contains(fieldName));
                        System.debug('fieldSet.contains(' + fieldName + '.toLowerCase()): ' + fieldSet.contains(fieldName.toLowerCase()));
                    }
                    if(leadOptOutFieldSet.contains(fieldName) && fieldSet.contains(fieldName)) {
                        leadAccessibleFields.add(fieldName);
                    }
                    else if(fieldMap.get(fieldName).getDescribe().isAccessible() && fieldSet.contains(fieldName.toLowerCase())){
                        leadAccessibleFields.add(fieldName);
                    }
                }
            }
            //system.debug('leadAccessibleFields: ' + leadAccessibleFields);
            return leadAccessibleFields;
        }
        set;
    }
    public static Set<String> campaignAccessibleFields {
        get {
            if(campaignAccessibleFields == null){
                Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Campaign.fields.getMap();
                Set<String> fieldSet = PanelMember.campaignFieldSet;
                campaignAccessibleFields = new Set<String>();
                // TODO: Have list of excluded fields that we check agains to make sure they aren't included in the Query
                for(String fieldKey : fieldMap.keySet()){
                    String fieldName = fieldMap.get(fieldKey).getDescribe().getName();
                    if(fieldMap.get(fieldName).getDescribe().isAccessible() && fieldSet.contains(fieldName.toLowerCase())){
                        campaignAccessibleFields.add(fieldName);
                    }
                }
            }
            return campaignAccessibleFields;
        }
        set;
    }
    public static JSONGenerator makeCampaignString(Campaign campaign, JSONGenerator generator){
        String campaignString = '';
        if (campaign.Id != null) {
            generator.writeObjectField('sfCampaignId',campaign.Id);
        }
        if (campaign.EndDate != null && PanelMember.campaignAccessibleFields.contains('enddate')) {
            generator.writeFieldName('sfEndDate');
            generator.writeDate(campaign.EndDate );
        }
        if (campaign.StartDate != null && PanelMember.campaignAccessibleFields.contains('startdate')) {
            generator.writeFieldName('sfStartDate');
            generator.writeDate(campaign.StartDate );
        }
        if (campaign.Name != null && PanelMember.campaignAccessibleFields.contains('name')) {
            generator.writeFieldName('sfCampaign');
            generator.writeString(campaign.Name );
        }
        if (campaign.Status != null && PanelMember.campaignAccessibleFields.contains('status')) {
            generator.writeFieldName('sfStatus');
            generator.writeString(campaign.Status );
        }
        return generator;
    }
    public static String makeMemberString(Lead lead, Id surveyId){
        return makeMemberString(lead, null, surveyId);
    }
    public static String makeMemberString(Lead lead, Campaign campaign, Id surveyId){
        Set<String> localAccessibleFields = new Set<String>();
        localAccessibleFields.addAll(PanelMember.leadAccessibleFields);
        String jsonString = '';
        JSONGenerator generator = JSON.createGenerator(True);
        generator.writeStartObject();
        if(localAccessibleFields.contains('Id')){
            generator.writeObjectField('ExternalReference', lead.Id);
            //localAccessibleFields.remove('Id');
        }
        if(lead.Email != null && localAccessibleFields.contains('Email')){
            generator.writeObjectField('Email', lead.Email);
            localAccessibleFields.remove('Email');
        }
        if(lead.FirstName != null && localAccessibleFields.contains('FirstName')){
            generator.writeObjectField('FirstName', lead.FirstName);
            localAccessibleFields.remove('FirstName');
        }
        if(localAccessibleFields.contains('LastName')){
            generator.writeObjectField('LastName', lead.LastName);
            localAccessibleFields.remove('LastName');
        }

        // Start Embedded Data
        generator.writeFieldName('EmbeddedData');
        generator.writeStartObject();
        if(campaign != null){
            generator = makeCampaignString(campaign, generator);
        }
        for(String fieldName : localAccessibleFields){
            Object fieldValue = lead.get(fieldName);
            if(fieldValue != null){
                if(fieldName == 'Id'){
                    generator.writeObjectField('ExternalDataRef', fieldValue);
                    generator.writeObjectField('sfLeadId', fieldValue);
                }
                else {
                    generator.writeObjectField('sf'+fieldName, fieldValue);
                }
            }
        }
        generator.writeFieldName('sfOrgCompany');
        generator.writeString(PanelMember.orgName);
        generator.writeFieldName('sfSurveyID');
        generator.writeString(surveyId);
        generator.writeEndObject();
        // End Embedded Data

        jsonString = generator.getAsString();
        return jsonString;

    }
    public static String makeMemberString(Contact contact, Id surveyId){
        return makeMemberString(contact, null, surveyId);
    }
    public static String makeMemberString(Contact contact, Campaign campaign, Id surveyId){
        Set<String> localAccessibleFields = new Set<String>();
        localAccessibleFields.addAll(PanelMember.contactAccessibleFields);
        String jsonString = '';
        JSONGenerator generator = JSON.createGenerator(True);
        generator.writeStartObject();
        if(localAccessibleFields.contains('Id')){
            generator.writeObjectField('ExternalReference', contact.Id);
            //localAccessibleFields.remove('Id');
        }
        if(contact.Email != null && localAccessibleFields.contains('Email')){
            generator.writeObjectField('Email', contact.Email);
            localAccessibleFields.remove('Email');
        }
        if(contact.FirstName != null && localAccessibleFields.contains('FirstName')){
            generator.writeObjectField('FirstName', contact.FirstName);
            localAccessibleFields.remove('FirstName');
        }
        if(localAccessibleFields.contains('LastName')){
            generator.writeObjectField('LastName', contact.LastName);
            localAccessibleFields.remove('LastName');
        }

        // Start Embedded Data
        generator.writeFieldName('EmbeddedData');
        generator.writeStartObject();
        if(campaign != null){
            generator = makeCampaignString(campaign, generator);
        }
        for(String fieldName : localAccessibleFields){
            Object fieldValue = contact.get(fieldName);
            if(fieldValue != null){
                if(fieldName == 'Id'){
                    generator.writeObjectField('ExternalDataRef', fieldValue);
                    generator.writeObjectField('sfContactId', fieldValue);
                }
                else {
                    generator.writeObjectField('sf'+fieldName, fieldValue);
                }
            }
        }
        
        if(contact.Account != null){
            generator.writeFieldName('sfAccount');
            generator.writeString(contact.Account.Name);
        }
        generator.writeFieldName('sfOrgCompany');
        generator.writeString(PanelMember.orgName);
        generator.writeFieldName('sfSurveyID');
        generator.writeString(surveyId);
        generator.writeEndObject();
        // End Embedded Data

        jsonString = generator.getAsString();
        return jsonString;
    }

    public static Set<String> addOptOutFieldsToSet(String whichSObject) {
        Set<String> retSet = new Set<String> { 'HasOptedOutOfEmail' };
        Map<String, Schema.SObjectField> fieldMap;
        if(whichSObject == 'Lead') {
            fieldMap = Schema.SObjectType.Lead.fields.getMap();
        }
        else if (whichSObject == 'Contact') {
            fieldMap = Schema.SObjectType.Contact.fields.getMap();  
        }
        //system.debug('fieldMap: ' + fieldMap);
        Map<String,Qualtrics_Email_Opt_out__c> optOutSettings = Qualtrics_Email_Opt_out__c.getAll();
        //system.debug('optoutSettings: ' + optOutSettings);
        for(Qualtrics_Email_Opt_out__c setting: optOutSettings.values()) {
            if(setting.SObject_Name__c == whichSObject) {
                system.debug('Field Name: ' + setting.Field_Name__c);
                if(fieldMap.containsKey(setting.Field_Name__c)) {
                    retSet.add(setting.Field_Name__c);
                }
                else {
                    system.debug('finding: ' + setting);
                    List<String> nameSegs = setting.Field_Name__c.split('__');
                    string cleanName = '';
                    string nameSpace = '';
                    if(nameSegs.size() > 2 || (nameSegs.size() == 2) && !nameSegs.get(0).equalsIgnoreCase('c')) {
                        nameSpace = nameSegs.get(0);
                        cleanName = setting.Field_Name__c.replace(nameSpace+'__','').toLowerCase();
                        system.debug('Namespace: ' + nameSpace + ', cleanFieldName: ' + cleanName);
                        if(fieldMap.containsKey(cleanName) && fieldMap.get(cleanName).getDescribe().getName() == setting.Field_Name__c) {
                            retSet.add(setting.Field_Name__c);                        
                        }
                    }
                }
            }
        }

        return retSet;
    }

    public static Set<Id> checkMissingOptOutFields() {
        Set<Id> retSet = new Set<Id>();
        Map<String, Schema.SObjectField> leadFieldMap = Schema.SObjectType.Lead.fields.getMap();
        Map<String, Schema.SObjectField> contactFieldMap = Schema.SObjectType.Contact.fields.getMap();
        Map<String,Qualtrics_Email_Opt_out__c> optOutSettings = Qualtrics_Email_Opt_out__c.getAll();
        for(Qualtrics_Email_Opt_out__c setting: optOutSettings.values()) {
            //system.debug('finding: ' + setting);
            List<String> nameSegs = setting.Field_Name__c.split('__');
            string cleanName = '';
            string nameSpace = '';
            if(nameSegs.size() > 2 || (nameSegs.size() == 2) && !nameSegs.get(0).equalsIgnoreCase('c')) {
                nameSpace = nameSegs.get(0);
                cleanName = setting.Field_Name__c.replace(nameSpace+'__','').toLowerCase();
                system.debug('Namespace: ' + nameSpace + ', cleanFieldName: ' + cleanName);
            }
            if((setting.SObject_Name__c == 'Lead' && !leadFieldMap.containsKey(setting.Field_Name__c.toLowerCase())) ||
               (setting.SObject_Name__c == 'Contact' && !contactFieldMap.containsKey(setting.Field_Name__c.toLowerCase()))){
                //Field no longer exists -- remove from the optout
                if(string.isBlank(cleanName)) {
                    system.debug('Missing field: ' + setting);
                    retSet.add(setting.Id);
                }
                else if(!string.isBlank(cleanName) && !contactFieldMap.containsKey(cleanName)) {
                    system.debug('Missing field: ' + setting);
                    retSet.add(setting.Id);
                }
                else if(!string.isBlank(cleanName) && contactFieldMap.containsKey(cleanName)) {
                    if(!contactFieldMap.get(cleanName).getDescribe().getName().startsWithIgnoreCase(nameSpace)) {
                        system.debug('Missing field: ' + setting);
                        retSet.add(setting.Id);
                    }
                }
            }
        }

        return retSet;
    }
}