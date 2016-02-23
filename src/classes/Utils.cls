public with sharing class Utils {

	public static Boolean isValidId(String s) {
		Id validId;
		try {
			validId = s;
			return true;
		} catch (Exception ex) {
			return false;
		}
	}

	public static Boolean userHasQualtricsSettings(String userId){
		Qualtrics_API_Settings__c settings = Qualtrics_API_Settings__c.getInstance(userId);
		if(settings.API_Token__c == null){
			return false;
		}		
		return true;
	}

	public static void sendDebugEmail(List<String> toAddresses, String objectInfo){
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(toAddresses);
			mail.setSubject('Error in qualtrics app');
			mail.setPlainTextBody(objectInfo);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });	
	}

	public static void clearEmailOptOutSettingForMissingField() {
        Set<Id> missingEmailOptOutFields = PanelMember.checkMissingOptOutFields();
        if(missingEmailOptOutFields.size() > 0) {
            List<Qualtrics_Email_Opt_out__c> deleteSettings = new List<Qualtrics_Email_Opt_out__c>();
            for(Id del : missingEmailOptOutFields) {
                deleteSettings.add(new Qualtrics_Email_Opt_out__c(Id=del));
            }
            delete deleteSettings;
        }
	}

	public static Boolean userHasQualtricsAdminPermission() {
        CustomPermissionsReader cpr = new CustomPermissionsReader(Survey__c.sObjectType);
        return cpr.hasPermission('Qualtrics_Admin');
    }

    public static string generateBase64UniqueString(String incomingString) {
    	if(!string.isBlank(incomingString)) {
			Blob targetBlob = Blob.valueOf(incomingString);
			Blob hashSHA1 = Crypto.generateDigest('SHA1', targetBlob);
			String hashBase64SHA1 = EncodingUtil.base64encode (hashSHA1);
			return hashBase64SHA1;
		}
		return '';
    }

}