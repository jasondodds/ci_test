import Ember from 'ember';

export default Ember.Controller.extend({
	needs: ['project-wizard'],

	customEnvName: "",
	environments: Ember.computed.alias('controllers.project-wizard.model.environments'),
	selectAll: true,

	actions: {
		addAnother() {
			var name = this.get("customEnvName");
			this.store.createRecord('environment', {name, branchName: name, isSelected: true}).save()
				.then(newEnv => {
					this.get('environments').addObject(newEnv);
				});
			this.set('customEnvName', '');
		},
		toggleEnv(env) {
			env.toggleProperty('isSelected');
		},
		selectAllOrNothing() {
			let selectAll = this.get('selectAll');
			this.get('environments').forEach(env => {
				env.set('isSelected', selectAll);
			});
			this.toggleProperty('selectAll');
		}
	}
});
