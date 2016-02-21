import Ember from 'ember';

export default Ember.Route.extend({
	events: {
		didTransition() {
			Ember.run.later(this, function() {
				Ember.$('li[id^=progressStep]').removeClass('active');
				Ember.$('#progressStep_0').addClass('active');
			}, 150);
		}
	}
});
