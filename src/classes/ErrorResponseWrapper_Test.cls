@isTest
private class ErrorResponseWrapper_Test {
	
	@isTest static void testParse() {
		String json = '{\"Meta\":{\"Status\":\"Error\",\"RequestType\":\"createPanel\",\"ErrorCode\":500,\"QualtricsErrorCode\":\"ESEC49\",\"ErrorMessage\":\"You have exceeded your maximum number of panels for this library.\",\"Debug\":\"\"},\"Result\":null}';
		ErrorResponseWrapper obj = ErrorResponseWrapper.parse(json);
		System.assert(obj != null);
	}
	
}