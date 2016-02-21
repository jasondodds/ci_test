trigger TeamMember on Team_Member__c (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

		if (Trigger.isBefore) {
			if(Trigger.isInsert){
				// Add Collaborators to GitHub Repo
				boolean processCollaborators = true;
				Set<Id> projectDefIds = new Set<Id>();
				
				for(Team_Member__c teamMember : Trigger.new){
					projectDefIds.add(teamMember.Project_Definition__c);
				}
				Map<Id,ProjectDefinition__c> projectDefsById = new Map<Id,ProjectDefinition__c>([SELECT Id, Repo_Name__c FROM ProjectDefinition__c WHERE Id IN :projectDefIds]);
				
				for(Team_Member__c teamMember : Trigger.new){
					if(projectDefsById.get(teamMember.Project_Definition__c).Repo_Name__c == null){
						processCollaborators = false;
						teamMember.addError('There is no repository defined for the parent Project Definition');
					}
				}
			}
		} else if (Trigger.isAfter) {
			if(Trigger.isInsert){
				// Add Collaborators to GitHub Repo
				GithubService.addCollaboratorsFuture(trigger.newMap.keySet());
			}
		}

		if(trigger.isBefore && trigger.isDelete && trigger.old.size() == 1) {
			Team_Member__c tm = [SELECT Github_Handle__c, Project_Definition__r.Repo_Name__c FROM Team_Member__c WHERE Id = :trigger.old[0].Id];
			GithubService.removeTeamMember(tm.Project_Definition__r.Repo_Name__c, tm.Github_Handle__c);
		}
}