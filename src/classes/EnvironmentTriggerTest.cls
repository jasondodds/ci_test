@isTest
public with sharing class EnvironmentTriggerTest {
    public static testMethod void environment_insert_test() {
        String getRefBody = '{"ref": "refs/heads/featureA","url": "https://api.github.com/repos/octocat/Hello-World/git/refs/heads/featureA","object": {"type": "commit","sha": "aa218f56b14c9653891f9e74264a383fa43fefbd","url": "https://api.github.com/repos/octocat/Hello-World/git/commits/aa218f56b14c9653891f9e74264a383fa43fefbd"}}';
        String createRefBody = '{"ref": "refs/heads/featureA","url": "https://api.github.com/repos/octocat/Hello-World/git/refs/heads/featureA","object": {"type": "commit","sha": "aa218f56b14c9653891f9e74264a383fa43fefbd","url": "https://api.github.com/repos/octocat/Hello-World/git/commits/aa218f56b14c9653891f9e74264a383fa43fefbd"}}';
        Test.setMock(HttpCalloutMock.class, new GithubCalloutMock(createRefBody,getRefBody));

        test.startTest();
            ProjectDefinition__c pd = new ProjectDefinition__c(Name='test', Repo_Name__c='CodeScience/test');
            insert pd ;

            // insert one at a time to run the createUserBranch method
            Environment__c parentEnv = new Environment__c(CI_Project_Definition__c=pd.Id, Name='Production', Production__c=true, Branch_Name__c='master');
            insert parentEnv;
            Environment__c env = new Environment__c(Name='test', CI_Project_Definition__c=pd.Id, Parent_Environment__c=parentEnv.Id, Branch_Name__c='test');
            insert env;
        test.stopTest();
    }

    public static testMethod void environment_insert_no_branch_test() {
        String getRefBody = '{"ref": "refs/heads/featureA","url": "https://api.github.com/repos/octocat/Hello-World/git/refs/heads/featureA","object": {"type": "commit","sha": "aa218f56b14c9653891f9e74264a383fa43fefbd","url": "https://api.github.com/repos/octocat/Hello-World/git/commits/aa218f56b14c9653891f9e74264a383fa43fefbd"}}';
        String createRefBody = '{"ref": "refs/heads/featureA","url": "https://api.github.com/repos/octocat/Hello-World/git/refs/heads/featureA","object": {"type": "commit","sha": "aa218f56b14c9653891f9e74264a383fa43fefbd","url": "https://api.github.com/repos/octocat/Hello-World/git/commits/aa218f56b14c9653891f9e74264a383fa43fefbd"}}';
        Test.setMock(HttpCalloutMock.class, new GithubCalloutMock(createRefBody,getRefBody));

        Test.startTest();
            ProjectDefinition__c pd = new ProjectDefinition__c(Name='test', Repo_Name__c='CodeScience/test');
            insert pd ;

            // insert one at a time to run the createUserBranch method
            Environment__c parentEnv = new Environment__c(CI_Project_Definition__c=pd.Id, Name='Production', Production__c=true, Branch_Name__c='master');
            insert parentEnv;
            Environment__c env = new Environment__c(Name='test', CI_Project_Definition__c=pd.Id, Parent_Environment__c=parentEnv.Id);
            
            try{
                insert env;
            } catch(GithubService.CustomException e) {
                system.assertEquals('The environment either does not exist or does not contain a parent or a branch name', e.getMessage());
            }
        Test.stopTest();
    }

    public static testMethod void environment_insert_no_repo_test() {
        String getRefBody = '{"ref": "refs/heads/featureA","url": "https://api.github.com/repos/octocat/Hello-World/git/refs/heads/featureA","object": {"type": "commit","sha": "aa218f56b14c9653891f9e74264a383fa43fefbd","url": "https://api.github.com/repos/octocat/Hello-World/git/commits/aa218f56b14c9653891f9e74264a383fa43fefbd"}}';
        String createRefBody = '{"ref": "refs/heads/featureA","url": "https://api.github.com/repos/octocat/Hello-World/git/refs/heads/featureA","object": {"type": "commit","sha": "aa218f56b14c9653891f9e74264a383fa43fefbd","url": "https://api.github.com/repos/octocat/Hello-World/git/commits/aa218f56b14c9653891f9e74264a383fa43fefbd"}}';
        Test.setMock(HttpCalloutMock.class, new GithubCalloutMock(createRefBody,getRefBody));

        Test.startTest();
            ProjectDefinition__c pd = new ProjectDefinition__c(Name='test');
            insert pd ;

            // insert one at a time to run the createUserBranch method
            Environment__c parentEnv = new Environment__c(CI_Project_Definition__c=pd.Id, Name='Production', Production__c=true, Branch_Name__c='master');
            insert parentEnv;
            Environment__c env = new Environment__c(Name='test', CI_Project_Definition__c=pd.Id, Parent_Environment__c=parentEnv.Id, Branch_Name__c='test');
            
            try{
                insert env;
            } catch(GithubService.CustomException e) {
                system.assertEquals('The CI Project Definition is missing one or more required fields', e.getMessage());
            }
        Test.stopTest();
    }

    public static testMethod void environment_insert_no_parent_branch_test() {
            String getRefBody = '{"ref": "refs/heads/featureA","url": "https://api.github.com/repos/octocat/Hello-World/git/refs/heads/featureA","object": {"type": "commit","sha": "aa218f56b14c9653891f9e74264a383fa43fefbd","url": "https://api.github.com/repos/octocat/Hello-World/git/commits/aa218f56b14c9653891f9e74264a383fa43fefbd"}}';
            String createRefBody = '{"ref": "refs/heads/featureA","url": "https://api.github.com/repos/octocat/Hello-World/git/refs/heads/featureA","object": {"type": "commit","sha": "aa218f56b14c9653891f9e74264a383fa43fefbd","url": "https://api.github.com/repos/octocat/Hello-World/git/commits/aa218f56b14c9653891f9e74264a383fa43fefbd"}}';
            Test.setMock(HttpCalloutMock.class, new GithubCalloutMock(createRefBody,getRefBody));
            
            Test.startTest();
            ProjectDefinition__c pd = new ProjectDefinition__c(Name='test', Repo_Name__c='CodeScience/test');
            insert pd ;

            // insert one at a time to run the createUserBranch method
            Environment__c parentEnv = new Environment__c(CI_Project_Definition__c=pd.Id, Name='Production', Production__c=true);
            insert parentEnv;
            Environment__c env = new Environment__c(Name='test', CI_Project_Definition__c=pd.Id, Parent_Environment__c=parentEnv.Id, Branch_Name__c='test');
            
            try{
                insert env;
            } catch(GithubService.CustomException e) {
                system.assertEquals('The CI Project Definition is missing one or more required fields', e.getMessage());
            }
        Test.stopTest();
    }
}