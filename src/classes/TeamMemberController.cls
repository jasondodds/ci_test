public with sharing class TeamMemberController {

	private final Team_Member__c member;

    public TeamMemberController(ApexPages.StandardController stdController) {
        this.member = (Team_Member__c)stdController.getRecord();

    }

    public List<SelectOption> getGithubUsers() {
        List<SelectOption> options = new List<SelectOption>();
        List<String> gitHubUsers = GithubService.getOrgMembers(null, 'CodeScience');
        options.add(new SelectOption('','None'));
        for(String user : gitHubUsers){
            options.add(new SelectOption(user,user));
        }
        return options;
    }

}