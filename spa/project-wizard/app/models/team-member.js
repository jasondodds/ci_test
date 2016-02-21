import DS from 'ember-data';

var attr = DS.attr;

var TeamMember = DS.Model.extend({
    sfdc: attr('string'),
    name: attr('string'),
    firstName: attr('string'),
    lastName: attr('string'),
    githubHandle: attr('string'),
    role: attr('string'),
    email: attr('string')
});

TeamMember.reopenClass({
    FIXTURES: [{
        "id": "00361000003ihXvAAZ",
        "name": "Local Contact",
        "firstName": "Local",
        "lastName": "Contact",
        "email": "localcontact@example.com"
    },{
        "id": "00361000003ihXvAAI",
        "name": "Rose Gonzalez",
        "firstName": "Rose",
        "lastName": "Gonzalez",
        "email": "rose@edge.com"
    }, {
        "id": "00361000003ihXwAAI",
        "name": "Sean Forbes",
        "firstName": "Sean",
        "lastName": "Forbes",
        "email": "sean@edge.com"
    }, {
        "id": "00361000003ihXxAAI",
        "name": "Jack Rogers",
        "firstName": "Jack",
        "lastName": "Rogers",
        "email": "jrogers@burlington.com"
    }, {
        "id": "00361000003ihXyAAI",
        "name": "Pat Stumuller",
        "firstName": "Pat",
        "lastName": "Stumuller",
        "email": "pat@pyramid.net"
    }, {
        "id": "00361000003ihXzAAI",
        "name": "Andy Young",
        "firstName": "Andy",
        "lastName": "Young",
        "email": "a_young@dickenson.com"
    }, {
        "id": "00361000003ihY0AAI",
        "name": "Tim Barr",
        "firstName": "Tim",
        "lastName": "Barr",
        "email": "barr_tim@grandhotels.com"
    }, {
        "id": "00361000003ihY1AAI",
        "name": "John Bond",
        "firstName": "John",
        "lastName": "Bond",
        "email": "bond_john@grandhotels.com"
    }, {
        "id": "00361000003ihY2AAI",
        "name": "Stella Pavlova",
        "firstName": "Stella",
        "lastName": "Pavlova",
        "email": "spavlova@uog.com"
    }, {
        "id": "00361000003ihY3AAI",
        "name": "Lauren Boyle",
        "firstName": "Lauren",
        "lastName": "Boyle",
        "email": "lboyle@uog.com"
    }, {
        "id": "00361000003ihY4AAI",
        "name": "Babara Levy",
        "firstName": "Babara",
        "lastName": "Levy",
        "email": "b.levy@expressl&t.net"
    }, {
        "id": "00361000003ihY5AAI",
        "name": "Josh Davis",
        "firstName": "Josh",
        "lastName": "Davis",
        "email": "j.davis@expressl&t.net"
    }, {
        "id": "00361000003ihY6AAI",
        "name": "Jane Grey",
        "firstName": "Jane",
        "lastName": "Grey",
        "email": "jane_gray@uoa.edu"
    }, {
        "id": "00361000003ihY7AAI",
        "name": "Arthur Song",
        "firstName": "Arthur",
        "lastName": "Song",
        "email": "asong@uog.com"
    }, {
        "id": "00361000003ihY8AAI",
        "name": "Ashley James",
        "firstName": "Ashley",
        "lastName": "James",
        "email": "ajames@uog.com"
    }, {
        "id": "00361000003ihY9AAI",
        "name": "Tom Ripley",
        "firstName": "Tom",
        "lastName": "Ripley",
        "email": "tripley@uog.com"
    }, {
        "id": "00361000003ihYAAAY",
        "name": "Liz D'Cruz",
        "firstName": "Liz",
        "lastName": "D'Cruz",
        "email": "ldcruz@uog.com"
    }, {
        "id": "00361000003ihYBAAY",
        "name": "Edna Frank",
        "firstName": "Edna",
        "lastName": "Frank",
        "email": "efrank@genepoint.com"
    }, {
        "id": "00361000003ihYCAAY",
        "name": "Avi Green",
        "firstName": "Avi",
        "lastName": "Green",
        "email": "agreen@uog.com"
    }, {
        "id": "00361000003ihYDAAY",
        "name": "Siddartha Nedaerk",
        "firstName": "Siddartha",
        "lastName": "Nedaerk"
    }, {
        "id": "00361000003ihYEAAY",
        "name": "Jake Llorrac",
        "firstName": "Jake",
        "lastName": "Llorrac"
    }]
});

export default TeamMember;
