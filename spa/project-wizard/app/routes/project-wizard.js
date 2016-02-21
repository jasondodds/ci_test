import Ember from 'ember';

export default Ember.Route.extend({
	model() {
		return this.store.createRecord('build-settings');
	},
	setupController(ctrl, model) {
		this._super(ctrl, model);
		let steps = ctrl.get('progressSteps');
		let step = ctrl.get('currentStep');
		this.transitionTo(steps[step].route);
	},
	actions: {
		goToStep(step) {
			this.controller.set('currentStep', step);
			let steps = this.controller.get('progressSteps');
			this.transitionTo(steps[step].route);
		},
		didTransition() {
			Ember.$('li[id^=progressStep]').removeClass('active');
			let step = this.controller.get('currentStep');
			Ember.$('#progressStep_' + step).addClass('active');
		},
		resetWizard() {
			var reallyReally = confirm('Do you really want to clear this wizard and start over? If you click "Ok", all custom environments and repos will be deleted.');
			if (reallyReally) {
				var controller = this.controller;
				return this.store.findAll('environment').then(envs => {
					return envs.forEach(env => {
						let id = env.get('id');
						if (!["1", "2", "3"].contains(id)) {
							env.destroyRecord();
						} else {
							env.set('isSelected', false);
						}
					});
				})
				.then(envs => {
					return this.store.findAll('repository').then(repos => {
						return repos.forEach(repo => {
							let id = repo.get('id');
							if (!["1", "2", "3"].contains(id)) {
								repo.destroyRecord();
							} else {
								repo.set('isSelected', false);
							}
						});
					});
				})
				.finally(() => {
					controller.get('model').destroyRecord();
					controller.set('model', this.store.createRecord('build-settings'));
					controller.set('isNotDeploying', true);
					this.send('goToStep', 0);
				});
			}
		}
	}
});
