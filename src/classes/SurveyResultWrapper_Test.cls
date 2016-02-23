@isTest
private class SurveyResultWrapper_Test {
	
	@isTest static void testParse() {
		String json = '{\"Meta\":{\"Status\":\"Success\",\"Debug\":\"\"},\"Result\":{\"Surveys\":[{\"SurveyType\":\"SV\",\"SurveyID\":\"SV_9pjIVAqm230gGRD\",\"SurveyName\":\"New survey1\",\"SurveyOwnerID\":\"UR_88uCZoW8wlvqdPT\",\"SurveyStatus\":\"Active\",\"SurveyStartDate\":\"0000-00-00 00:00:00\",\"SurveyExpirationDate\":\"0000-00-00 00:00:00\",\"SurveyCreationDate\":\"2015-01-06 11:35:22\",\"CreatorID\":\"UR_88uCZoW8wlvqdPT\",\"LastModified\":\"2015-02-23 15:44:00\",\"LastActivated\":\"2015-02-23 15:44:00\",\"UserFirstName\":\"Jon\",\"UserLastName\":\"Tresko\"}]}}';
		SurveyResultWrapper obj = SurveyResultWrapper.parse(json);
		System.assert(obj != null);
		System.assertEquals('SV', obj.Result.Surveys[0].SurveyType);
		System.assertEquals('SV_9pjIVAqm230gGRD', obj.Result.Surveys[0].SurveyID);
		System.assertEquals('New survey1', obj.Result.Surveys[0].SurveyName);
	}
	
}