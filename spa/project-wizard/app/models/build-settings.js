import Ember from 'ember';
import DS from 'ember-data';

var attr = DS.attr;

export default DS.Model.extend({
  projectName: attr('string'),
  packageName: attr('string'),
  projectDescription: attr('string'),
  namespace: attr('string'),
  teamMembers: DS.hasMany('teamMember'),
  environments: DS.hasMany('environment'),
  repositories: DS.hasMany('repository'),

  selectedTeamMembers: Ember.computed.alias('teamMembers'),
  devTeamMembers: Ember.computed.filterBy('teamMembers', 'role', 'Developer'),
  pmTeamMembers: Ember.computed.filterBy('teamMembers', 'role', 'Product Owner'),
  tmsNeedingEnvs: Ember.computed.union('devTeamMembers', 'pmTeamMembers'),

  selectedEnvironments: Ember.computed.filterBy('environments', 'isSelected'),
  selectedRepositories: Ember.computed.filterBy('repositories', 'isSelected'),

  projectDetailsFilledOut: Ember.computed('projectName', 'packageName', 'projectDescription', 'namespace', function() {
    let projectName = this.get('projectName');
    let packageName = this.get('packageName');
    let projectDescription = this.get('projectDescription');
    let namespace = this.get('namespace');
    let isPresent = Ember.isPresent;
    return isPresent(projectName) && isPresent(packageName) && isPresent(projectDescription) && isPresent(namespace);
  })
});
