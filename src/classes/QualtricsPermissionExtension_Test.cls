@isTest
private class QualtricsPermissionExtension_Test {
	@isTest static void testConstructorsPositive() {
		User user = TestingUtils.createAdminUserWithAdminPermSet();
		System.runAs(user) {
			QualtricsPermissionExtension qpe = new QualtricsPermissionExtension();
			system.assert(qpe.hasQualtricsAdminPermission);

			Lead testLead = new Lead(LastName = 'Test', Company = 'TestCo');
			ApexPages.StandardController standardController = new ApexPages.StandardController(testLead);
			QualtricsPermissionExtension qpesc = new QualtricsPermissionExtension(standardController);
			system.assert(qpesc.hasQualtricsAdminPermission);

			List<Lead> testLeads = new List<Lead>();
			for(integer i = 1;i<5;i++) {
				testLeads.add(new Lead(LastName = 'Test' + string.valueOf(i), Company = 'TestCo'));
			}
			ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(testLeads);
			QualtricsPermissionExtension qpessc = new QualtricsPermissionExtension(ssc);
			system.assert(qpessc.hasQualtricsAdminPermission);
		}
	}

	@isTest static void testConstructorsNegative() {
		User user = TestingUtils.createTestUser();
		System.runAs(user) {
			QualtricsPermissionExtension qpe = new QualtricsPermissionExtension();
			system.assertEquals(false,qpe.hasQualtricsAdminPermission);

			Lead testLead = new Lead(LastName = 'Test', Company = 'TestCo');
			ApexPages.StandardController standardController = new ApexPages.StandardController(testLead);
			QualtricsPermissionExtension qpesc = new QualtricsPermissionExtension(standardController);
			system.assertEquals(false,qpesc.hasQualtricsAdminPermission);

			List<Lead> testLeads = new List<Lead>();
			for(integer i = 1;i<5;i++) {
				testLeads.add(new Lead(LastName = 'Test' + string.valueOf(i), Company = 'TestCo'));
			}
			ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(testLeads);
			QualtricsPermissionExtension qpessc = new QualtricsPermissionExtension(ssc);
			system.assertEquals(false,qpessc.hasQualtricsAdminPermission);
		}
	}

}