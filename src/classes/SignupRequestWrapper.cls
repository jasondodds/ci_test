public with sharing class SignupRequestWrapper {

	public SignupRequest srObj { get; set; }

	public Id Id { get { return (Id) getField('Id', Id); } set { Id = value; setField('Id', value); }}
	public String FirstName { get { return (String) getField('FirstName', FirstName); } set { FirstName = value; setField('FirstName', value); }}
	public String LastName { get { return (String) getField('LastName', LastName); } set { LastName = value; setField('LastName', value); }}
	public String SignupEmail { get { return (String) getField('SignupEmail', SignupEmail); } set { SignupEmail = value; setField('SignupEmail', value); }}
	public String Username { get { return (String) getField('Username', Username); } set { Username = value; setField('Username', value); }}
	public String Subdomain { get { return (String) getField('Subdomain', Subdomain); } set { Subdomain = value; setField('Subdomain', value); }}
	public String Company { get { return (String) getField('Company', Company); } set { Company = value; setField('Company', value); }}
	public String Status { get { return (String) getField('Status', Status); } set { Status = value; setField('Status', value); }}
	public Id Environment { get { return (Id) getField('Environment', Environment); } set { Environment = value; setField('Environment', value); }}
	public Boolean Create_Users { get { return (Boolean) getField('Create_Users', Create_Users); } set { Create_Users = value; setField('Create_Users', value); }}
	public String CreatedOrgId { get { return (String) getField('CreatedOrgId', CreatedOrgId); } set { CreatedOrgId = value; setField('CreatedOrgId', value); }}
	public String AuthCode { get { return (String) getField('AuthCode', AuthCode); } set { AuthCode = value; setField('AuthCode', value); }}
	public String Edition { get { return (String) getField('Edition', Edition); } set { Edition = value; setField('Edition', value); }}

	public SignupRequestWrapper(Id srId, Boolean useMock) {

		if (!useMock) {
			List<SignupRequest> srObjList = [SELECT Company, Status, Edition, CreatedOrgId, AuthCode, Environment__c, Create_Users__c, Username FROM SignupRequest WHERE Id = :srId];
			if (!srObjList.isEmpty()) srObj = srObjList[0];
		} else {
			setMockValues();
		}
	}

	public SignupRequestWrapper(SignupRequest srObj) {
		this.srObj = srObj;
		setMockValues();
	}

	private void setMockValues() {

		if (SignupRequestService.bypassSRInsertForTest) {
			FirstName = LastName = Username = Company = AuthCode = CreatedOrgId = 'test';
			SignupEmail = 'test@test.com';
			Subdomain = 'test.com';
			Status = 'Success';
			Edition = 'Partner Developer';
			Environment = [select Id from Environment__c limit 1].Id;
			Create_Users = true;
		}
	}

	public Database.SaveResult insertSignupRequest() {

		if (SignupRequestService.bypassSRInsertForTest) {
			return null;
		} else {
			return Database.insert(srObj);
		}
	}

	public Object getField(String fieldName, Object paramValue) {

		if (SignupRequestService.bypassSRInsertForTest) {

			return paramValue;
		} else {

			if (fieldName == 'Environment') {
				return srObj.Environment__c;
			} else if (fieldName == 'Create_Users') {
				return srObj.Create_Users__c;
			} else {
				return srObj.get(fieldName);
			}
		}
	}

	public void setField(String fieldName, Object value) {

		if (!SignupRequestService.bypassSRInsertForTest && this.srObj != null) {

			Set<String> customSignupRequestFields = new Set<String>{
				'Environment__c', 'Create_Users__c'
			};

			if (customSignupRequestFields.contains(fieldName + '__c')) {
				this.srObj.put(fieldName + '__c', value);
			} else {
				this.srObj.put(fieldName, value);
			}
		}
	}
}