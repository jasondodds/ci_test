global class PostInstallScript implements InstallHandler {
  global void onInstall(InstallContext context) {
    if(context.previousVersion() == null) {
      //Moving to separate function and checking for existence of Quickstarts
/*    	String tempUrl = 'https://s3-us-west-1.amazonaws.com/codesciencedev/qualtrics/QualtricsSampleSurvey.json';
      List<Quick_Start_Survey__c> quickStartGuides = new List<Quick_Start_Survey__c>();

      // INITIALIZE MAP WITH QUICK STARTS AND S3 LOCATIONS FROM STATIC RESOURCE 
      Blob fileContents = [SELECT Body FROM StaticResource WHERE Name = 'QuickStartGuidesLoad' LIMIT 1].Body;
      String jsonContent =  fileContents.toString();
      System.debug(jsonContent);
      List<quickStart> quickStartList = (List<quickStart>)JSON.deserialize(jsonContent, List<quickStart>.class);
      for(PostInstallScript.quickStart quickStart : quickStartList){
        quickStartGuides.add(new Quick_Start_Survey__c(Name=quickStart.name, Name__c=quickStart.name, Static_Resource_Location__c=quickStart.url, Preview_Location__c=quickStart.preview));
      }
      insert quickStartGuides;
*/
    }
    else {
      if(context.previousVersion().compareTo(new Version(1,0)) == 0) {
        	// VERSION UPGRADE
        }
      if(context.isUpgrade()) {
        	// UPGRADE
        }
      if(context.isPush()) {
        	// UPGRADE PUSH
      }
      Set<String> existingObjects = Schema.getGlobalDescribe().keySet();
      if(existingObjects.contains('qualtrics_email_opt_out__c') || existingObjects.contains('qualtrics__qualtrics_email_opt_out__c')) {
        Map<String, Qualtrics_Email_Opt_out__c> curOptOutFields = Qualtrics_Email_Opt_out__c.getAll();
        list<Qualtrics_Email_Opt_out__c> newOptOutFields = new List<Qualtrics_Email_Opt_out__c>();
        list<Qualtrics_Email_Opt_out__c> deleteOptOutFields = new list<Qualtrics_Email_Opt_out__c>();
        For(Qualtrics_Email_Opt_out__c field : curOptOutFields.values()) {
          if(!curOptOutFields.containsKey(Utils.generateBase64UniqueString(field.SObject_Name__c + '|' + field.Field_Name__c))){
            newOptOutFields.add(
              new Qualtrics_Email_Opt_out__c(
                Name = Utils.generateBase64UniqueString(field.SObject_Name__c + '|' + field.Field_Name__c),
                SObject_Name__c = field.SObject_Name__c,
                Field_Name__c = field.Field_Name__c
              )
            );
            deleteOptOutFields.add(field);
          }
        }
        //Savepoint sp = Database.setSavepoint();
        //try {
          if(newOptOutFields.size() > 0) {
            insert newOptOutFields;
          }
          if(deleteOptOutFields.size() > 0) {
            delete deleteOptOutFields;
          }
        /*}
        Catch(Exception ex) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An error occurred updating your Opt out fields. Please verify your values are in place.'));
          Database.rollback(sp);
        }*/
      }
    }
    Qualtrics_Preferences__c qualtricsSetting = Qualtrics_Preferences__c.getInstance('Default');
    if(qualtricsSetting == null) {
      qualtricsSetting = new Qualtrics_Preferences__c(
                              Name = 'Default',
                              Default_Message_From_Type__c = QualtricsConstants.MessageFromType.RunningUser.name(),
                              Default_Subject__c = '',
                              Allow_Subject_Override__c = true
      );
      insert qualtricsSetting;
    }
    checkQuickStarts();
  }

  private void checkQuickStarts() {
      //SCS Not used anymore
      //String tempUrl = 'https://s3-us-west-1.amazonaws.com/codesciencedev/qualtrics/QualtricsSampleSurvey.json';
      List<Quick_Start_Survey__c> quickStartGuides = new List<Quick_Start_Survey__c>();
      List<Quick_Start_Survey__c> updateQSGuides = new List<Quick_Start_Survey__c>();

      /* INITIALIZE MAP WITH QUICK STARTS AND S3 LOCATIONS FROM STATIC RESOURCE */
      Blob fileContents = [SELECT Body FROM StaticResource WHERE Name = 'QuickStartGuidesLoad' LIMIT 1].Body;
      String jsonContent =  fileContents.toString();
      System.debug(jsonContent);
      List<quickStart> quickStartList = (List<quickStart>)JSON.deserialize(jsonContent, List<quickStart>.class);
      Map<String,Quick_Start_Survey__c> curSurveys = Quick_Start_Survey__c.getAll();
      for(PostInstallScript.quickStart quickStart : quickStartList){
        if(!curSurveys.containsKey(quickStart.Name)) {
          quickStartGuides.add(new Quick_Start_Survey__c(Name=quickStart.name, Name__c=quickStart.name, Static_Resource_Location__c=quickStart.url, Preview_Location__c=quickStart.preview));
        }
        else {
          Quick_Start_Survey__c tempSurvey = curSurveys.get(quickStart.Name);
          tempSurvey.Name__c = quickStart.Name;
          tempSurvey.Static_Resource_Location__c = quickStart.url;
          tempSurvey.Preview_Location__c = quickStart.preview;
          updateQSGuides.add(tempSurvey);
        }
      }
      insert quickStartGuides;
      if(updateQSGuides.size() > 0) {
        update updateQSGuides;
      }
  }

  public class quickStart {
    public String name {get;set;}
    public String url {get;set;}
    public String preview {get;set;}
  }
}