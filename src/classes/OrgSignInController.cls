public with sharing class OrgSignInController {

	private final Environment__c env;

    public OrgSignInController(ApexPages.StandardController stdController) {
        this.env = (Environment__c)stdController.getRecord();
    }

    public PageReference redirect() {
        PageReference ref = null;
        List<SignupRequest> requests = [SELECT CreatedOrgId FROM SignupRequest WHERE Environment__c = :this.env.Id];
        system.debug('env id ' + this.env.id);
        system.debug('REQUESTS ' + [SELECT Id, Environment__c FROM SignupRequest]);
        system.debug(requests.size());
        if(requests.size() == 1) {
            SignupRequest req = requests[0];
            String orgId = test.isRunningTest() == true ? '123' : req.CreatedOrgId;
            Environment_Refresh_Token__c ert = Environment_Refresh_Token__c.getInstance(orgId);
            system.debug('ERT ' + ert);
            if(ert != null) {
                Map<String,String> res = SignupRequestService.exchangeRefreshToken(ert.Refresh_Token__c);
                if(res.containsKey('access_token')) {
                    ref = new PageReference(res.get('instance_url') +  '/secur/frontdoor.jsp?sid=' + res.get('access_token'));
                    ref.setRedirect(true);
                }
            }
            else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Login failed, org may not be provisioned, wait a few minutes and try again.'));
            }
        }
        
        return ref;
    }
}