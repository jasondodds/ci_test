trigger LicenseTriggerHandler on sfLma__License__c(before insert,after insert,before update,after update,before delete,after delete,after undelete){
	
	if(trigger.isbefore && trigger.isinsert){
        system.debug('BEFORE INSERT'+trigger.new);
	}
	if(trigger.isafter && trigger.isinsert){
		LicenseManagement licenseMgmt = new LicenseManagement();
		licenseMgmt.PopulateLeadLicense(Trigger.New);
		//system.debug('AFTER INSERT'+trigger.new);
		//system.debug('AFTER INSERT MAP'+trigger.newmap);
	}
	if(trigger.isafter && trigger.isupdate){
		system.debug('AFTER UPDATE NEW'+trigger.new);
		system.debug('AFTER UPDATE OLD'+trigger.old);
		system.debug('AFTER UPDATE OLD MAP'+trigger.oldmap);
		system.debug('AFTER UPDATE NEW MAP'+trigger.newmap);
	}
	if(trigger.isbefore && trigger.isupdate){
		LicenseManagement licenseMgmt = new LicenseManagement();
		licenseMgmt.PopulateLeadLicense(Trigger.New);		//trigger.old as well?		
		//system.debug('BEFORE UPDATE NEW'+trigger.new);
		//system.debug('BEFORE UPDATE OLD'+trigger.old);
		//system.debug('BEFORE UPDATE OLD MAP'+trigger.oldmap);
		//system.debug('BEFORE UPDATE NEW MAP'+trigger.newmap);
	}
	if(trigger.isbefore && trigger.isdelete){
		LicenseManagement licenseMgmt = new LicenseManagement();
		licenseMgmt.LicenseProtection(Trigger.Old);
	}
	if(trigger.isafter && trigger.isundelete){
		system.debug('AFTER UNDELETE NEW'+trigger.new);
	}
}