public with sharing class SignupRequestService {

    public static Boolean bypassSRInsertForTest = Test.isRunningTest();

    public static void createSignupRequest(Environment__c env) {
        Code_Accelerator_Setting__mdt settings = [SELECT SR_Consumer_Key__c, SR_Consumer_Secret__c, SR_Redirect_URL__c, SR_User_Session_Id__c, API_Token__c, API_Stage__c, AWS_Endpoint__c, SR_Org_Template_Id__c FROM Code_Accelerator_Setting__mdt WHERE MasterLabel = 'Integration Setting' LIMIT 1];
        ProjectDefinition__c pd = [SELECT Name FROM ProjectDefinition__c WHERE Id = :env.CI_Project_Definition__c];
        List<Environment_User__c> users = [SELECT Team_Member__r.First_Name__c, Team_Member__r.Last_Name__c, Team_Member__r.Email__c FROM Environment_User__c WHERE Environment__c = :env.Id Order By CreatedDate];
        SignupRequestWrapper srWrapper = new SignupRequestWrapper(new SignupRequest(
            Subdomain=pd.Name + '-' + env.Branch_Name__c, 
            Environment__c=env.Id, 
            Company=env.Name, 
            Country='US', 
            ConnectedAppCallbackUrl=settings.SR_Redirect_Url__c, 
            ConnectedAppConsumerKey=settings.SR_Consumer_Key__c, 
            ShouldConnectToEnvHub=true, 
            Create_Users__c=env.Create_Users__c,
            Edition='Partner Developer'
            //0TTA00000000yTd
            /*TemplateId=settings.SR_Org_Template_Id__c*/
        ));
        if(users.size() > 0) {
            srWrapper.FirstName = users[0].Team_Member__r.First_Name__c;
            srWrapper.LastName = users[0].Team_Member__r.Last_Name__c;
            srWrapper.SignupEmail = users[0].Team_Member__r.Email__c;
            users[0].Created__c = true;
        }
        else {
            User u = [SELECT FirstName, LastName, Email FROM User WHERE Id = :UserInfo.getUserId()];
            srWrapper.FirstName = u.FirstName;
            srWrapper.LastName = u.LastName;
            srWrapper.SignupEmail = u.Email;
        }
        srWrapper.Username = srWrapper.FirstName + '.' + srWrapper.LastName + '@' + pd.Name + '.' + env.Branch_Name__c;
        srWrapper.Username = srWrapper.Username.replace(' ','_');
        srWrapper.Subdomain = srWrapper.Subdomain.replace(' ','_').replace('_','');
        System.debug('Email Address being used for srWrapper: ' + srWrapper.Username);
        if(!String.isBlank(srWrapper.SignupEmail)) {

            // Create the remote site in current org
            String baseUrl = 'https://'+srWrapper.Subdomain+'-dev-ed.my.salesforce.com';
            String remoteSiteName = pd.Name+'_'+env.Name;
            system.debug('CREATING REMOTE SITE FOR ' + baseUrl);
            createRemoteSiteSetting(UserInfo.getSessionId(),remoteSiteName.replace(' ','_'), baseUrl);
            // Insert the signup request
            Database.SaveResult res = srWrapper.insertSignupRequest();
            system.debug('RES IS ' + res);
            if(res != null && res.isSuccess()) {
                if(users.size() > 0) {
                    update users[0];
                }
                scheduleJob(res.getId(), srWrapper.Company);
            }
        }
    }

    @future(callout=true)
    public static void storeRefreshToken(Id srId) {
        SignupRequestWrapper srWrapper = new SignupRequestWrapper(srId, bypassSRInsertForTest);
        Environment__c env = [SELECT Id, Signup_Request_Status__c, Branch_Name__c, CI_Project_Definition__r.Owner.Email, CI_Project_Definition__r.Name, CI_Project_Definition__r.Id, Instance_Url__c, Session_Id__c, Name, CreatedBy.Name FROM Environment__c WHERE Id = :srWrapper.Environment];

        //if we have an auth code attempt to exchange it
        if(srWrapper.Status == 'Success' && srWrapper.authCode != null) {

            Map<String,Object> resp = getAccessToken(srWrapper.authCode, srId);
            system.debug('ACCESS RESPONSE ' + resp);
            if(resp != null && resp.containsKey('refresh_token') && resp.get('refresh_token') != null) {
                if(srWrapper.Create_Users) {
                    try {
                        createEnvironmentUsers((String)resp.get('access_token'), (String)resp.get('instance_url'), env.CI_Project_Definition__r.Name, env);
                    } 
                    catch(CalloutException e) {
                        System.debug(e.getMessage());
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        String[] toAddresses = new String[] {env.CI_Project_Definition__r.Owner.Email};
                        mail.setToAddresses(toAddresses);
                        mail.setSubject('ERROR during Signup Request - '+env.CI_Project_Definition__r.Name);
                        mail.setPlainTextBody('There was an error while creating the '+env.Name+' environment.  Please check the debug logs for more detail.  ERROR: '+e.getMessage());
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                        scheduleJob(srId, srWrapper.Company);
                    }
                }
                String ertName = srWrapper.CreatedOrgId;
                Environment_Refresh_Token__c ert = new Environment_Refresh_Token__c(Name=ertName, Refresh_Token__c=(String)resp.get('refresh_token'));
                insert ert;
                env.Signup_Request_Status__c = 'Success';

                // Send an email to the Apex job's submitter
                if(!Test.isRunningTest()){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] toAddresses = new String[] {env.CI_Project_Definition__r.Owner.Email};
                    mail.setToAddresses(toAddresses);
                    mail.setSubject('Signup Request Successful - '+env.CI_Project_Definition__r.Name);
                    mail.setPlainTextBody('The Signup Request polling batch Apex job has completed successfully.  A username of '+srWrapper.Username+' has been created in a new org with id of '+srWrapper.CreatedOrgId+' for the '+env.Name+' environment.  Please use this username to setup SSO in the Environment Hub for this org.  The default password for all users in the org is the branchName+\'1234\'.');
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            }
            else {
                env.Signup_Request_Status__c = 'Failure';
                scheduleJob(srId, srWrapper.Company);
            }
            update env;
        }
        //if status is in progress reschedule the job
        else if(srWrapper.Status == 'In Progress') { 
            scheduleJob(srId, srWrapper.Company);
        } 
    }

    public static Map<String,Object> getAccessToken(String ac, Id srId) {
        system.debug('GET ACCESS TOKEN');
        UserDefinition__c ud = UserDefinition__c.getInstance(UserInfo.getUserId());

        String url = 'https://login.salesforce.com/services/oauth2/token?';
        Code_Accelerator_Setting__mdt oauth = [SELECT SR_Consumer_Key__c, SR_Consumer_Secret__c, SR_Redirect_URL__c, SR_User_Session_Id__c, API_Token__c, API_Stage__c, AWS_Endpoint__c FROM Code_Accelerator_Setting__mdt WHERE MasterLabel = 'Integration Setting' LIMIT 1];
        String parameters = 'grant_type=authorization_code&code=' + ac + '&client_id=' + oauth.SR_Consumer_Key__c + '&client_secret=' + oauth.SR_Consumer_Secret__c + '&redirect_uri=https%3A%2F%2Flogin.salesforce.com';
        system.debug('URL IS ' + url + parameters);
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url + parameters);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        Http http = new Http();
        HttpResponse resp = http.send(req);
        system.debug('RESP + ' + resp.getBody());
        Map<String,String> accessTokenResp = (Map<String,String>)JSON.deserialize(resp.getBody(),  Map<String,String>.class);
        system.debug('TOKEN RESPONSE ' + accessTokenResp);
        if(accessTokenResp.containsKey('error_description')){
            if(accessTokenResp.get('error_description') == 'expired authorization code'){
                throw new CustomException(accessTokenResp.get('error_description'));
            }
            return null;
        }
        //store the refresh token in custom setting and in circleci env vars
        SignupRequest sr;
        if (srId != null) {
            sr = [SELECT Environment__c, Environment__r.Branch_Name__c,Environment__r.CI_Project_Definition__r.Repo_Name__c FROM SignupRequest WHERE Id = :srId];
        }
        system.debug('SIGNUP REQUEST ' + sr);
        if(sr == null || sr.Environment__c == null) {
            //throw new CustomException('Signup Request is not attached to an environment.');
        }
        //get the org/username and repo name
        List<String> repoSplit = (bypassSRInsertForTest ? new List<String>{ 'orgName', 'repoName' } : sr.Environment__r.CI_Project_Definition__r.Repo_Name__c.split('/'));
        String branchName = (bypassSRInsertForTest ? 'testbranch' : sr.Environment__r.Branch_Name__c);
        String orgName = repoSplit[0];
        String repoName = repoSplit[1];
        String keyRoot = branchName.toUpperCase();
        String key = keyRoot + '_TOKEN';
        system.debug('ASSIGNED REPO NAMES');
        system.debug('ACCESS TOKEN RESP ' + accessTokenResp);
        if(accessTokenResp.containsKey('refresh_token')) {
            Map<String,Object> ccResp = CircleCIService.addEnvironmentVariable(ud.CI_Token__c, orgName, repoName, key, accessTokenResp.get('refresh_token'));
            system.debug('CC RESP ' + ccResp);
            ccResp = CircleCIService.addEnvironmentVariable(ud.CI_Token__c, orgName, repoName, keyRoot + '_CLIENTID', oauth.SR_Consumer_Key__c);
            system.debug('CLEINT ID RESP ' + ccResp);
            ccResp = CircleCIService.addEnvironmentVariable(ud.CI_Token__c, orgName, repoName, keyRoot + '_CLIENTSECRET', oauth.SR_Consumer_Secret__c);
            system.debug('CLIENT SECRET RESP ' + ccResp);
            ccResp = CircleCIService.triggerBuild(ud.CI_Token__c, orgName, repoName, branchName);
            return accessTokenResp;
        }

        return null;
    }

    public static void createEnvironmentUsers(String at, String baseUrl, String pdName, Environment__c env) {
        system.debug('CREATE ENV USERS');
        Code_Accelerator_Setting__mdt oauth = [SELECT SR_Consumer_Key__c, SR_Consumer_Secret__c, SR_Redirect_URL__c, SR_User_Session_Id__c, API_Token__c, API_Stage__c, AWS_Endpoint__c FROM Code_Accelerator_Setting__mdt WHERE MasterLabel = 'Integration Setting' LIMIT 1];
        List<Environment_User__c> envUsers = new List<Environment_User__c>();
        system.debug('** Finding Team Members for Project: '+env.CI_Project_Definition__r.Name+' - '+env.CI_Project_Definition__r.Id);
        Map<Id,Team_Member__c> projectTeamMembers = new Map<Id,Team_Member__c>([SELECT Id, Name, First_Name__c, Last_Name__c, Email__c FROM Team_Member__c WHERE Project_Definition__c =: env.CI_Project_Definition__r.Id]);
        for(Team_Member__c teamMember : projectTeamMembers.values()){
            Environment_User__c envUser = new Environment_User__c();
            envUser.Environment__c = env.Id;
            envUser.Team_Member__c = teamMember.Id;
            envUser.Created__c = false;
            envUsers.add(envUser);
        }
        system.debug('** envUsers: '+envUsers);
        QueryResponse qr = query(at, baseUrl, 'select id from profile where name = \'System Administrator\'');
        Id profileId;
        if(qr.records.size() == 1) {
            profileId = qr.records[0].Id;
        }
        System.debug('** Target org System Administrator Profile Id: '+profileId);
        List<SignupRequest> srList = [SELECT Username from SignupRequest WHERE Environment__c = :env.Id];
        String parentUsername = '';
        if(srList.size() >= 1){
            parentUsername = srList.get(0).Username;
        }
        for(Environment_User__c eu : envUsers) {
            System.debug('** Creating new User for: '+eu);
            Team_Member__c teamMember = projectTeamMembers.get(eu.Team_Member__c);
            String username = teamMember.First_Name__c + '.' + teamMember.Last_Name__c + '@' + env.CI_Project_Definition__r.Name + '.' + env.Branch_Name__c;
            username = username.replace(' ','_');
            if(parentUsername != username){
                String alias = (teamMember.First_Name__c.left(1) + teamMember.Last_Name__c.left(4)).toLowerCase();
                User u = new User(FirstName=teamMember.First_Name__c, LastName=teamMember.Last_Name__c, Email=teamMember.Email__c, Username=username, Alias=alias, TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', ProfileId=profileId, LanguageLocaleKey='en_US', ReceivesInfoEmails=true, UserPermissionsSFContentUser=false, UserPermissionsMarketingUser=false, UserPermissionsMobileUser=false, UserPermissionsOfflineUser=false);
                eu.Created__c = true;
                System.debug('** Creating target org user for: '+u);
                String response = create(at, baseUrl, 'User', u);
                CreateResponse createUserResponse = (CreateResponse)JSON.deserialize(response,  CreateResponse.class);
                if(createUserResponse.id != null){
                    // Set the password on the account
                    System.debug('SETTING PASSWORD: '+env.Branch_Name__c);
                    response = setPassword(at, baseUrl, createUserResponse.id, env.Branch_Name__c+'1234');
                }
            }
        }
        system.debug('** Creating Environment Users');
        insert envUsers;
    }
    public static Map<String,String> login(String un, String pw, String ck, String cs) {
        System.debug('Username: '+un);
        System.debug('Password:  '+pw);
        System.debug('Consumer Key:  '+ck);
        System.debug('Consumer Secret:  '+cs);
        HttpRequest req = new HttpRequest();
        un = EncodingUtil.urlEncode(un, 'UTF-8');
        req.setEndpoint(String.format('https://login.salesforce.com/services/oauth2/token?grant_type=password&client_id={0}&client_secret={1}&username={2}&password={3}', new String[]{ck,cs,un,pw}));
        req.setMethod('POST');
        Http http = new Http();
        HttpResponse resp = http.send(req);

        system.debug('RESP ' + resp.getBody());

        return (Map<String,String>)JSON.deserialize(resp.getBody(), Map<String,String>.class);

    }

    public static Map<String,String> exchangeRefreshToken(String rt) {
        Code_Accelerator_Setting__mdt oauth = [SELECT SR_Consumer_Key__c, SR_Consumer_Secret__c, SR_Redirect_URL__c, SR_User_Session_Id__c, API_Token__c, API_Stage__c, AWS_Endpoint__c FROM Code_Accelerator_Setting__mdt WHERE MasterLabel = 'Integration Setting' LIMIT 1];
        HttpRequest req = new HttpRequest();
        String url = 'https://login.salesforce.com/services/oauth2/token?grant_type=refresh_token&client_id=' + oauth.SR_Consumer_Key__c + '&client_secret=' + oauth.SR_Consumer_Secret__c + '&refresh_token=' + rt;
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');

        Http http = new Http();
        HttpResponse resp;
        if(!test.isRunningTest()) {
            resp = http.send(req);
        }
        else {
            return new Map<String,String>{'id'=>'https://login.salesforce.com/id/00Dx0000000BV7z/005x00000012Q9P','issued_at'=>'1278448832702','instance_url'=>'https://na1.salesforce.com','signature'=>'0CmxinZir53Yex7nE0TD+zMpvIWYGb/bdJh6XfOH6EQ=','access_token'=>'00Dx0000000BV7z!AR8AQAxo9UfVkh8AlV0Gomt9Czx9LjHnSSpwBMmbRcgKFmxOtvxjTrKW19ye6PE3Ds1eQz3z8jr3W7_VbWmEu4Q8TVGSTHxs','refresh_token'=>'12345'};
        }

        return (Map<String,String>)JSON.deserialize(resp.getBody(), Map<String,String>.class);
    }

    public static String create(String at, String baseUrl, String sobjType, SObject so) {
        system.debug('CREATE CALLED');
        String target = baseUrl + '/services/data/v35.0/sobjects/' + sobjType;
        String body = JSON.serialize(so);
        HttpResponse resp = callSalesforceOrg('POST',at,target,'application/json',body);
        return resp.getBody();
    }

    public static String setPassword(String at, String baseUrl, String userId, String password) {
        system.debug('SET PASSWORD');
        String target = baseUrl + '/services/data/v35.0/sobjects/User/' + userId+'/password';
        String body = '{"NewPassword":"'+password+'"}';
        HttpResponse resp = callSalesforceOrg('POST',at,target,'application/json',body);
        return resp.getBody();
    }

    public static QueryResponse query(String at, String endpoint, String query) {
        String target = endpoint + '/services/data/v35.0/query?q=' + EncodingUtil.urlEncode(query, 'UTF-8');
        HttpResponse resp = callSalesforceOrg('GET',at,target,'application-x-www-form-urlencoded',null);
        return (QueryResponse)JSON.deserialize(resp.getBody(), QueryResponse.class);
    }

    public static HttpResponse callSalesforceOrg(String verb, String at, String endpoint, String contentType, String body){
        system.debug('ACCESS TOKEN ' + at);
        HttpRequest req = new HttpRequest();
        req.setMethod(verb.toUpperCase());
        req.setHeader('Authorization', 'Bearer ' + at);
        req.setHeader('Content-Type', contentType);
        req.setHeader('Accept', 'application/json');
        req.setEndpoint(endpoint);
        system.debug('ENDPOINT ' + req.getendpoint());
        if(body != null){
            req.setBody(body);
        }
        Http http = new Http();
        HttpResponse resp = http.send(req);
        system.debug('STATUS CODE ' + resp.getStatusCode());
        system.debug('STATUS ' + resp.getStatus());
        system.debug('RESPONSE ' + resp.getBody());
        return resp;
    }

    public static void scheduleJob(Id srId, String name) {
        system.debug('SCHEDULING JOB');
        Datetime now = Datetime.now();
        now = now.addMinutes(1);
        String nft = String.valueOf(now.second()) + ' ' + String.valueOf(now.minute()) + ' ' + String.valueOf(now.hour()) + ' ' + String.valueOf(Date.today().day()) + ' ' + String.valueOf(Date.today().month()) + ' ? ' + String.valueOf(Date.today().year());
        system.debug('NFT ' + nft);
        ScheduleStoreRefreshToken srt = new ScheduleStoreRefreshToken(srId);
        System.schedule(name + ' Store Refresh Token started at ' + String.valueOf(Datetime.now()), nft, srt);
    }

    @future(callout=true)
    public static void createRemoteSiteSetting(String at, String name, String url) {
        system.debug('CREATE REMOTE SITE SETTING');
        url = url.toLowerCase();
        name = name.toLowerCase();
        String body = '<?xml version="1.0" encoding="utf-8"?><env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><env:Header><urn:SessionHeader xmlns:urn="http://soap.sforce.com/2006/04/metadata"><urn:sessionId>' + at + '</urn:sessionId></urn:SessionHeader></env:Header><env:Body> <createMetadata xmlns="http://soap.sforce.com/2006/04/metadata"> <metadata xsi:type="RemoteSiteSetting"><fullName>'+ name + '</fullName><description>' + name + '</description><disableProtocolSecurity>false</disableProtocolSecurity><isActive>true</isActive><url>' + url + '</url></metadata></createMetadata></env:Body></env:Envelope>';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(System.Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/m/35.0');
        req.setMethod('POST');
        req.setHeader('SOAPAction', '""');
        req.setHeader('Content-Type', 'text/xml');
        req.setBody(body);

        HttpResponse resp = new Http().send(req);
        system.debug('RESPONSE ' + resp.getBody());
    }

    public class QueryResponse {
        public List<SObject> records;
        public String totalSize;

        public QueryResponse() {}
    }

    public class CreateResponse {
        public String id;
        public List<String> errors;
        public Boolean success;

        public CreateResponse() {}
    }

    public class CustomException extends Exception {}
}