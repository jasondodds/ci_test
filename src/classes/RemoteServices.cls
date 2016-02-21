public with sharing class RemoteServices {
	public RemoteServices(ApexPages.StandardController stdController) {
	}

	@RemoteAction
	public static ProjectDefinition__c createWizardProject(String jsonString) {
		System.debug(loggingLevel.Info, 'CREATING A PROJECT FROM WIZARD DATA');
		try {
			WizardPayload payload = parsePayload(jsonString);
			ProjectDefinition__c projectDef = new ProjectDefinition__c();
			projectDef.Name = payload.projectName;
			projectDef.Description__c = payload.projectDescription;
			projectDef.Namespace__c = payload.namespace;
			projectDef.Package_Name__c = payload.packageName;
			insert projectDef;
			return projectDef;
		} catch(Exception e) {
			System.debug(e.getMessage());
			return null;
		}
	}

	@RemoteAction
    public static String createRepo(Id projectDefId){
		System.debug(loggingLevel.Info, 'CREATING THE REPO');
        ProjectDefinition__c projectDef = [SELECT Name, Package_Name__c, Description__c FROM ProjectDefinition__c WHERE Id = :projectDefId LIMIT 1];
        if(projectDef != null){
            return GithubService.createRepoFromProjectDefinition(projectDef);
        }
        else {
            Throw new CustomException('There was no Project Setup document with this id');
        }
        return null;
    }

    @RemoteAction
    public static String addCircleResources(Id projectDefId) {
		System.debug(loggingLevel.Info, 'ADDING RESOURCES FOR CIRCLE CI');
        ProjectDefinition__c projectDef = [SELECT Name, Package_Name__c, Namespace__c, Repo_Name__c, Repo_Url__c FROM ProjectDefinition__c WHERE Id = :projectDefId LIMIT 1];
        if(projectDef != null){
            return AwsService.addCircleResources(projectDef);
        }
        else {
            Throw new CustomException('There was no Project Setup document with this id');
        }
        return null;
    }

    @RemoteAction
    public static String updateBuildProps(Id projectDefId){
		System.debug(loggingLevel.Info, 'UPDATING THE BUILD PROPERTIES');
        ProjectDefinition__c projectDef = [SELECT Name, Package_Name__c, Namespace__c, Repo_Name__c, Repo_Url__c FROM ProjectDefinition__c WHERE Id = :projectDefId LIMIT 1];
        if(projectDef != null){
            return AwsService.updateBuildProperties(projectDef,null);
        }
        else {
            Throw new CustomException('There was no Project Setup document with this id');
        }
        return null;
    }

	@RemoteAction
    public static String seedRepos(String jsonString, Id projectDefId) {
		System.debug(loggingLevel.Info, 'SEEDING REPOSITORIES');
		ProjectDefinition__c projectDef = [SELECT Name, Package_Name__c, Namespace__c, Repo_Name__c, Repo_Url__c FROM ProjectDefinition__c WHERE Id = :projectDefId LIMIT 1];
		if(projectDef != null){
            WizardPayload payload = parsePayload(jsonString);
			for(Repository repo : payload.repositories){
				if(repo.isSelected){
					String urlRoot = 'https://github.com/';
					System.debug('Adding resources from '+repo.name+': '+repo.url);
					List<String> repoSplit = urlRoot.difference(repo.url).split('/');
		        	AwsService.seedRepo(repoSplit[0],repoSplit[1],'ci-accelerator',projectDef.Repo_Name__c.split('/')[0],projectDef.Repo_Name__c.split('/')[1],'Seeding from '+repo.name+' repo.');
				}
			}
			return 'success';
        }
        else {
            Throw new CustomException('There was no Project Setup document with this id');
        }
        return null;
    }

    @RemoteAction
    public static String circleWatchRepo(Id projectDefId) {
		System.debug(loggingLevel.Info, 'TELLING CIRCLE CI TO WATCH THE REPO');
        ProjectDefinition__c projectDef = [SELECT Name, Package_Name__c, Namespace__c, Repo_Name__c, Repo_Url__c FROM ProjectDefinition__c WHERE Id = :projectDefId LIMIT 1];
        if(projectDef != null){
            return CircleCIService.watchRepoFromProjectDefinition(projectDef);
        }
        else {
            Throw new CustomException('There was no Project Setup document with this id');
        }
        return null;
    }

    @RemoteAction
    public static Boolean createTeamMembers(String jsonString, Id projectDefId){
		System.debug(loggingLevel.Info, 'CREATING TEAM MEMBERS AND ADDING AS COLLABORATORS IN GITHUB');
    	try {
			WizardPayload payload = parsePayload(jsonString);
			List<Team_Member__c> teamMembers = new List<Team_Member__c>();
			List<String> contactIds = new List<String>();
			for(TeamMember payloadTeamMember : payload.teamMembers){
				if(payloadTeamMember.sfdc != 'null'&& payloadTeamMember.sfdc != ''){
					contactIds.add(payloadTeamMember.sfdc);
				}
			}
			Map<Id,Contact> contactsById = new Map<Id,Contact>([SELECT Id, FirstName, LastName, Email, GitHub_Handle__c FROM Contact WHERE Id IN :contactIds]);
			List<Contact> contactsToUpdate = new List<Contact>();
			for(TeamMember payloadTeamMember : payload.teamMembers){
				Boolean hasContact = contactsById.containsKey(payloadTeamMember.sfdc);
				Team_Member__c teamMember = new Team_Member__c();
				Contact memberContact = new Contact();
				if(hasContact){
					memberContact = contactsById.get(payloadTeamMember.sfdc);
					if(memberContact.GitHub_Handle__c != payloadTeamMember.githubHandle){
						memberContact.GitHub_Handle__c = payloadTeamMember.githubHandle;
						contactsToUpdate.add(memberContact);
					}
				} else {
					List<String> nameList = nameGenerator(payloadTeamMember.name);
					memberContact.FirstName = nameList.get(1);
					memberContact.LastName	= nameList.get(2);
					memberContact.Email = payloadTeamMember.email;
					memberContact.GitHub_Handle__c = payloadTeamMember.githubHandle;
					insert memberContact;
				}
				teamMember.Contact__c = memberContact.Id;
				teamMember.Project_Definition__c = projectDefId;
				teamMember.Email__c = memberContact.Email;
				teamMember.First_Name__c = memberContact.FirstName;
				teamMember.Last_Name__c = memberContact.LastName;
				teamMember.Name = teamMember.First_Name__c + ' ' + teamMember.Last_Name__c;
				teamMember.GitHub_Handle__c = memberContact.GitHub_Handle__c;
				teamMembers.add(teamMember);
			}
			update contactsToUpdate;
			insert teamMembers;
			return true;
		} catch(Exception e) {
			Throw new CustomException('There was an issue creating Team Members: '+e.getMessage());
			System.debug(e.getMessage());
			return false;
		}
	}

    @RemoteAction
	public static Boolean createEnvironments(String jsonString, Id projectDefId){
		System.debug(loggingLevel.Info, 'CREATING ENVIRONMENTS AND SETTING UP BRANCHES');
		try {
			WizardPayload payload = parsePayload(jsonString);
			List<Team_Member__c> teamMembers = [SELECT Id, Name, Contact__c, Email__c, First_Name__c, Last_Name__c, Github_Handle__c, Project_Definition__c FROM Team_Member__c WHERE Project_Definition__c = :projectDefId];
			List<Environment__c> environments = new List<Environment__c>();
			for(Environment environment : payload.environments){
				if(environment.isSelected == true){
					Environment__c newEnvironment = new Environment__c();
					newEnvironment.Name = environment.name;
					newEnvironment.CI_Project_Definition__c = projectDefId;
					newEnvironment.Namespace__c = environment.namespace;
					newEnvironment.Create_Users__c = true;
					newEnvironment.Packaging__c = environment.isPackaging;
					newEnvironment.Production__c = environment.isProduction;
					//newEnvironment.Parent_Environment__c = environment.parentEnvironment;
					environments.add(newEnvironment);
				}
			}
			insert environments;
			return true;
		} catch(Exception e) {
			Throw new CustomException('There was an issue creating Environments: '+e.getMessage());
			System.debug(e.getMessage());
			return false;
		}
	}

	public static WizardPayload parsePayload(String jsonString) {
		try {
			WizardPayload payload = (WizardPayload)JSON.deserialize(jsonString, WizardPayload.class);
			//System.debug(loggingLevel.Info, '*** payload: ' + payload);
			return payload;
		} catch(Exception e) {
			System.debug(e.getMessage());
			return null;
		}
	}

	public static List<String> nameGenerator(String name){
		List<String> nameList = new List<String>();
		if(String.isBlank(name)){
			nameList.add('Contact Name');
	        nameList.add('Contact');
	        nameList.add('Name');
		}
		else {
			nameList.add(name);
			Integer spaceIndex = name.indexOf(' ');
			if(spaceIndex > 0){
	        	nameList.add(name.left(spaceIndex));
				nameList.add(name.right(name.length() - (spaceIndex + 1)));
			}
			else {
				nameList.add('Contact');
				nameList.add(name);
			}
		}
		return nameList;
	}

    public class CustomException extends Exception {}

	public class WizardPayload {
		public String id {get;set;}
		public String projectName {get;set;}
		public String packageName {get;set;}
		public String projectDescription {get;set;}
		public String namespace {get;set;}
		public List<TeamMember> teamMembers {get;set;}
		public List<Environment> environments {get;set;}
		public List<Repository> repositories {get;set;}
	}

	public class TeamMember {
		public String id {get;set;}
		public String sfdc {get;set;}
		public String name {get;set;}
		public String firstName {get;set;}
		public String lastName {get;set;}
		public String githubHandle {get;set;}
		public String role {get;set;}
		public String email {get;set;}
		public String contact {get;set;}
		public String projectDefinition {get;set;}
	}

	public class Environment {
		public String id {get;set;}
		public String name {get;set;}
		public String branchName {get;set;}
		public String projectDefinition {get;set;}
		public String namespace {get;set;}
		public String parentEnvironment {get;set;}
		public Boolean isPackaging {get;set;}
		public Boolean isProduction {get;set;}
		public Boolean isSelected {get;set;}
	}

	public class Repository {
		public String id {get;set;}
		public String name {get;set;}
		public String url {get;set;}
		public Boolean isSelected {get;set;}
	}
}