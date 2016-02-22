@isTest
private class DescribeCacheTest {
	@isTest
	static void getRestrictedFields() {
		System.runAs(UserTest.createStandardUser()) {
			DescribeCache dc = DescribeCache.getDescribeCache('Lead');

			dc.getRestrictedFields(DataConstants.SecurityOperation.CREATE);
		}
	}
    
	@isTest
	static void getFieldTokenNamespace() {
		System.runAs(UserTest.createStandardUser()) {
			DescribeCache dc = DescribeCache.getDescribeCache('Lead');

			dc.getFieldToken('NS__AggregateQueries__c');
		}
	}
	
	@isTest
	static void getRecordTypeId() {
		System.runAs(UserTest.createStandardUser()) {
			DescribeCache dc = DescribeCache.getDescribeCache('Lead');

			try {
				dc.getRecordTypeId('Test');
				System.assert(false);
			} catch (DescribeCache.RecordTypeNotFoundException rtnfe) {
				System.assert(true);
			}
		}
	}
	
	@isTest
	static void getPicklistOptions() {
		System.runAs(UserTest.createStandardUser()) {
			DescribeCache dc = DescribeCache.getDescribeCache('Account');

			dc.getPicklistOptions('Type');
		}
	}
}