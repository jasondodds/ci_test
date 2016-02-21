import Ember from 'ember';

export default Ember.Controller.extend({
	needs: ['project-wizard'],

	customRepoURL: "",
	repositories: Ember.computed.alias('controllers.project-wizard.model.repositories'),
	selectAll: true,

	actions: {
		addAnother() {
			let url = this.get("customRepoURL");
			let matches = this.store.peekAll('repository', {url});
			if (matches.length > 0) {
				alert('You have already added this Repo');
			} else if (url.search(/^https:\/\/github.com\//i) !== -1) {
				let name = url.split('/').pop();
				this.store.createRecord('repository', {name, url, isSelected: true}).save()
					.then(repo => {
						this.get('repositories').addObject(repo);
					});
				this.set('customRepoURL', '');
			} else {
				alert('Custom Repo field should be a URL starting with https://github.com/');
			}
		},
		toggleRepo(repo) {
			repo.toggleProperty('isSelected');
		},
		selectAllOrNothing() {
			let selectAll = this.get('selectAll');
			this.get('repositories').forEach(repo => {
				repo.set('isSelected', selectAll);
			});
			this.toggleProperty('selectAll');
		}
	}
});
