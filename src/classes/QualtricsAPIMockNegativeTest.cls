@isTest
public class QualtricsAPIMockNegativeTest implements HttpCalloutMock{

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;



	public QualtricsAPIMockNegativeTest() {
		
	}
	public HTTPResponse respond(HTTPRequest req) {
        //System.assertEquals('http://api.salesforce.com/foo/bar', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        System.debug('$$$ req.getBody(); is ' + req.getBody());
        System.debug('request.getEndPoint() is ' + req.getEndPoint());


        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');         
        if(req.getEndpoint().contains('Request=getUserInfo')){
                //res.setBody('{"Meta": {"Status": "Success","Debug": ""},"Result": "mjiHDKkXSslRPLUhXQjyTc5ouVd8gFt6pZgMZxtf"}');
                    res.setBody('<XML><Test> test failure</Test></XML>');
           }
        if(req.getEndpoint().contains('Request=getUserToken')){
                //res.setBody('{"Meta": {"Status": "Success","Debug": ""},"Result": "mjiHDKkXSslRPLUhXQjyTc5ouVd8gFt6pZgMZxtf"}');
                    //res.setBody('<XML><Test> test failure</Test></XML>');
                res.setBody('{"Meta": {"Status": "Error","Debug": ""},"ErrorMessage": "You do not have the required permissions."}');
        }
        if(req.getEndpoint().contains('Request=getUserInfo')) {
            res.setBody('<XML><Test> test failure</Test></XML>');   
        }
        if(req.getBody().contains('Request=getLibraryMessages')){
           //res.setBody('{"Meta":{"Status":"Success","Debug":""},"Result":{"INVITE":[],"REMINDER":[],"THANKYOU":[],"ENDOFSURVEY":[],"INACTIVESURVEY":[],"GENERAL":{"MS_e8sZCdjyCsiqRG5":"Jason Test Message","MS_5ckH2UkAFq1I6PP":"LibraryMessageStringForTest","MS_cVnpYmrU7P8ke7H":"LibraryMessageStringForTest","MS_3EsDS6ErkYSo86x":"message name 10","MS_efgPg3jdAqXwo4d":"message name 11","MS_0MuFO8gWuJsvQR7":"message name 14","MS_0UEXtUdDZdUAVgh":"message name demo","MS_e5tzkPjDLu0bIDb":"messageName","MS_1Y8dogaTCopt7HD":"name of message","MS_6fC4WaGfdxjwBc9":"name of my message","MS_24T27h6PiIdGLeR":"new test message name 12","MS_eUQEa7h02xCqGYR":"new test message name 12","MS_0IcerpHcqO4LOXX":"new test message name 9","MS_6DuZQqf2XQEbaUR":"new1","MS_1YBwM3XT4GMmtKJ":"Test Message ","MS_1RmwzfLkHMn0wYt":"test message name","MS_3Q8Pet9Gh2qnghf":"test message name","MS_9nO4wVdE0dPp8CV":"TestMessagefrom API tester","MS_e5M6hBktIrSISTb":"yo"},"LOOKANDFEEL":[]}}');
           res.setBody('{"Meta":{"Status":"Error","RequestType":"createPanel","ErrorCode":500,"QualtricsErrorCode":"ESEC17","ErrorMessage":"No Library Messages were found.","Debug":""},"Result":null}');
        }
        if(req.getEndpoint().contains('/v3/users/')) {
            res.setBody('{"result": {"userId": "UR_1234567890AbCdE","username": "example@qualtrics.com","firstName": "Qualtrics","lastName": "Support","userType": "UT_1234567890AbCdE","product": "ControlPanel","brandId": "yourbrandid","divisionId": null,"accountExpirationDate": null,"accountCreationDate": "2015-12-18 00:00:00","email": "support@qualtrics.com","language": "EN","passwordLastChanged": null,"status": "Active","lastLogin": "2016-01-21 23:20:25","unsubscribed": false,"users": {"controlPanel": {"yourBrandId": {"yourBrandId": null}}},"userDeletedDate": null,"loginHistory": [1437666912, 1437666818],"permissions": {"controlPanel": {"accountPermissions": {"useVocalize":  {"calculatedState": "off","state": "type"}}}}},"meta": {"status": "Success","internalErrorCode": null,"errorMessage": null}}');
        }
        return res;

	}
}