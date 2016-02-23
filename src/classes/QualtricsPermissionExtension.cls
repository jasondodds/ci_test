public with sharing class QualtricsPermissionExtension {
	public Boolean hasQualtricsAdminPermission {get;set;}
	public QualtricsPermissionExtension() {
		hasQualtricsAdminPermission = Utils.userHasQualtricsAdminPermission();
	}
	public QualtricsPermissionExtension(ApexPages.StandardController sc) {
		hasQualtricsAdminPermission = Utils.userHasQualtricsAdminPermission();
	}
	public QualtricsPermissionExtension(ApexPages.StandardSetController ssc) {
		hasQualtricsAdminPermission = Utils.userHasQualtricsAdminPermission();
	}

}