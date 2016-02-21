import Ember from 'ember';

export default Ember.Controller.extend({
	needs: ['project-wizard'],
	isNotDeploying: Ember.computed.alias('controllers.project-wizard.isNotDeploying'),

	actions: {
		readyTheDeploy() {
			this.set('isNotDeploying', false);
			this.get('controllers.project-wizard').send('readyTheDeploy');
		}
	}
});