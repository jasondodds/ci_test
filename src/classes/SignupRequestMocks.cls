@isTest
public class SignupRequestMocks implements HttpCalloutMock {
    private String tokenResponse;
    private String circleResponse;
    private String githubCreateResponse;
    private String githubGetResponse;
    private String queryResponse;
    private String insertResponse;

    public SignupRequestMocks(String tr, String cr, String gcr, String ggr, String qr, String ir) {
        this.tokenResponse        = tr;
        this.circleResponse       = cr;
        this.githubCreateResponse = gcr;
        this.githubGetResponse    = ggr;
        this.queryResponse        = qr;
        this.insertResponse       = ir;
    }

    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();

        //if the request is a salesforce token req
        if(req.getEndpoint().contains('login.salesforce')) {
            res.setBody(this.tokenResponse);
            res.setStatusCode(200);
        }
        //if the request is a circleci env variable
        else if(req.getEndpoint().contains('circleci')) {
            res.setBody(this.circleResponse);
            res.setStatusCode(201);
        }
        //if its a github request to create reference
        else if(req.getEndpoint().contains('github') && req.getMethod() == 'POST') {
            res.setBody(this.githubCreateResponse);
            res.setStatusCode(201);
        }
        //if its a github request to get reference
        else if(req.getEndpoint().contains('github') && req.getMethod() == 'GET') {
            res.setBody(this.githubGetResponse);
            res.setStatusCode(200);
        }
        else if(req.getEndpoint().contains('query')) {
            res.setBody(this.queryResponse);
            res.setStatusCode(200);
        }
        else if(req.getEndpoint().contains('sobjects')) {
            res.setBody(this.insertResponse);
            res.setStatusCode(200);
        }

        return res;
    }

}