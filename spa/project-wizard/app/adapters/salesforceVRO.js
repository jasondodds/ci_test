import Ember from 'ember';
import DS from 'ember-data';

var services = services || {};
/* PROJECT DEFINITIONS VRO */
services.ProjectDefinitions = {
    retrieve: function(params) {
        params = params ? {} : params;
        var sfdcProjectDefinitions = new RemoteObjectModel.ProjectDefinition();
        sfdcProjectDefinitions.retrieve(
            params, //Return all Team Members = empty filter object
            function(err, records) {
                if (err) {
                    console.log(err);
                } else {
                    var returnArray = [];
                    records.forEach(function(record) {
                        returnArray.push(services.ProjectDefinitions.parse(record));
                    });
                    console.log(returnArray);
                    return returnArray;
                }
            }
        );
    },
    parse: function(record) {
        var teamMember = {
            "id": record.get('Id'),
            "name": record.get('Name'),
            "description": record.get('Description__c'),
            "namespace": record.get('Namespace__c'),
            "packageName": record.get('Package_Name__c'),
            "repoName": record.get('Repo_Name__c'),
            "repoUrl": record.get('Repo_Url__c')
        };
        return teamMember;
    },
    encode: function(projectDefinition) {
        var record = {
            "Id": projectDefinition.id,
            "Name": projectDefinition.name,
            "Description__c": projectDefinition.description,
            "Namespace__c": projectDefinition.namespace,
            "Package_Name__c": projectDefinition.packageName,
            "Repo_Name__c": projectDefinition.repoName,
            "Repo_Url__c": projectDefinition.repoUrl
        };
        return record;
    }
};
/* TEAM MEMBERS VRO */
services.TeamMembers = {
    retrieve: function(params) {
        params = params ? {} : params;
        var sfdcTeamMembers = new RemoteObjectModel.TeamMember();
        sfdcTeamMembers.retrieve(
            params, //Return all Team Members = empty filter object
            function(err, records) {
                if (err) {
                    console.log(err);
                } else {
                    var returnArray = [];
                    records.forEach(function(record) {
                        returnArray.push(services.TeamMembers.parse(record));
                    });
                    console.log(returnArray);
                    return returnArray;
                }
            }
        );
    },
    parse: function(record) {
        var teamMember = {
            "id": record.get('Id'),
            "name": record.get('Name'),
            "email": record.get('Email'),
            "firstName": record.get('First_Name__c'),
            "lastName": record.get('Last_Name__c'),
            "githubHandle": record.get('Github_Handle__c'),
            "isProcessed": record.get('Processed__c'),
            "contact": record.get('Contact__c'),
            "projectDefinition": record.get('Project_Definition__c')
        };
        return teamMember;
    },
    encode: function(teamMember) {
        var record = {
            "Id": teamMember.id,
            "Name": teamMember.name,
            "Email": teamMember.email,
            "First_Name__c": teamMember.firstName,
            "Last_Name__c": teamMember.lastName,
            "Github_Handle__c": teamMember.githubHandle,
            "Processed__c": teamMember.isProcessed,
            "Contact__c": teamMember.contact,
            "Project_Definition__c": teamMember.projectDefinition
        };
        return record;
    }
};
/* ENVIRONMENTS VRO */
services.Environments = {
    retrieve: function(params) {
        params = params ? {} : params;
        var sfdcEnvironments = new RemoteObjectModel.Environment();
        sfdcEnvironments.retrieve(
            params, //Return all Team Members = empty filter object
            function(err, records) {
                if (err) {
                    console.log(err);
                } else {
                    var returnArray = [];
                    records.forEach(function(record) {
                        returnArray.push(services.Environments.parse(record));
                    });
                    console.log(returnArray);
                    return returnArray;
                }
            }
        );
    },
    parse: function(record) {
        var environment = {
            "id": record.get('Id'),
            "name": record.get('Name'),
            "branchName": record.get('Branch_Name__c'),
            "projectDefinition": record.get('CI_Project_Definition__c'),
            "namespace": record.get('Namespace__c'),
            "isPackaging": record.get('Packaging__c'),
            "parentEnvironment": record.get('Parent_Environment__c'),
            "isProduction": record.get('Production__c'),
            "signupRequestStatus": record.get('Signup_Request_Status__c')
        };
        return environment;
    },
    encode: function(environment) {
        var record = {
            "Id": record.get('id'),
            "Name": record.get('name'),
            "Branch_Name__c": environment.branchName,
            "CI_Project_Definition__c": environment.projectDefinition,
            "Namespace__c": environment.namespace,
            "Packaging__c": environment.isPackaging,
            "Parent_Environment__c": environment.paentEnvironment,
            "Production__c": environment.isProduction,
            "Signup_Request_Status__c": environment.signupRequestStatus
        };
        return record;
    }
};
/* CONTACTS VRO */
services.Contacts = {
    update: function(params) {
        params = params ? params : {};
        if (params === {}) {
            throw 'This is not a valid contact';
        }
        var sfdcContacts = new RemoteObjectModel.Contact();
        var updateIt = Ember.RSVP.denodeify(sfdcContacts.update);
        var Id = [params["Id"]];
        return updateIt(Id, params) //Return all Team Members = empty filter object
        	.then(ids => {
                return ids;
	        })
	        .catch(err => {
	        	throw err;
	        });
    },
    retrieve: function(params) {
        params = params ? params : {};
        var sfdcContacts = new RemoteObjectModel.Contact();
        var getIt = Ember.RSVP.denodeify(sfdcContacts.retrieve);
        return getIt(params) //Return all Team Members = empty filter object
            .then(records => {
                var returnArray = [];
                records.forEach(function(record) {
                    returnArray.push(services.Contacts.parse(record));
                });
                console.log(returnArray);
                return returnArray;
            })
            .catch(err => {
                throw err;
            });
    },
    parse: function(record) {
        var contact = {
            "id": record.get('Id'),
            "name": record.get('Name'),
            "firstName": record.get('FirstName'),
            "lastName": record.get('LastName'),
            "email": record.get('Email'),
            "githubHandle": record.get('GitHub_Handle__c')
        };
        return contact;
    },
    encode: function(contact) {
        var record = {
            "Id": contact.id,
            "Email": contact.email,
            "GitHub_Handle__c": contact.githubHandle
        };
        return record;
    }
};

export default DS.Adapter.extend({
	findAll(store, type) {
		type = type.modelName;
		if (type === 'team-member') { type = "Contacts"; }
		return services[type].retrieve({ limit: 100 });
	},
	findRecord(store, type, id) {
		type = type.modelName;
		if (type === 'team-member') { type = "Contacts"; }
		return new Ember.RSVP.Promise(resolve => {
			services[type].retrieve({ where: {Id: {eq: id} }, limit: 1})
				.then(data => {
					Ember.run(null, resolve, data);
				});
		});
	},
	createRecord() {

	},
	updateRecord(store, type, snapshot) {
        type = type.modelName;
        if (type === 'team-member') { type = "Contacts"; }
		var data = this.serialize(snapshot, {includeId: true});
        console.log('Pre-encoded data:', data);
        data = services[type].encode(data);
        console.log('Post-encoded data:', data);
		return new Ember.RSVP.Promise((resolve, reject) => {
            services[type].update(data)
                .then(data => {
                    Ember.run(null, resolve, data);
                })
                .catch(e => {
                    console.log(type + " update failed:", e);
                    Ember.run(null, reject, data);
                });
		});
	},
	deleteRecord() {

	},
	query(store, type, query) {
		return new Ember.RSVP.Promise(resolve => {
			var data = services[type].retrieve({ where: query });
			Ember.run(null, resolve, data);
		});
	}
});
