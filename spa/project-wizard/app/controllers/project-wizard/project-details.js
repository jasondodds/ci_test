import Ember from 'ember';

export default Ember.Controller.extend({
	needs: ['project-wizard'],

	projectName: Ember.computed.alias('controllers.project-wizard.model.projectName'),
	packageName: Ember.computed.alias('controllers.project-wizard.model.packageName'),
	projectDescription: Ember.computed.alias('controllers.project-wizard.model.projectDescription'),
	projectNamespace: Ember.computed.alias('controllers.project-wizard.model.namespace'),
});
