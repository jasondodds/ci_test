import DS from 'ember-data';

var attr = DS.attr;

var Environment = DS.Model.extend({
    name: attr('string'),
    branchName: attr('string'),
    projectDefinition: attr('string'),
    namespace: attr('string'),
    isPackaging: attr('boolean'),
    parentEnvironment: DS.belongsTo('environment'),
    isProduction: attr('boolean'),
    // teamMembers: DS.hasMany('team-member'),
    isSelected: attr('boolean')
});

Environment.reopenClass({
	FIXTURES: [{
	    "id": "1",
	    "name": "Packaging",
	    "branchName": "master"
	}, {
	    "id": "2",
	    "name": "QA",
	    "branchName": "qa"
	}, {
	    "id": "3",
	    "name": "Test",
	    "branchName": "test"
	}]
});

export default Environment;