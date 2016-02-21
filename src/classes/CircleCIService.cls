public with sharing class CircleCIService {
    public static final String BASE_URL = 'https://circleci.com/api/v1/';

    public static String getToken(){
        UserDefinition__c ud = UserDefinition__c.getInstance(UserInfo.getUserId());
        if(ud == null){
            Throw new CustomException('Error retrieving CircleCI token');
        }
        else {
            String accessToken = ud.CI_Token__c;
            return accessToken;
        }
        return null;
    }

    public static Boolean isValidToken(String token) {
        //uses the results of the me api call to determine if an access token is valid
        system.debug('IS VALID TOKEN');

        Map<String,Object> meResp = me(token);
        system.debug('RESP ' + meResp);
        Boolean isValid;
        if(meResp.containsKey('message')) {
            isValid = false;
        }
        else if(meResp.containsKey('login')) {
            UserDefinition__c uds = UserDefinition__c.getInstance(UserInfo.getUserId());
            uds.CI_Username__c = (String)meResp.get('login');
            upsert uds;
            isValid = true;
        }

        return isValid;
    }
    
    public static Map<String,Object> me(String token) {
        //set up request
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(BASE_URL + 'me?circle-token=' + token);
        req.setHeader('Accept', 'application/json');

        //execute request
        Http http = new Http();
        HttpResponse resp = http.send(req);
        //Map<String,String> resBody = (Map<String,String>)JSON.deserialize(resp.getBody(), Map<String,String>.class);
        if(resp.getStatusCode() != 200) {
            //String errorMessage = resBody.get('message');
            Throw new CustomException('Error retrieving CircleCI token');
        }
        return (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
    }

    public static String watchRepoFromProjectDefinition(ProjectDefinition__c projectDef){
        return JSON.serialize(watchRepo(CircleCIService.getToken(), projectDef.Repo_Name__c));
    }
    public static Map<String,Object> watchRepo(String token, String repo) {
        if(token == null || repo == null){
            Throw new CustomException('Error retrieving CircleCI token');
        }
        //set up request
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(BASE_URL + 'project/'+repo+'/follow?circle-token=' + token);
        req.setHeader('Accept', 'application/json');

        //execute request
        Http http = new Http();
        HttpResponse resp = http.send(req);

        if(resp.getStatusCode() != 200) {
            Throw new CustomException('Error retrieving CircleCI token');
        }
        return (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
    }

    public static Map<String,Object> addEnvironmentVariable(String token, String username, String project, String key, String value) {
        if(token == null) {
            throw new CustomException('Missing CI token.');
        }

        if(key == null || value == null) {
            throw new CustomException('Missing key or value.');
        }

        String endpoint = BASE_URL + 'project/' + username + '/' + project + '/envvar?circle-token=' + token;
        String body = '{"name":"' + key + '",' + '"value":"' + value + '"}';
        HttpResponse resp = makeCircleCallout('POST',endpoint,body);

        /*HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(BASE_URL + 'project/' + username + '/' + project + '/envvar?circle-token=' + token);
        system.debug('BASE URL ' + BASE_URL + 'project/' + username + '/' + project + '/envvar?circle-token=' + token);
        String body = '{"name":"' + key + '",' + '"value":"' + value + '"}';
        system.debug('BODY ' + body);
        req.setBody(body);

        Http http = new Http();
        HttpResponse resp = http.send(req);*/
        if(resp.getStatusCode() != 201) {
            throw new CustomException('Add variable failed.');
        }

        return (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
    }

    public static Map<String,Object> triggerBuild(String token, String username, String project, String branch) {
        if(token == null) {
            throw new CustomException('Missing CI token.');
        }

        if(username == null || project == null || branch == null) {
            throw new CustomException('Missing key or value.');
        }

        String endpoint = BASE_URL + 'project/' + username + '/' + project + '/tree/' + branch + '?circle-token=' + token;
        String body = '{}';
        HttpResponse resp = makeCircleCallout('POST',endpoint,body);

        /*HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(BASE_URL + 'project/' + username + '/' + project + '/tree/' + branch + '?circle-token=' + token);
        system.debug('BASE URL ' + BASE_URL + 'project/' + username + '/' + project + '/tree/' + branch + '?circle-token=' + token);
        String body = '{}';
        system.debug('BODY ' + body);
        req.setBody(body);

        Http http = new Http();
        HttpResponse resp = http.send(req);*/
        if(resp.getStatusCode() != 201) {
            throw new CustomException('Trigger Build failed.');
        }

        return (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
    }

    public static HttpResponse makeCircleCallout(String callVerb, String endpoint, String body){
        HttpRequest req = new HttpRequest();
        req.setMethod(callVerb.toUpperCase());
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(endpoint);
        system.debug('BASE URL ' + endpoint);
        system.debug('BODY ' + body);
        req.setBody(body);

        Http http = new Http();
        return http.send(req);
    }

    public class CustomException extends Exception {}
}