@isTest
public with sharing class GithubCalloutMock implements HttpCalloutMock {
    protected String orgResp;
    protected String getRefResp;

    public GithubCalloutMock(String orgResp, String getRefResp) {
        this.orgResp = orgResp;
        this.getRefResp = getRefResp;
    }

    public GithubCalloutMock(String orgResp) {
        this.orgResp = orgResp;
    }

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        //if its a token exchange response
        system.debug('ENDPOINT ' + req.getEndpoint());
        if(req.getEndpoint().contains('access_token')) {
            res.setStatusCode(200);
            res.setBody('{"access_token":"e72e16c7e42f292c6912e7710c838347ae178b4a", "scope":"repo,gist", "token_type":"bearer"}');
            res.setHeader('Content-Type', 'application/json');
        }
        else if(req.getEndpoint().contains('/user/orgs')) {
            system.debug('IN USER ORGS');
            res.setStatusCode(200);
            res.setBody(this.orgResp);
            res.setHeader('Content-Type', 'application/json');
        }
        else if(req.getEndpoint().contains('/git/refs/')) {
            res.setStatusCode(200);
            res.setBody(this.getRefResp);
        }
        else if(req.getEndpoint().contains('/orgs/CodeScience/members')) {
            system.debug('IN ORG');
            res.setHeader('Link', '<https://api.github.com/organizations/5943746/members?page=2>; rel="next"');
            res.setStatusCode(200);
            res.setBody(this.orgResp);
            res.setHeader('Content-Type', 'application/json');
        }
        else if(req.getEndpoint().contains('/orgs/CodeScience')) {
            system.debug('IN ORG');
            res.setStatusCode(201);
            res.setBody(this.orgResp);
            res.setHeader('Content-Type', 'application/json');
        }
        else if(req.getEndpoint().contains('collaborators')) {
            res.setStatusCode(204);
            res.setBody('');
        }
        else if(req.getEndpoint().contains('teams') && req.getEndpoint().contains('repos')) {
            res.setStatusCode(204);
            res.setBody('');
        }
        else {
            res.setStatusCode(201);
            res.setBody(this.orgResp);
            res.setHeader('Content-Type', 'application/json');
        }

        return res;
    }
}