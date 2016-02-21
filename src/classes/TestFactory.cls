@isTest
public class TestFactory {
	
	// User
	public static User factoryUser(Boolean dml, String profileName){
		Profile p = [SELECT Id FROM Profile WHERE Name=:profileName];
		Integer userkey = Math.round(Math.random()*1000);
		String userNameString = 'user.'+userKey+'@testorg.com';
		System.debug('USERNAME: '+userNameString);
        User u = new User(Alias = 'standt', Email=userNameString, 
            EmailEncodingKey='UTF-8', FirstName='Test', LastName=profileName, LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=userNameString);
        if(dml){
			insert u;
		}
		return u;
	}

	// oAuth Settings
	public static OAuth_Settings__c factoryOauthSetting(Boolean dml){
		OAuth_Settings__c oauth = OAuth_Settings__c.getOrgDefaults();
		oauth.Redirect_Url__c = 'codescience.com';
		if(dml){
			upsert oauth;
		}
		return oauth;
	}

	// User Settings
	public static UserDefinition__c factoryUserDefinition(Boolean dml){
		UserDefinition__c uds = UserDefinition__c.getInstance(UserInfo.getUserId());
		uds.VCS_Token__c = '1234567890';
		uds.CI_Token__c = '0987654321';
		if(dml){
			upsert uds;
		}
		return uds;
	}

	// Project Definition
	public static ProjectDefinition__c factoryProjectDefinition(Boolean dml){
		ProjectDefinition__c projectDef = new ProjectDefinition__c();
		projectDef.Name = 'Test Project';
		projectDef.Namespace__c = 'testnamespace';
		projectDef.Package_Name__c = 'testpackage';
		projectDef.Repo_Name__c = 'CodeScience/Test-Project';
		projectDef.Repo_Url__c = 'https://github.com/CodeScience/Test-Project';
		if(dml){
			upsert projectDef;
		}
		return projectDef;
	}

	// Team Members
	public static List<Team_Member__c> factoryTeamMembers(Boolean dml, ProjectDefinition__c projectDef, Integer count){
		List<Team_Member__c> members = new List<Team_Member__c>();
		String name = 'Test Member';
		String github = 'github';
		for(Integer i=1; i<=count; i++){
			members.add(factoryTeamMember(false, projectDef, null, name+i, github+i));
		}
		if(dml){
			upsert members;
		}
		return members;
	}
	public static Team_Member__c factoryTeamMember(Boolean dml, ProjectDefinition__c projectDef, Contact contact, String name, String github){
		Team_Member__c member = new Team_Member__c();
        if(contact == null){
        	contact = factoryContact(true,null,null);
        }
        member.Project_Definition__c = projectDef.Id;
        member.Contact__c = contact.Id;
        // Name manager
        List<String> nameList = nameGenerator(name);
        member.Name = nameList.get(0);
        member.First_Name__c = nameList.get(1);
        member.Last_Name__c = nameList.get(2);
		// GitHub Handle manager
        if(String.isBlank(github)){
			member.Github_Handle__c = 'github';
		}
		else {
			member.Github_Handle__c = github;
		}
		// DML
		if(dml){
			upsert member;
		}
        return member;
	}

	// Environment
	public static Environment__c factoryEnvironment(Boolean dml, ProjectDefinition__c projectDef, Environment__c parentEnv ,String name, String namespace, Boolean production, Boolean packaging){
		Environment__c env = new Environment__c();
		if(projectDef == null){
			projectDef = factoryProjectDefinition(true);
		}
		env.Name = name;
		env.CI_Project_Definition__c = projectDef.Id;
		env.Namespace__c = namespace;
		env.Packaging__c = packaging;
		env.Parent_Environment__c = parentEnv == null ? null : parentEnv.Id;
		env.Production__c = production;
		// DML
		if(dml){
			upsert env;
		}
        return env;
	}

	// Account
	public static Account factoryAccount(Boolean dml){
		Account account = new Account();
		account.Name = 'Test Account';
		if(dml){
			upsert account;
		}
        return account;
	}

	// Contact
	public static List<Contact> factoryContacts(Boolean dml, Account account, Integer count){
		List<Contact> contacts = new List<Contact>();
		String name = 'Test Contact';
		for(Integer i=1; i<=count; i++){
			contacts.add(factoryContact(false, account, name+i));
		}
		if(dml){
			upsert contacts;
		}
		return contacts;
	}
	public static Contact factoryContact(Boolean dml, Account account, String name){
		Contact contact = new Contact();
		if(account == null){
			account = factoryAccount(true);
		}
		// Name manager
        List<String> nameList = nameGenerator(name);
        contact.FirstName = nameList.get(1);
        contact.LastName = nameList.get(2);
        contact.AccountId = account.Id;
		if(dml){
			upsert contact;
		}
        return contact;
	}

	public static List<String> nameGenerator(String name){
		List<String> nameList = new List<String>();
		if(String.isBlank(name)){
			nameList.add('Test Name');
	        nameList.add('Test');
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
				nameList.add('Test');
				nameList.add(name);
			}
		}
		return nameList;
	}
	
}