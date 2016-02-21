public with sharing class ProjectSetupController {

    public String projectDefinitionId {get;set;}
    private final ProjectDefinition__c projectDefinition;
    
    public ProjectSetupController(ApexPages.StandardController stdController) {
        //this.projectDefinition = (ProjectDefinition__c)stdController.getRecord();
        //this.projectDefinitionId = projectDefinition.Id;
    }

    public Boolean githubTokenPresent {
        get{
            return new UserSetupController().githubTokenPresent;
        }
        set;
    }

    public Boolean ciTokenPresent {
        get{
            return new UserSetupController().ciTokenPresent;
        }
        set;
    }

    public PageReference routeToUserSetup(){
        PageReference pageRef = new PageReference('/apex/UserSetup');
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference routeToHome(){
        PageReference pageRef = new PageReference('/a00');
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference checkRouteToUserSetup(){
        PageReference pageRef = new PageReference('/apex/UserSetup');
        if(!githubTokenPresent || !ciTokenPresent){
            pageRef.setRedirect(true);
            return pageRef;
        }
        else {
            return null;
        }
    }
}