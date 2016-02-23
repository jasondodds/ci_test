@isTest
public class QualtricsAPIMockTest implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public QualtricsAPIMockTest(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }
    public QualtricsAPIMockTest(){
    }
    public HTTPResponse respond(HTTPRequest req) {
        //System.assertEquals('http://api.salesforce.com/foo/bar', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        System.debug('$$$ req.getBody(); is ' + req.getBody());
        System.debug('request.getEndPoint() is ' + req.getEndPoint());


        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
           
           //tests calls to the older API 
        if (req.getEndpoint().contains('https://survey.qualtrics.com/WRAPI/ControlPanel/api.php')){

            if(req.getBody().contains('Request=createPanel')){
                res.setBody('{"Meta":{"Status":"Success","Debug":""},"Result":{"PanelID":"9"}}');
                res.setStatusCode(200);
            }
            if(req.getBody().contains('Request=getSurveys')){
                res.setBody('{"Meta":{"Status":"Success","Debug":""},"Result":{"Surveys":[{"SurveyType":"SV","SurveyID":"SV_0uZ5fWo83fvZykd","SurveyName":"Bain Certified NPS - Relationship","SurveyOwnerID":"UR_88uCZoW8wlvqdPT","SurveyStatus":"Inactive","SurveyStartDate":"0000-00-00 00:00:00","SurveyExpirationDate":"0000-00-00 00:00:00","SurveyCreationDate":"2015-04-01 19:43:10","CreatorID":"UR_88uCZoW8wlvqdPT","LastModified":"2015-04-02 16:55:09","LastActivated":"2015-02-23 18:47:53","UserFirstName":"Jon","UserLastName":"Tresko"},{"SurveyType":"SV","SurveyID":"SV_25hZYNYY0mR7seF","SurveyName":"test","SurveyOwnerID":"UR_88uCZoW8wlvqdPT","SurveyStatus":"Inactive","SurveyStartDate":"0000-00-00 00:00:00","SurveyExpirationDate":"0000-00-00 00:00:00","SurveyCreationDate":"2015-04-03 14:33:03","CreatorID":"UR_88uCZoW8wlvqdPT","LastModified":"2015-04-03 14:33:03","LastActivated":"0000-00-00 00:00:00","UserFirstName":"Jon","UserLastName":"Tresko"},{"SurveyType":"SV","SurveyID":"SV_2bqjvOI3V5lYKt7","SurveyName":"WinLoss - Loss","SurveyOwnerID":"UR_88uCZoW8wlvqdPT","SurveyStatus":"Inactive","SurveyStartDate":"0000-00-00 00:00:00","SurveyExpirationDate":"0000-00-00 00:00:00","SurveyCreationDate":"2015-04-01 19:44:18","CreatorID":"UR_88uCZoW8wlvqdPT","LastModified":"2015-04-01 19:44:18","LastActivated":"2015-03-19 11:39:26","UserFirstName":"Jon","UserLastName":"Tresko"},{"SurveyType":"SV","SurveyID":"SV_3jxnJFJflggoI6N","SurveyName":"WinLoss - Win","SurveyOwnerID":"UR_88uCZoW8wlvqdPT","SurveyStatus":"Inactive","SurveyStartDate":"0000-00-00 00:00:00","SurveyExpirationDate":"0000-00-00 00:00:00","SurveyCreationDate":"2015-04-01 19:44:31","CreatorID":"UR_88uCZoW8wlvqdPT","LastModified":"2015-04-01 19:44:31","LastActivated":"2015-03-19 11:39:29","UserFirstName":"Jon","UserLastName":"Tresko"},{"SurveyType":"SV","SurveyID":"SV_3JZfgSouF3zI0vj","SurveyName":"Customer Product Purchase - Pricing Survey - Copy","SurveyDescription":"Customer Product Purchase - Pricing Survey - Copy","SurveyOwnerID":"UR_88uCZoW8wlvqdPT","SurveyStatus":"Inactive","SurveyStartDate":"0000-00-00 00:00:00","SurveyExpirationDate":"0000-00-00 00:00:00","SurveyCreationDate":"2015-03-10 15:01:46","CreatorID":"UR_88uCZoW8wlvqdPT","LastModified":"2015-04-01 19:46:40","LastActivated":"2015-03-10 15:02:20","UserFirstName":"Jon","UserLastName":"Tresko"},{"SurveyType":"SV","SurveyID":"SV_5BatET28CxiPa5f","SurveyName":"Bain Certified NPS - Touchpoint","SurveyOwnerID":"UR_88uCZoW8wlvqdPT","SurveyStatus":"Inactive","SurveyStartDate":"0000-00-00 00:00:00","SurveyExpirationDate":"0000-00-00 00:00:00","SurveyCreationDate":"2015-04-01 19:43:31","CreatorID":"UR_88uCZoW8wlvqdPT","LastModified":"2015-04-01 19:43:31","LastActivated":"2015-02-23 18:48:29","UserFirstName":"Jon","UserLastName":"Tresko"},{"SurveyType":"SV","SurveyID":"SV_6QE29M2dlggWRmZ","SurveyName":"Pre-meeting Survey","SurveyOwnerID":"UR_88uCZoW8wlvqdPT","SurveyStatus":"Inactive","SurveyStartDate":"0000-00-00 00:00:00","SurveyExpirationDate":"0000-00-00 00:00:00","SurveyCreationDate":"2015-04-01 19:43:46","CreatorID":"UR_88uCZoW8wlvqdPT","LastModified":"2015-04-01 19:43:46","LastActivated":"2015-03-18 16:23:16","UserFirstName":"Jon","UserLastName":"Tresko"},{"SurveyType":"SV","SurveyID":"SV_88hZOFOCRTxBgvX","SurveyName":"Informed Consent Survey","SurveyDescription":"Informed Consent Survey","SurveyOwnerID":"UR_88uCZoW8wlvqdPT","SurveyStatus":"Inactive","SurveyStartDate":"0000-00-00 00:00:00","SurveyExpirationDate":"0000-00-00 00:00:00","SurveyCreationDate":"2015-03-10 16:03:04","CreatorID":"UR_88uCZoW8wlvqdPT","LastModified":"2015-04-02 16:43:35","LastActivated":"0000-00-00 00:00:00","UserFirstName":"Jon","UserLastName":"Tresko"},{"SurveyType":"SV","SurveyID":"SV_8IaB1QU5GHMCYVD","SurveyName":"Post implementation survey","SurveyOwnerID":"UR_88uCZoW8wlvqdPT","SurveyStatus":"Inactive","SurveyStartDate":"0000-00-00 00:00:00","SurveyExpirationDate":"0000-00-00 00:00:00","SurveyCreationDate":"2015-04-01 19:44:47","CreatorID":"UR_88uCZoW8wlvqdPT","LastModified":"2015-04-01 19:44:47","LastActivated":"2015-03-19 13:10:27","UserFirstName":"Jon","UserLastName":"Tresko"},{"SurveyType":"SV","SurveyID":"SV_9oAsjuznAPgpjff","SurveyName":"Dodds Test Survey","SurveyOwnerID":"UR_88uCZoW8wlvqdPT","SurveyStatus":"Inactive","SurveyStartDate":"0000-00-00 00:00:00","SurveyExpirationDate":"0000-00-00 00:00:00","SurveyCreationDate":"2015-04-06 07:51:34","CreatorID":"UR_88uCZoW8wlvqdPT","LastModified":"2015-04-06 07:51:34","LastActivated":"0000-00-00 00:00:00","UserFirstName":"Jon","UserLastName":"Tresko"},{"SurveyType":"SV","SurveyID":"SV_9pjIVAqm230gGRD","SurveyName":"New survey1","SurveyOwnerID":"UR_88uCZoW8wlvqdPT","SurveyStatus":"Active","SurveyStartDate":"0000-00-00 00:00:00","SurveyExpirationDate":"0000-00-00 00:00:00","SurveyCreationDate":"2015-01-06 11:35:22","CreatorID":"UR_88uCZoW8wlvqdPT","LastModified":"2015-02-23 15:44:00","LastActivated":"2015-02-23 15:44:00","UserFirstName":"Jon","UserLastName":"Tresko"},{"SurveyType":"SV","SurveyID":"SV_bkfaTqIz4mYh6y9","SurveyName":"Support call report card","SurveyOwnerID":"UR_88uCZoW8wlvqdPT","SurveyStatus":"Inactive","SurveyStartDate":"0000-00-00 00:00:00","SurveyExpirationDate":"0000-00-00 00:00:00","SurveyCreationDate":"2015-04-01 19:44:02","CreatorID":"UR_88uCZoW8wlvqdPT","LastModified":"2015-04-01 19:44:03","LastActivated":"2015-03-19 11:45:13","UserFirstName":"Jon","UserLastName":"Tresko"}]}}');
            }
            if(req.getBody().contains('Request=getLibraryMessages')){
                res.setBody('{"Meta":{"Status":"Success","Debug":""},"Result":{"INVITE":{"MS_0TfB4WFXWdfpCdf":"invitations","MS_3IeseiD26YoYcmN":"Tell Us!"},"REMINDER":[],"THANKYOU":[],"ENDOFSURVEY":[],"INACTIVESURVEY":[],"GENERAL":{"MS_e8sZCdjyCsiqRG5":"Jason Test Message","MS_5ckH2UkAFq1I6PP":"LibraryMessageStringForTest","MS_cVnpYmrU7P8ke7H":"LibraryMessageStringForTest","MS_3EsDS6ErkYSo86x":"message name 10","MS_efgPg3jdAqXwo4d":"message name 11","MS_0MuFO8gWuJsvQR7":"message name 14","MS_0UEXtUdDZdUAVgh":"message name demo","MS_e5tzkPjDLu0bIDb":"messageName","MS_1Y8dogaTCopt7HD":"name of message","MS_6fC4WaGfdxjwBc9":"name of my message","MS_24T27h6PiIdGLeR":"new test message name 12","MS_eUQEa7h02xCqGYR":"new test message name 12","MS_0IcerpHcqO4LOXX":"new test message name 9","MS_6DuZQqf2XQEbaUR":"new1","MS_1YBwM3XT4GMmtKJ":"Test Message ","MS_1RmwzfLkHMn0wYt":"test message name","MS_3Q8Pet9Gh2qnghf":"test message name","MS_9nO4wVdE0dPp8CV":"TestMessagefrom API tester","MS_e5M6hBktIrSISTb":"yo"},"LOOKANDFEEL":[]}}');
            }
            if(req.getBody().contains('Request=getLibraryMessage&MessageID=')){
                res.setBody('{"Meta":{"Status":"Success","Debug":""},"Result":["test message content"]}');
            }
            if(req.getBody().contains('Request=createLibraryMessage')){
                res.setBody('{"Meta":{"Status":"Success","Debug":""},"Result":{"LibraryID":"UR_88uCZoW8wlvqdPT","MessageID":"MS_5ckH2UkAFq1I6PP","Description":"LibraryMessageStringForTest","Category":"GeneralMessages"}}');
            }
            if(req.getBody().contains('Request=sendSurveyToPanel')){
                res.setBody('{"Meta":{"Status":"Success","Debug":""},"Result":{"Success":true,"EmailDistributionID":"EMD_5bEgY6ln4MBhtDD","DistributionQueueID":"EMD_5bEgY6ln4MBhtDD"}}');
            }
            if(req.getEndpoint().contains('Request=getUserInfo')){
                res.setBody('{"Meta":{"Status":"Success","Debug":""},"Result":{"UserData":{"UserID":"UR_88uCZoW8wlvqdPT","UserName":"jon.doe@example.com","UserFirstName":"Jon","UserLastName":"Doe","UserAccountType":"Standard - Qualtrics","UserAccountTypeID":"UT_3dBUKOs5wAT2mLW","UserAccountBrandID":"gobbletygook","UserAccountExpirationDate":"0000-00-00","UserAccountCreationDate":"2015-01-05 17:05:32","DivisionID":null,"UserLanguage":"EN","UserEmail":"jon.doe@example.com","PasswordLastChanged":"2015-04-14 19:33:16","UserAccountStatus":"Active","LoginHistory":[1429736113,1429729712,1429729702,1429659835,1429656943,1429656936,1429651800,1429651674,1429648481,1429641440,1429638435,1429636197,1429634109,1429633010,1429570063,1429563112,1429558096,1429474325,1429287750,1429287689,1429219078,1429214744,1429213359,1429213185,1429213164,1429213163,1429209875,1429207445,1429204691,1429195009],"UserUnsubscribed":0,"UdsRestricted":false,"AvailableProducts":["ControlPanel"],"Users":{"ControlPanel":{"salesforceappdev":{"AccountStatus":"Active","UserId":"UR_88uCZoW8wlvqdPT"}}},"SFData":{"refreshToken":"5Aep861eWO5D.7wJBvGnbfPvhcIgMIavomlO8Dnw_Rjm7LWMnJ2fzmIFVtMy7YGIFde0JX3P_TVb0LveT1.YT3A","sessionToken":"null","instanceUrl":"https:na3.salesforce.com"}},"Libraries":[{"Name":"Jon Doe","ID":"UR_88uCZoW8wlvqdPT"},{"Name":"Qualtrics Library","ID":"GR_0rJTu2lC3cYWmrO"}]}}');
            }        
            if(req.getEndpoint().contains('Request=getUserToken')){
                res.setBody('{"Meta": {"Status": "Success","Debug": ""},"Result": "mjiHDKkXSslRPLUhXQjyTc5ouVd8gFt6pZgMZxtf"}');
            }
            if(req.getEndpoint().contains('Request=getPanelMemberCount')){
                res.setBody('{"Meta": {"Status": "Success","Debug": ""},"Result":{"Count":"100"}}');
            }
            if(req.getBody().contains('Request=importSurvey')){
                res.setBody('{"Meta":{"Status":"Success","Debug":""},"Result":{"Surveys":[{"SurveyType":"SV","SurveyID":"SV_0uZ5fWo83fvZykd","SurveyName":"Bain Certified NPS - Relationship","SurveyOwnerID":"UR_88uCZoW8wlvqdPT","SurveyStatus":"Inactive","SurveyStartDate":"0000-00-00 00:00:00","SurveyExpirationDate":"0000-00-00 00:00:00","SurveyCreationDate":"2015-04-01 19:43:10","CreatorID":"UR_88uCZoW8wlvqdPT","LastModified":"2015-04-02 16:55:09","LastActivated":"2015-02-23 18:47:53","UserFirstName":"Jon","UserLastName":"Tresko"}]}}');
            }

        }
        //tests calls to the newer api 
        if (req.getEndpoint().contains('https://s.qualtrics.com/API/v1/panels/')){
            //tests the addPanelMembers call 
            res.setBody('{"result":{"importStatus":"http://s.qualtrics.com/API/v1/panels/ML_5v9oEGd0IjKTpxH/members/panelImports/PGRS_6nyPUpEpoL1lnox"},"meta":{"status":"Success","qualtricsErrorCode":null,"errorMessage":null}}');
        }
        else if(req.getEndpoint().contains('/v3/users/')) {
            res.setBody('{"result": {"userId": "UR_1234567890AbCdE","username": "example@qualtrics.com","firstName": "Qualtrics","lastName": "Support","userType": "UT_1234567890AbCdE","product": "ControlPanel","brandId": "yourbrandid","divisionId": null,"accountExpirationDate": null,"accountCreationDate": "2015-12-18 00:00:00","email": "support@qualtrics.com","language": "EN","passwordLastChanged": null,"status": "Active","lastLogin": "2016-01-21 23:20:25","unsubscribed": false,"users": {"controlPanel": {"yourBrandId": {"yourBrandId": null}}},"userDeletedDate": null,"loginHistory": [1437666912, 1437666818],"permissions": {"controlPanel": {"accountPermissions": {"useVocalize": {"calculatedState": "on","state": "type"}}}}},"meta": {"status": "Success","internalErrorCode": null,"errorMessage": null}}');
        }
        return res;
    }
}