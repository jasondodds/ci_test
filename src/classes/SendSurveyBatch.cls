global class SendSurveyBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    global Id surveyId;
    global String panelId;
    global Integer validMemberCount;
    global Boolean leadOptOutAccessible;
    global Boolean contactOptOutAccessible;
    global Map<String,Boolean> leadOptOutsAccessible;
    global Map<String,Boolean> contactOptOutsAccessible;
    global Integer recordsTotal {get;set;}
    global Integer recordsNullEmail {get;set;}
    global Integer recordsOptOut {get;set;}
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        validMemberCount = 0;
        recordsTotal = 0;
        recordsNullEmail = 0;
        recordsOptOut = 0;
        Set<String> leadAccFields = PanelMember.leadAccessibleFields;
        leadOptOutsAccessible = new Map<String,Boolean>();
        for(String field : PanelMember.leadOptOutFieldSet) {
            leadOptOutsAccessible.put(field,PanelMember.leadAccessibleFields.contains(field) ? true : false);
        }

        Set<String> lContactAccFields = PanelMember.contactAccessibleFields;
        contactOptOutsAccessible = new Map<String,Boolean>();
        for(String field : PanelMember.contactOptOutFieldSet) {
            contactOptOutsAccessible.put(field,PanelMember.contactAccessibleFields.contains(field) ? true : false);
        }

        Utils.clearEmailOptOutSettingForMissingField();

        return Database.getQueryLocator(
            [SELECT Id, LeadId, ContactId, CampaignId
               FROM CampaignMember
              WHERE CampaignId IN (SELECT Campaign__c
                                     FROM Survey_Campaign__c
                                    WHERE Survey__c = :this.surveyId)]);
    }
    
    global void execute(Database.BatchableContext BC, List<CampaignMember> cms) {
        List<CampaignMember> members = Database.query(getCampaignMemberQuery());
        List<String> memberStrings = new List<String>();
        for (CampaignMember cm : members) {
            String campaignId = cm.Id;
            Campaign c = cm.Campaign;
            
            if (cm.Lead != null) {
                if(!String.isBlank(cm.Lead.Email)){
                    boolean optOutAccessible = false;
                    boolean optedOut = false;
                    for(String field : leadOptOutsAccessible.keySet()) {
                        if(leadOptOutsAccessible.get(field) == true) {
                            optOutAccessible = true;
                            if(cm.Lead.get(field) == true) {
                                optedOut = true;
                                break;
                            }
                        }
                    }
                    if(!optOutAccessible || (optOutAccessible && !optedOut)) {
                        memberStrings.add(PanelMember.makeMemberString(cm.Lead, c, surveyId));
                    }
                    else {
                        recordsOptOut += 1;
                    }
                }
                else {
                    recordsNullEmail += 1;
                }
                recordsTotal += 1;
            } 
            else if (cm.Contact != null) {
                if(!String.isBlank(cm.Contact.Email)){
                    boolean optOutAccessible = false;
                    boolean optedOut = false;
                    for(String field : contactOptOutsAccessible.keySet()) {
                        if(contactOptOutsAccessible.get(field) == true) {
                            optOutAccessible = true;
                            if(cm.Contact.get(field) == true) {
                                optedOut = true;
                                break;
                            }
                        }
                    }
                    if(!optOutAccessible || (optOutAccessible && !optedOut)) {
                        memberStrings.add(PanelMember.makeMemberString(cm.Contact, c, surveyId));
                    }
                    else {
                        recordsOptOut += 1;
                    }
                }
                else {
                    recordsNullEmail += 1;
                }
                recordsTotal += 1;
            }
        }
        QualtricsAPI.addPanelMembers(this.panelId, memberStrings);
    }
    
    global void finish(Database.BatchableContext BC) {
        this.validMemberCount = this.recordsTotal - (this.recordsNullEmail + this.recordsOptOut);
        // Update the Panel Member count on the Survey
        if(this.validMemberCount > 0){
            Survey__c survey = [SELECT Id, Sent__c FROM Survey__c WHERE Id = :this.surveyId LIMIT 1];
            survey.Sent__c = this.validMemberCount;
            survey.Email_Missing__c = this.recordsNullEmail;
            survey.Email_Opt_Out__c = this.recordsOptOut;
            update survey;
        }
        
        // Update the survey as sent
        List<Survey_Campaign__c> scs = [SELECT Id, SendSurveyCompleteTimestamp__c
                                          FROM Survey_Campaign__c
                                         WHERE Survey__c = :this.surveyId];
        for (Survey_Campaign__c sc : scs) {
            sc.SendSurveyCompleteTimestamp__c 	= DateTime.now();
        }
        update scs;
        
        // See if other surveys need to be processed
        List<Survey__c> surveys = [SELECT Id, Panel_ID__c
                                     FROM Survey__c
                                    WHERE Id IN (SELECT Survey__c
                                                   FROM Survey_Campaign__c
                                                  WHERE SendSurveyCompleteTimestamp__c = null)
                                    LIMIT 1];
        if (surveys.size() > 0) {
            // Another job needs to be submitted
            submitBatchJob(surveys.get(0).Id, surveys.get(0).Panel_ID__c);
        }
    }
    
    /**
     * This method should be called by any other process that needs to submit this batch job.
     */
    public static Id submitBatchJob(Id surveyId, String panelId) {
        Id returnValue = null;
        
        // See if any other Apex Batch Jobs have been queued
        List<String> statuses = new List<String>{'Queued', 'Processing', 'Preparing'};
            List<AsyncApexJob> jobs = [SELECT Id
                                       FROM AsyncApexJob
                                       WHERE ApexClass.Name = 'SendSurveyBatch'
                                       AND Status IN :statuses];
        if (jobs.size() == 0) {
            // No other batch jobs are in the queue, let's add one
            try {
                SendSurveyBatch ssb	= new SendSurveyBatch();
                ssb.surveyId	= surveyId;
                ssb.panelId		= panelId;
                
                returnValue = Database.executeBatch(ssb, 2000);
            } catch (Exception e) {
                System.debug(e);
            }
        }
        
        return returnValue;
    }
    
    // split this out so that it's easier to test
    public static String getCampaignMemberQuery() {
        return 'SELECT Id, CampaignId, Contact.Account.Name, Contact.' +
            String.join(new List<String>(PanelMember.contactAccessibleFields), ', Contact.') + ', Lead.' +
            String.join(new List<String>(PanelMember.leadAccessibleFields), ', Lead.') + ', Campaign.' +
            String.join(new List<String>(PanelMember.campaignAccessibleFields), ', Campaign.') + 
            ' FROM CampaignMember WHERE Id IN :cms';
    }
}
