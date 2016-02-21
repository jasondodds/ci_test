import DS from 'ember-data';
import config from "../config/environment";
import SalesforceVRO from "./salesforceVRO";

var adapter = DS.FixtureAdapter.extend({});

if (config.environment === 'production') {
	adapter = SalesforceVRO;
}

export default adapter;
