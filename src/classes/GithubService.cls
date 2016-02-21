public with sharing class GithubService {
    

    //static urls for formatting
    private static final String BASE_GH_OAUTH_LINK = 'https://github.com/login/oauth/authorize?client_id={0}&redirect_uri={1}&scope=repo';
    private static final String GH_ACCESS_TOKEN_URL = 'https://github.com/login/oauth/access_token?client_id={0}&client_secret={1}&code={2}';
    private static final String BASE_GH_URL = 'https://api.github.com';

    @future(callout=true)
    public static void removeTeamMember(String repoName, String handle) {
        removeCollaborator(null, repoName, handle);
    }

    public static void createOAuthSettings() {
        //called from the UserSetupController init method and page load action of the User Setup page
        try {
            system.debug('IN CREATE OAUTH SETTINGS');
            system.debug('PARAMETERS ' + ApexPages.CurrentPage().getParameters());
            //check that the code is in the response and call the getToken method
            if(ApexPages.CurrentPage().getParameters().containsKey('code')) {
                String accessToken = getToken(ApexPages.CurrentPage().getParameters().get('code'));

                //check if the token is valid
                if(isValidToken(accessToken)) {
                    //not sure what we want to do here if the token is valid
                    UserDefinition__c uds = UserDefinition__c.getInstance(UserInfo.getUserId());
                    uds.VCS_Token__c = accessToken;
                    upsert uds;
                }
            }
        }
        catch (Exception e){
            System.debug(e.getLineNumber()+': '+e.getMessage());
            Throw new CustomException(e.getMessage());
        }
    }

    @future(callout=true)
    public static void createUserBranch(Id envId) {
        List<Environment__c> envs = [SELECT Name, Branch_Name__c, Parent_Environment__r.Branch_Name__c, CI_Project_Definition__r.Id, CI_Project_Definition__r.Repo_Name__c FROM Environment__c WHERE Id = :envId];
        //if the environment name is production, it's master and we don't need to create a branch
        if(envs.size() == 1 && envs[0].Name != 'Production') {
            system.debug('ENVS ' + envs);
            if(envs.size() == 0 || String.isBlank(envs[0].Branch_Name__c)) {
                return;
            }

            Environment__c env = envs[0];

            if(String.isBlank(env.CI_Project_Definition__r.Repo_Name__c)){
                return;
            }

            List<String> repoSplit = env.CI_Project_Definition__r.Repo_Name__c.split('/');
            String orgName = repoSplit[0];
            String repoName = repoSplit[1];

            //get the sha of the master branch
            //String parentBranch = env.Parent_Environment__r.Branch_Name__c;
            String parentBranch = 'master';
            String resp = GithubService.getReference(null, orgName, repoName, 'heads/' + parentBranch);
            system.debug('RESP ' + resp);
            Object crBody = JSON.deserializeUntyped(resp);
            Map<String,Object> crRespBody = (Map<String,Object>)crBody;
            Map<String,Object> objectBody = (Map<String,Object>)crRespBody.get('object');
            String sha = (String)objectBody.get('sha');

            //create a new branch based on master
            Boolean branchCreated = createReference(null, orgName, repoName, env.Branch_Name__c, sha);
            
            if(!branchCreated) {
                return;
            }

            //If Test is running, suppress second callout due to initial callout to GitHub
            if(!Test.isRunningTest()){
                ProjectDefinition__c pd = [SELECT Repo_Name__c, Package_Name__c, Namespace__c FROM ProjectDefinition__c WHERE Id = :env.CI_Project_Definition__r.Id];
                AwsServiCE.updateBuildProperties(pd, env.Branch_Name__c);
            }

            return;
        }   
    }   

    public static Boolean isValidToken(String at) {
        //execute a user organizations callout as basis for determining token validity
        try {
            String orgString = organizations(at);
            List<Map<String,String>> orgs;
            Map<String,String> error;

            //if org string starts with a curly bracket it gets cast to a Map<String,String> 
            if(orgString.startsWith('[')) {
                orgs = (List<Map<String,String>>)JSON.deserialize(orgString,List<Map<String,String>>.class);
            }
            // if the org string starts with a square bracket it gets cast to a List<Map<String,String>>
            else if(orgString.startsWith('{')) {
                error = (Map<String,String>)JSON.deserialize(orgString,Map<String,String>.class);
            }

            //if we get atleast one org (we can assume that they will at least have access to the codescience repo)
            if(orgs != null && orgs.size() > 0) {
                //String resp = user(at);
                //Object userObj = (Object)JSON.deserializeUntyped(resp);
                //Map<String,Object> user = (Map<String,Object>)userObj;
                //UserDefinition__c ud = UserDefinition__c.getInstance(UserInfo.getUserId());
                //ud.VCS_Username__c = (String)user.get('login');
                //upsert ud;
                return true;
            }
        }
        catch (Exception e){
            System.debug(e.getLineNumber()+': '+e.getMessage());
            Throw new CustomException(e.getMessage());
            return false;
        }
        return false;
    }

    public static PageReference oauthRedirect() {
        //redirect to the oauth link 
        system.debug('OAUTH REDIRECT');
        //get the github client and redirect url
        OAuth_Settings__c os = OAuth_Settings__c.getOrgDefaults();
        Code_Accelerator_Setting__mdt oauth = [SELECT CS_GitHub_Client_Id__c, CS_GitHub_Client_Secret__c FROM Code_Accelerator_Setting__mdt WHERE MasterLabel = 'Integration Setting' LIMIT 1];
        String clientId = oauth.CS_GitHub_Client_Id__c;
        String redirectUrl = os.Redirect_Url__c;
        
        //format the oauth url
        String ghOauthLink = String.format(BASE_GH_OAUTH_LINK, new String[]{clientId, redirectUrl});
        
        PageReference pr = new PageReference(ghOauthLink);
        pr.setRedirect(true);
        
        return pr;
    }

    public static String getToken(String code) {
        //exchange the code for access token
        Code_Accelerator_Setting__mdt oauth = [SELECT CS_GitHub_Client_Id__c, CS_GitHub_Client_Secret__c FROM Code_Accelerator_Setting__mdt WHERE MasterLabel = 'Integration Setting' LIMIT 1];
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(String.format(GH_ACCESS_TOKEN_URL, new String[]{oauth.CS_GitHub_Client_Id__c,oauth.CS_GitHub_Client_Secret__c,code}));
        Http http = new Http();
        HttpResponse resp = http.send(req);
        if(resp.getStatusCode() != 200) {
            String errorString = getErrorString(resp.getBody());
            Throw new CustomException(errorString);
        }
        Map<String,String> resBody = (Map<String,String>)JSON.deserialize(resp.getBody(), Map<String,String>.class);
        return resBody.get('access_token');
    }

    public static String user(String at) {
        String accessToken;
        if(at == null) {
            //get the user definition for the access token 
            UserDefinition__c ud = UserDefinition__c.getInstance(UserInfo.getUserId());
            accessToken = ud.VCS_Token__c;
        }
        else {
            accessToken = at;
        }

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Authorization', 'token ' + accessToken);
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(BASE_GH_URL + '/user');

        Http http = new Http();
        HttpResponse resp = http.send(req);

        if(resp.getStatusCode() != 200) {
            throw new CustomException('Github user call failed.');
        }

        return resp.getBody();
    }

    public static String organizations(String at) {
        String accessToken;
        if(at == null) {
            //get the user definition for the access token 
            UserDefinition__c ud = UserDefinition__c.getInstance(UserInfo.getUserId());
            accessToken = ud.VCS_Token__c;
        }
        else {
            accessToken = at;
        }

        //setup the http request
        HttpRequest req = new HttpRequest();          
        req.setMethod('GET');
        req.setHeader('Authorization', 'token ' + accessToken);
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(BASE_GH_URL + '/user/orgs');

        Http http = new Http();
        HttpResponse resp = http.send(req);
        if(resp.getStatusCode() != 200) {
            String errorString = getErrorString(resp.getBody());
            Throw new CustomException(errorString);
        }
        return resp.getBody();
    }

    public static List<String> getOrgMembers(String at, String org){
        String accessToken;
        String pageLinks = '';
        List<String> gitHubMembers = new List<String>();
        Integer pageCount = 0;

        if(at == null) {
            //get the user definition for the access token 
            UserDefinition__c ud = UserDefinition__c.getInstance(UserInfo.getUserId());
            accessToken = ud.VCS_Token__c;
        }
        else {
            accessToken = at; 
        }

        //setup the http request
        HttpRequest req = new HttpRequest();
        Http http = new Http();       
        req.setMethod('GET');
        req.setHeader('Authorization', 'token ' + accessToken);
        req.setHeader('Accept', 'application/json');
         
        do{
            pageCount++;
            req.setEndpoint(BASE_GH_URL + '/orgs/'+org+'/members?page='+pageCount);
        
            HttpResponse resp = http.send(req);
            pageLinks = resp.getHeader('Link');
            System.debug(pageLinks);
            
            if(resp.getStatusCode() != 200) {
                String errorString = getErrorString(resp.getBody());
                Throw new CustomException(errorString);
            }
            System.debug(resp.getBody());
            List<Object> entries = (List<Object>)JSON.deserializeUntyped(resp.getBody());
            for(Object entry : entries){
                Map<String,Object> entryMap = (Map<String,Object>)entry;
                String username = (String)entryMap.get('login');
                gitHubMembers.add(username);
            }
        }
        while (pageLinks.contains('rel="last"') && pageCount <=10);
        
        return gitHubMembers;
    }

    public static String createRepoFromProjectDefinition(ProjectDefinition__c projectDef){
        String repoName = projectDef.Name.replace(' ', '-');
        return createRepo(null, repoName, 'CodeScience', true, projectDef.Id);
    }

    public static String createRepo(String at, String repoName, String organization, Boolean isPrivate, Id projectDefId){
        try{
            String accessToken;
            if(at == null) {
                //get the user definition for the access token 
                UserDefinition__c ud = UserDefinition__c.getInstance(UserInfo.getUserId());
                accessToken = ud.VCS_Token__c;
            }
            else {
                accessToken = at;
            }

            //setup the http request
            HttpRequest req = new HttpRequest();          
            req.setMethod('POST');
            req.setHeader('Authorization', 'token ' + accessToken);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type', 'application/json; charset=utf-8');
            req.setEndpoint(BASE_GH_URL + '/orgs/'+organization+'/repos');
            String body = '{'+
                    '"name":"'+repoName+'",'+
                    '"private":'+isPrivate+
                '}';
            req.setBody(body);

            Http http = new Http();
            HttpResponse resp = http.send(req);
            System.debug(resp.getStatusCode());
            System.debug(resp.getBody());
            if(resp.getStatusCode() != 201) {
                String errorString = getErrorString(resp.getBody());
                Throw new CustomException(errorString);
            }

            // Update the project definition with the repository information
            if(projectDefId != null){
                ProjectDefinition__c projectDef = [SELECT Repo_Name__c, Repo_Url__c FROM ProjectDefinition__c WHERE Id = :projectDefId LIMIT 1];
                if(projectDef != null){
                    projectDef.Repo_Name__c = 'CodeScience/'+repoName;
                    projectDef.Repo_Url__c = 'https://github.com/CodeScience/'+repoName;
                    update projectDef;
                }
            }

            return resp.getBody();
        }
        catch(Exception e){
            Throw new CustomException(e.getMessage());
        }
        return null;
    }

    public static String getReference(String at, String org, String repo, String ref) {
        /* GET /repos/:owner/:repo/git/refs/:ref */

        String accessToken;
        if(at == null) {
            //get the user definition for the access token 
            UserDefinition__c ud = UserDefinition__c.getInstance(UserInfo.getUserId());
            accessToken = ud.VCS_Token__c;
        }
        else {
            accessToken = at;
        }

        //setup the http request
        HttpRequest req = new HttpRequest();          
        req.setMethod('GET');
        req.setHeader('Authorization', 'token ' + accessToken);
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(String.format(BASE_GH_URL + '/repos/{0}/{1}/git/refs/{2}', new String[]{org, repo, ref}));

        Http http = new Http();
        HttpResponse resp = http.send(req);

        return resp.getBody();
    }

    public static Boolean createReference(String at, String org, String repo, String ref, String sha) {
        /* POST /repos/:owner/:repo/git/refs */
        
        String accessToken;
        if(at == null) {
            //get the user definition for the access token 
            UserDefinition__c ud = UserDefinition__c.getInstance(UserInfo.getUserId());
            accessToken = ud.VCS_Token__c;
        }
        else {
            accessToken = at;
        }

        //setup the http request
        HttpRequest req = new HttpRequest();          
        req.setMethod('POST');
        req.setHeader('Authorization', 'token ' + accessToken);
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(BASE_GH_URL + String.format('/repos/{0}/{1}/git/refs', new String[]{org, repo}));
        String body = '{"ref": "' + 'refs/heads/' + ref + '","sha": "' + sha + '"}';
        req.setBody(body);

        Http http = new Http();
        HttpResponse resp = http.send(req);

        return resp.getStatusCode() == 201 ? true : false;
    }

    public static String getErrorString(String response){
        String errorMessage = '';
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response);
        errorMessage = (String)m.get('message')+' - ';
        List<Object> errors = (List<Object>)m.get('errors');
        for(Object error: errors){
            Map<String,Object> errorMap = (Map<String,Object>)error;
            errorMessage += (String)errorMap.get('message');
        }
        return errorMessage;
    }

    @future(callout=true)
    public static void addCollaboratorsFuture(Set<Id> ids){
        List<Team_Member__c> teamMembers = [SELECT Id, Github_Handle__c, Project_Definition__r.Repo_Name__c FROM Team_Member__c WHERE Id IN :ids];
        for(Team_Member__c teamMember : teamMembers){
            if(teamMember.Github_Handle__c != null){
                Boolean success = addCollaborator(null,teamMember.Project_Definition__r.Repo_Name__c, teamMember.Github_Handle__c, 'admin');
                if(success){
                    teamMember.Processed__c = true;
                }
            }
        }
        update teamMembers;
    }

    public static Boolean addCollaborator(String at, String repoName, String collaborator, String permissionLevel) {
        String accessToken;
        if(at == null) {
            //get the user definition for the access token 
            UserDefinition__c ud = UserDefinition__c.getInstance(UserInfo.getUserId());
            accessToken = ud.VCS_Token__c;
        }
        else {
            accessToken = at;
        }

        //setup the http request
        HttpRequest req = new HttpRequest();
        req.setMethod('PUT');
        req.setHeader('Authorization', 'token ' + accessToken);
        req.setHeader('Accept', 'application/vnd.github.ironman-preview+json');
        req.setHeader('Content-Type', 'application/json; charset=utf-8');
        req.setEndpoint(BASE_GH_URL + '/repos/' + repoName + '/collaborators/'+collaborator);
        String body = '{"permission": "' + permissionLevel + '"}';
        system.debug('BODY ' + body);
        req.setBody(body);

        Http http = new Http();
        HttpResponse resp = http.send(req);
        Boolean success = true;
        if(resp.getStatusCode() != 200){
            success = false;
        }
        return success;
    }

    public static Boolean removeCollaborator(String at, String repoName, String cName) {
        /* DELETE /repos/:owner/:repo/collaborators/:username */

        String accessToken;
        if(at == null) {
            //get the user definition for the access token 
            UserDefinition__c ud = UserDefinition__c.getInstance(UserInfo.getUserId());
            accessToken = ud.VCS_Token__c;
        }
        else {
            accessToken = at;
        }

        //setup the http request
        HttpRequest req = new HttpRequest();
        req.setMethod('DELETE');
        req.setHeader('Authorization', 'token ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=utf-8');
        req.setEndpoint(BASE_GH_URL + '/repos/' + repoName + '/collaborators/' + cName);
        system.debug('ENDPOINT ' + req.getEndpoint());
        Http http= new Http();
        HttpResponse resp = http.send(req);
        Boolean success = true;
        system.debug('STATUS CODE ' + resp.getStatusCode());
        if(resp.getStatusCode() != 204) {
            success = false;
        }

        return success;
    }

    public class CustomException extends Exception {}
}