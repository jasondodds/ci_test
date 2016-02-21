import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.route('ProjectWizard', {path: '/'}, function() {
    this.route('ProjectDetails');
    this.route('TeamMembers');
    this.route('Environments');
    this.route('Tooling');
    this.route('Deploy');
  });
});

export default Router;
