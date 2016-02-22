@isTest
private class LimitsSnapshotTest {
	@isTest
	static void itShould() {
		//
		Test.startTest();
		LimitsSnapshot ls = new LimitsSnapshot('Apex Test');
		ls.toLog();
		ls.toLog(null);
		ls.toDatabase();
		Test.stopTest();

		System.assertNotEquals(null, ls.getLimitStart(LimitsSnapshot.LimitEnum.CpuTime));
		System.assertNotEquals(null, ls.getLimitEnd(LimitsSnapshot.LimitEnum.CpuTime));
	}

	static testMethod void remainingCoverage() {
		LimitsSnapshot ls = new LimitsSnapshot();
		ls.toLog();
	}
}