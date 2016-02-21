import Ember from 'ember';

export default Ember.Component.extend({
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
	]
});
