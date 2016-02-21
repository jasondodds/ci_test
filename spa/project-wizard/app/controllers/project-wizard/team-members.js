import Ember from 'ember';

export default Ember.Controller.extend({
	needs: ['project-wizard'],

	teamMembers: Ember.computed.alias('controllers.project-wizard.model.teamMembers'),
	selectedTeamMember: {name: ''},
	tempName: '',

	isNotValidTeamMember: function() {
		let memberName = this.get('selectedTeamMember.name');
		let memberRole = this.get('selectedRole');
		let isValidEmail = this.get('isValidEmail');
		let isValidGithub = this.get('isValidGithub');
		return !(Ember.isPresent(memberName) && memberRole !== 'none' && memberRole.length > 0 && isValidEmail && isValidGithub);
	}.property('selectedTeamMember', 'selectedRole', 'isValidEmail', 'isValidGithub'),

	memberRoles: [
        "Architect",
        "Developer",
        "Product Owner",
        "QA/QE",
        "Scrum Master",
        "UI/UX"
    ],
	selectedRole: "none",

	memberEmail: "",
	isValidEmail: Ember.computed('memberEmail', function() {
		var memberEmail = this.get('memberEmail');
		return (memberEmail.search(/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i) !== -1);
	}),

	memberGithub: "",
	isValidGithub: false,
	checkGithub: function() {
		var handle = this.get('memberGithub');
		if (Ember.isBlank(handle)) {
			this.set('isValidGithub', false);
			return;
		}
		Ember.$.getJSON('https://api.github.com/users/'+handle)
			.then(() => {
				this.set('isValidGithub', true);
			})
			.fail(() => {
				this.set('isValidGithub', false);
			});
	},
	githubChanged: Ember.observer('memberGithub', function() {
		Ember.run.throttle(this, 'checkGithub', 750, false);
	}),

	actions: {
		updateRole: function() {
			this.set('selectedRole', Ember.$('#memberRole').val());
		},
		handleKeydown: function(dropdown, e) {
			if (e.keyCode !== 13) { return; }
			let text = e.target.value;
			if (text.length > 0 && this.get('model').indexOf(text) === -1) {
				this.set('selectedTeamMember',{name:text,id:''});
				this.set('tempName',text);
			}
		},
		selectItem: function(teamMember) {
			if(teamMember){
				this.set('selectedTeamMember', teamMember);
				this.set('memberEmail', teamMember.get('email'));
				this.set('memberGithub', teamMember.get('githubHandle'));
				this.checkGithub();
			}
		},
		addAnother: function() {
			let email = this.get('memberEmail');
			let role = this.get('selectedRole');
			let memberGithub = this.get('memberGithub');
			let tm = this.get('model').filterBy('email', email)[0];
			if (typeof(tm) !== 'undefined') {
				var boolGithubChanged = false;
				let githubHandle = tm.get('githubHandle');
				if(tm.get('githubHandle') != memberGithub){
					boolGithubChanged = true;
				}
				tm.set('githubHandle', memberGithub);
				tm.set('role', role);
				tm.set('sfdc', tm.id);
				if(boolGithubChanged){
					this.get('teamMembers').pushObject(tm);
				}
				else {
					this.get('teamMembers').pushObject(tm);
				}
				
			} else {
				let name = this.get('tempName');
				let githubHandle = memberGithub;
				tm = this.store.createRecord('team-member', {name, role, email, githubHandle});
				this.get('teamMembers').pushObject(tm);
			}

			this.set('selectedTeamMember', '');
			Ember.$('#memberRole').val("none");
			this.set('selectedRole', 'none');
			this.set('memberEmail', '');
			this.set('memberGithub', '');
			this.checkGithub();
		},
		removeMember: function(member) {
			this.get('teamMembers').removeObject(member);
			var storedEnvs = this.store.peekAll('environment');
			var env = storedEnvs.findBy('name', member.get('name') + " Dev");
			if(env != null){
				storedEnvs.findBy('name', member.get('name') + " Dev").destroyRecord();
			}
		}
	}
});
