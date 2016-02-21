public with sharing class AwsService {

	public static String updateBuildProperties(ProjectDefinition__c projectDef, String branchName) {
        if(branchName == null){
            branchName = 'master';
        }
        UserDefinition__c ud = UserDefinition__c.getInstance(UserInfo.getUserId());
        if(ud == null){
            Throw new CustomException('No settings found for this user');
        }

		if(String.isBlank(projectDef.Repo_Name__c) || String.isBlank(projectDef.Package_Name__c) || String.isBlank(projectDef.Namespace__c)){
			Throw new CustomException('The CI Project Definition is missing one or more required fields');
		}
        String targetfileName = branchName == 'master' ? 'build.properties' : 'build.'+branchName.toLowerCase()+'.properties';

		String payload = '{'+
		'  "options": {'+
		'    "authtoken": "'+ud.VCS_Token__c+'",'+
		'    "source": {'+
		'      "repo": "CodeScience/circle-start",'+
		'      "branch": "ci-accelerator",'+
		'      "path": "build/build.properties"'+
		'    },'+
		'    "target": {'+
		'      "repo": "'+projectDef.Repo_Name__c+'",'+
		'      "branch": "'+branchName+'",'+
		'      "path": "build/'+targetfileName+'"'+
		'    },'+
		'    "properties": ['+
		'      ["SF_PACKAGE_NAME", "'+projectDef.Package_Name__c+'"],'+
		'      ["SF_NAMESPACE", "'+projectDef.Namespace__c+'"]'+
		'    ]'+
		'  }'+
		'}';

        Code_Accelerator_Setting__mdt cas = [SELECT API_Token__c, API_Stage__c, AWS_Endpoint__c FROM Code_Accelerator_Setting__mdt WHERE MasterLabel = 'Integration Setting' LIMIT 1];

		//setup the http request
        HttpRequest req = new HttpRequest();  
        String endpoint = cas.AWS_Endpoint__c+'/'+cas.API_Stage__c+'/update-file';
        System.debug(endpoint);
        req.setMethod('POST');
        req.setHeader('x-api-key', cas.API_Token__c);
        req.setEndpoint(endpoint);
        req.setBody(payload);
        System.debug(req);

        Http http = new Http();
        HttpResponse resp = http.send(req);
        System.debug(resp.getStatusCode());
        System.debug(resp.getBody());
        if(resp.getStatusCode() != 200 || resp.getBody().contains('errorMessage')) {
            String errorString = getErrorString(resp.getBody());
            Throw new CustomException(errorString);
        }
        return resp.getBody();
	}

    public static String addCircleResources(ProjectDefinition__c projectDef) {
        if(String.isBlank(projectDef.Repo_Name__c)){
            Throw new CustomException('The CI Project Definition is missing one or more required fields');
        }
        List<String> repoSplit = projectDef.Repo_Name__c.split('/');
        String response = seedRepo('CodeScience','circle-start','ci-accelerator',repoSplit[0],repoSplit[1],'Committing CircleCI resouces.');
        return response;
    }

    public static String seedRepo(String sourceOrgName, String sourceRepoName, String sourceBranch, String targetOrgName, String targetRepoName, String commitMessage){
        UserDefinition__c ud = UserDefinition__c.getInstance(UserInfo.getUserId());
        String body = '{"source_org": "'+sourceOrgName+'","source_repo": "'+sourceRepoName+'","source_branch": "'+sourceBranch+'","token": "' + ud.VCS_Token__c + '","target_org": "'+targetOrgName+'","target_repo": "'+targetRepoName+'","message": "'+commitMessage+'"}';
        System.debug(body);
        Code_Accelerator_Setting__mdt cas = [SELECT API_Token__c, API_Stage__c, AWS_Endpoint__c FROM Code_Accelerator_Setting__mdt WHERE MasterLabel = 'Integration Setting' LIMIT 1];

        HttpRequest req = new HttpRequest();  
        String endpoint = cas.AWS_Endpoint__c + '/' + cas.API_Stage__c + '/seedrepo';
        req.setMethod('POST');
        req.setHeader('Authorization', cas.API_Token__c);
        req.setEndpoint(endpoint);
        req.setBody(body);
        req.setTimeout(60000);

        Http http = new Http();
        HttpResponse resp = http.send(req);
        System.debug(resp.getBody());
        return resp.getBody();
    }

	public static String getErrorString(String response){
        String errorMessage = '';
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response);
        errorMessage = (String)m.get('errorMessage');
        return errorMessage;
    }

	public class CustomException extends Exception {}
}