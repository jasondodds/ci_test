import Ember from 'ember';
import config from "../config/environment";

export default Ember.Controller.extend({
	projectDetailsFilledOut: Ember.computed.alias('model.projectDetailsFilledOut'),
	hasSelectedTeamMembers: Ember.computed.notEmpty('model.selectedTeamMembers'),
	hasSelectedEnvironments: Ember.computed.notEmpty('model.selectedEnvironments'),
	hasSelectedRepositories: Ember.computed.notEmpty('model.selectedRepositories'),
	isNotDeploying: true,

	progressSteps: [
		{
			"route": "ProjectWizard.ProjectDetails",
			"name": "Project Details"
		},
		{
			"route": "ProjectWizard.TeamMembers",
			"name": "Team Members"
		},
		{
			"route": "ProjectWizard.Environments",
			"name": "Environments"
		},
		{
			"route": "ProjectWizard.Tooling",
			"name": "Accelerators & Tooling"
		},
		{
			"route": "ProjectWizard.Deploy",
			"name": "Deploy"
		}
	],
	currentStep: 0,
	previousStep: function() {
		let currentStep = this.get('currentStep');
		if (currentStep === 0) {
			return 0;
		} else {
			return currentStep - 1;
		}
	}.property('currentStep'),
	canGoBack: function() {
		let isNotDeploying = this.get('isNotDeploying');
		if (!isNotDeploying) return false;

		let currentStep = this.get('currentStep');
		return (currentStep !== 0);
	}.property('currentStep', 'isNotDeploying'),
	nextStep: function() {
		let currentStep = this.get('currentStep');
		if (currentStep === 4) {
			return 4;
		} else {
			return currentStep + 1;
		}
	}.property('currentStep'),
	canGoNext: function() {
		let isNotDeploying = this.get('isNotDeploying');
		if (!isNotDeploying) return false;
		
		let currentStep = this.get('currentStep');
		return (currentStep !== 4);
	}.property('currentStep', 'isNotDeploying'),

	canProceedTo(step) {
		if (config.environment === 'development') {
			return true;
		}

		var allGood = false;
		switch(step) {
			case 0:
				// Going back to Project Details, no validation needed
				allGood = true;
				break;
			case 1:
				// validate Project Details tab is completed
				if (this.get('projectDetailsFilledOut')) {
					allGood = true;
				} else {
					alert('Please fill out all required form fields before attempting to move on.');
					allGood = false;
				}
				break;
			case 2:
				// validate Team Members tab is completed
				if (this.get('hasSelectedTeamMembers')) {
					allGood = true;
				} else {
					alert('Please select at least one team member before attempting to move on.');
					allGood = false;
				}
				break;
			case 3:
				// validate Environments tab is completed
				if (this.get('hasSelectedEnvironments')) {
					allGood = true;
				} else {
					alert('Please select at least one environment before attempting to move on.');
					allGood = false;
				}
				break;
			case 4:
				allGood = true;
				break;
			default:
				console.log('Error: trying to reach a step that does not exist');
				break;
		}
		return allGood;
	},

	actions: {
		readyTheDeploy() {
			var model = this.get('model');
			var output = JSON.stringify(model.serialize());
			console.log('Build Settings being sent to appLocal:', output);
			appLocal.parameters.payload = output;
			var ready = confirm('Are you ready to deploy using the settings on this page?');
			if (ready) { appLocal.init(); }
		},
		goToStep(step) {
			let currentStep = this.get('currentStep');
			if (step < currentStep && step > -1) {
				return true;
			}
			let canProceed = this.canProceedTo(step);
			if (canProceed) {
				return true;
			} else {
				
				return false;
			}
		}
	}
});
