@isTest
public with sharing class CircleCICalloutMock implements HttpCalloutMock {
    protected String meResp;

    public CircleCICalloutMock(String meResp) {
        this.meResp = meResp;
    }

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        if(req.getEndpoint().contains('me?circle-token') || req.getEndpoint().contains('follow?circle-token')) {
            res.setStatusCode(200);
            res.setBody(this.meResp);
            res.setHeader('Content-Type','application/json');
        }

        return res;
    }
}