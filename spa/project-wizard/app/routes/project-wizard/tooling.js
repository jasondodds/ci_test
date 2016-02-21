import Ember from 'ember';

export default Ember.Route.extend({
	setupController() {
		this.store.findAll('repository', {order: 'createdAt'})
			.then(repos => {
				this.controllerFor('project-wizard').get('model.repositories').addObjects(repos);
			});
	}
});
