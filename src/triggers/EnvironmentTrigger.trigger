trigger EnvironmentTrigger on Environment__c (before insert, after insert) {
    
    if(trigger.isBefore && trigger.isInsert) {
        EnvironmentService.setEnvironmentBranchName(trigger.new);
    }

    if(trigger.isAfter && trigger.isInsert && trigger.new.size() >= 1) {
    	for(Environment__c environment : trigger.new){
    		GithubService.createUserBranch(environment.Id);
	        SignupRequestService.createSignupRequest(environment);
	    }
    }
}