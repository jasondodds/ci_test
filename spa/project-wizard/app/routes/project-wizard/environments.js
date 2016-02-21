import Ember from 'ember';

export default Ember.Route.extend({
	setupController() {
		var teamMembers = this.controllerFor('project-wizard').get('model.tmsNeedingEnvs');
        var environments = this.controllerFor('project-wizard').get('model.environments');
    	var store = this.store;
        return store.findAll('environment').then(storedEnvs => {
            environments.addObjects(storedEnvs);
            teamMembers.forEach(tm => {
                if (typeof(storedEnvs.findBy('branchName', "dev." + tm.get('githubHandle'))) === 'undefined') {
                    store.createRecord('environment', {
                        name: tm.get('name') + " Dev",
                        branchName: "dev." + tm.get('githubHandle')
                    }).save().then(env => {
                        environments.addObject(env);
                    });
                }
            });
        });
    }
});
