@isTest
public class AwsCalloutMock implements HttpCalloutMock {

    protected String response;

    public AwsCalloutMock(String response) {
        this.response = response;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        system.debug('ENDPOINT ' + req.getEndpoint());
        if(req.getEndpoint().contains('update-file') || req.getEndpoint().contains('seedrepo')) {
            res.setStatusCode(200);
            res.setBody(this.response);
            res.setHeader('Content-Type', 'application/json');
        }
        return res;
    }

}