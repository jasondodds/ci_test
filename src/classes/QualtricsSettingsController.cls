public with sharing class QualtricsSettingsController {
	public Qualtrics_Preferences__c qualtricsSetting {get;set;}
	public Qualtrics_API_Settings__c apiSetting {get;set;}
	public Map<String,List<qualtricsOptOutWrapper>> qualtricsOptOuts {get;set;}
	public Boolean showAuthOnlyCanvas {get;set;}
	public Boolean showDisconnectModal {get;set;}
	public Boolean hasQualtricsAdminPermission {get;set;}
	public Boolean hasCredentials {
        get {
            if(this.hasCredentials == null) {   
                this.hasCredentials = Utils.userHasQualtricsSettings(UserInfo.getUserId());
            }            
            return this.hasCredentials;
        }
        set;
    }
    public String qualtricsUserName {
        get {
            if(string.isBlank(this.qualtricsUserName) || this.qualtricsUserName == 'OrgDefault') {
				this.qualtricsUserName = Qualtrics_API_Settings__c.getInstance(UserInfo.getUserId()).User_Name__c;
            }
            return this.qualtricsUserName;
        }
        set;
    }
    public List<String> messageErrorList {
        get {
            if(this.messageErrorList == null) {   
                this.messageErrorList = new List<String>();
            }            
            return this.messageErrorList;
        }
        set;
    }
    public List<String> messageMsgsList {
        get {
            if(this.messageMsgsList == null) {   
                this.messageMsgsList = new List<String>();
            }            
            return this.messageMsgsList;
        }
        set;
    }
    public List<String> optoutErrorList {
        get {
            if(this.optoutErrorList == null) {   
                this.optoutErrorList = new List<String>();
            }            
            return this.optoutErrorList;
        }
        set;
    }
    public List<String> optoutMsgsList {
        get {
            if(this.optoutMsgsList == null) {   
                this.optoutMsgsList = new List<String>();
            }            
            return this.optoutMsgsList;
        }
        set;
    }
    private Map<String,String> sObjectsForOptOut = new Map<String,String> {'Contact' => 'HasOptedOutOfEmail','Lead' => 'HasOptedOutOfEmail'};
    private Map<String,Set<String>> sObjectExcludeFieldsFromOptOut = new Map<String,Set<String>> {
    	'Contact' => new Set<String> { 'IsDeleted' }, 
    	'Lead' => new Set<String> { 'IsDeleted','IsConverted','IsUnreadByOwner' }
    };

    //used by QualtricsLoginForm.component
    public QualtricsSettingsController getPageCont(){
        return this;
    }

	public QualtricsSettingsController() {
		showDisconnectModal = false;
		showAuthOnlyCanvas = true;
		hasQualtricsAdminPermission = Utils.userHasQualtricsAdminPermission();
		qualtricsSetting = Qualtrics_Preferences__c.getInstance('Default');
		if(qualtricsSetting == null) {
			qualtricsSetting = new Qualtrics_Preferences__c(Name='Default');
			qualtricsSetting.Default_Message_From_Type__c = QualtricsConstants.MessageFromType.RunningUser.name();
		}
		this.qualtricsUserName = Qualtrics_API_Settings__c.getInstance(UserInfo.getUserId()).User_Name__c;
		qualtricsOptOuts = buildQualtricsOptouts();
	}

	public List<SelectOption> getOrgWideEmails() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('','Select Address'));
		// Use Organization Wide Address  
		for(OrgWideEmailAddress owa : [select id, Address, DisplayName from OrgWideEmailAddress]) {
			options.add(new SelectOption(owa.Id, owa.DisplayName + ' - ' + owa.Address));
		}
		return options;		
	}

    public PageReference checkDeletedCheckboxFields() {
        Utils.clearEmailOptOutSettingForMissingField();
        return null;
    }

    public PageReference showConfirmDisconnect() {
    	showDisconnectModal = true;
    	return null;
    }

    public PageReference disconnectQualtricsUser() {
    	Qualtrics_API_Settings__c curQUser = Qualtrics_API_Settings__c.getInstance();
    	delete curQUser;
    	showDisconnectModal = false;
    	PageReference pr = Page.Qualtrics;
    	pr.setRedirect(true);
    	return pr;
    }

    public PageReference cancelDisconnect() {
    	showDisconnectModal = false;
    	return null;
    }

	public Map<String,List<qualtricsOptOutWrapper>> buildQualtricsOptouts() {
		Map<String,List<qualtricsOptOutWrapper>> retList = new Map<String,List<qualtricsOptOutWrapper>>();
		Map<String,Qualtrics_Email_Opt_out__c> curOptOuts = Qualtrics_Email_Opt_out__c.getAll();
		Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		For(String sobj : sObjectsForOptOut.keySet()) {
			Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sobj).getDescribe().fields.getMap();
			List<qualtricsOptOutWrapper> checkboxFields = new List<qualtricsOptOutWrapper>();
			For(Schema.SObjectField field : fieldMap.values()) {
				Schema.DescribeFieldResult dfr = field.getDescribe();
				if(dfr.getType() == DisplayType.Boolean && !sObjectExcludeFieldsFromOptOut.get(sobj).contains(dfr.getName())) { 
					//This is a checkbox field!
					qualtricsOptOutWrapper tempWrapper = new qualtricsOptOutWrapper();
					tempWrapper.sObjectName = sobj;
					tempWrapper.fieldLabel = dfr.getLabel();
					tempWrapper.fieldName = dfr.getName();
					if(sObjectsForOptOut.containsKey(sobj) && dfr.getName() == sObjectsForOptOut.get(sobj)) {
						tempWrapper.selected = true;
						tempWrapper.readOnly = true;
					}
					else {
						tempWrapper.selected = curOptOuts.containsKey(Utils.generateBase64UniqueString(sobj + '|' + tempWrapper.fieldName));
					}
					checkboxFields.add(tempWrapper);
				}
			}
			
			if(checkboxFields.size() > 0) {
				retList.put(sobj,checkboxFields);
			}
		}
		return retList;
	}

	public pageReference saveSettings() {
		this.optoutErrorList.clear();
		this.optoutMsgsList.clear();

		if(qualtricsOptOuts != null) {
			List<Qualtrics_Email_Opt_out__c> insertOptOuts = new List<Qualtrics_Email_Opt_out__c>();
			List<Qualtrics_Email_Opt_out__c> deleteOptOuts = new List<Qualtrics_Email_Opt_out__c>();
			Map<String,Qualtrics_Email_Opt_out__c> curOptOuts = Qualtrics_Email_Opt_out__c.getAll();
			for(List<qualtricsOptOutWrapper> wraps : qualtricsOptOuts.values()) {
				for(qualtricsOptOutWrapper wrap : wraps) {
					if(wrap.selected && !curOptOuts.containsKey(Utils.generateBase64UniqueString(wrap.sobjectName + '|' + wrap.fieldName)) &&
						wrap.fieldName != sObjectsForOptOut.get(wrap.sobjectName)) {
						insertOptOuts.add(
							New Qualtrics_Email_Opt_out__c(
								Name = Utils.generateBase64UniqueString(wrap.sobjectName + '|' + wrap.fieldName),
								SObject_Name__c = wrap.sobjectName,
								Field_Name__c = wrap.fieldName
							)
						);
					}
					else if(!wrap.selected && curOptOuts.containsKey(Utils.generateBase64UniqueString(wrap.sobjectName + '|' + wrap.fieldName))) {
						deleteOptOuts.add(curOptOuts.get(Utils.generateBase64UniqueString(wrap.sobjectName + '|' + wrap.fieldName)));
					}
				}
			}
			boolean hadChanges = false;
			if(insertOptOuts.size() > 0) { 
				hadChanges = true;
				insert insertOptOuts; 
			}
			if(deleteOptOuts.size() > 0) { 
				hadChanges = true;
				delete deleteOptOuts; 
			}
			if(hadChanges) {
				qualtricsOptOuts = buildQualtricsOptouts();
				this.optoutMsgsList.add('Saved Opt-out fields.');
			}
		}
		return null;
	}

	public pageReference savePrefs() {
		this.messageErrorList.clear();
		this.messageMsgsList.clear();
		if(qualtricsSetting.Default_Message_From_Type__c == QualtricsConstants.MessageFromType.Custom.name() && 
			(string.isBlank(qualtricsSetting.Default_From_Name__c) || string.isBlank(qualtricsSetting.Default_Reply_To_Email__c))) {
			this.messageErrorList.add('When selecting Use Custom Info you must enter a From Name and Reply-To Email.');
		}
		else if(string.isBlank(qualtricsSetting.Default_Subject__c) && !qualtricsSetting.Allow_Subject_Override__c) {
			this.messageErrorList.add('Default Subject cannot be blank if \'Allow User to Override\' is false. Please enter a Default Subject line, or set \'Allow User to Override\' to True');
		}
		else {
			upsert qualtricsSetting;
			this.messageMsgsList.add('Saved Settings.');
		}
		return null;
	}

	public pageReference cancelSettings() {
		this.optoutErrorList.clear();
		this.optoutMsgsList.clear();
		qualtricsOptOuts = buildQualtricsOptouts();
		this.optoutMsgsList.add('Cancelled Opt-Outs.');
		return null;
	}

	public pageReference cancelPrefs() {
		this.messageErrorList.clear();
		this.messageMsgsList.clear();
		qualtricsSetting = Qualtrics_Preferences__c.getInstance('Default');
		this.messageMsgsList.add('Cancelled Settings.');
		return null;
	}

	public string getRequestParamJSON(){
        Map<String,String> requestParamMap = new Map<String,String>();
        requestParamMap.put('qualtricsUserToken',Qualtrics_API_Settings__c.getInstance(UserInfo.getUserId()).API_Token__c);
        requestParamMap.put('AuthOnly','true');
        return JSON.serialize(requestParamMap);
    }

    public PageReference hideAuthOnlyCanvas() {
    	showAuthOnlyCanvas =false;
    	return null;
    }


	public class qualtricsOptOutWrapper {
		public String sobjectName {get;set;}
		public String fieldLabel {get;set;}
		public String fieldName {get;set;}
		public Boolean selected {get;set;}
		public Boolean readOnly {get;set;}

		public qualtricsOptOutWrapper() {
			this.selected = false;
			this.readOnly = false;
		}

	}

}