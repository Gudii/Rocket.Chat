Meteor.publish 'userAutocomplete', (selector) ->
	unless this.userId
		return this.ready()

	if not _.isObject selector
		return this.ready()

	options =
		fields:
			name: 1
			username: 1
			status: 1
		sort:
			username: 1
		limit: 10

	pub = this

	exceptions = selector.exceptions or []
	roles = selector.roles or [] #NTHU
	cursorHandle = RocketChat.models.Users.findActiveByUsernameOrNameRegexWithExceptions(selector.term, exceptions, options, roles).observeChanges #NTHU
		added: (_id, record) ->
			pub.added("autocompleteRecords", _id, record)

		changed: (_id, record) ->
			pub.changed("autocompleteRecords", _id, record)

		removed: (_id, record) ->
			pub.removed("autocompleteRecords", _id, record)

	@ready()
	@onStop ->
		cursorHandle.stop()
	return
