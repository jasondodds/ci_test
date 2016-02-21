import DS from 'ember-data';

export default DS.JSONSerializer.extend(DS.EmbeddedRecordsMixin, {
	attrs: {
		environments: { embedded: 'always' },
		repositories: { embedded: 'always' },
		teamMembers: { embedded: 'always' },
	}
});
