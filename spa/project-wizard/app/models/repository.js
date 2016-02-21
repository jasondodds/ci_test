import DS from 'ember-data';

var attr = DS.attr;

var Repository = DS.Model.extend({
    name: attr('string'),
    url: attr('string'),
    isSelected: attr('boolean')
});

Repository.reopenClass({
	FIXTURES: [{
	    "id": "1",
	    "name": "CS-UTILS",
	    "url": "https://github.com/CodeScience/csutils"
	}/*, {
	    "id": "2",
	    "name": "CS_CRUDFLS",
	    "url": "https://github.com/CodeScience/cs-crudfls"
	}, {
	    "id": "3",
	    "name": "CS-APEXPATTERNS",
	    "url": "https://github.com/CodeScience/cs-apexpatterns"
	}*/]
});

export default Repository;
