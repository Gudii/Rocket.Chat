Meteor.publish('userAutocomplete', function(selector) {
	if (!this.userId) {
		return this.ready();
	}

	if (!_.isObject(selector)) {
		return this.ready();
	}

	const options = {
		fields: {
			name: 1,
			username: 1,
			status: 1
		},
		sort: {
			username: 1
		},
		limit: 10
	};

	const pub = this;
	const exceptions = selector.exceptions || [];
  const rid = selector.rid || [];
  const roles = RocketChat.models.Rooms.findOne({_id: rid},{fields: {_id: 0, roles: 1}});
	const cursorHandle = RocketChat.models.Users.findActiveByUsernameOrNameRegexWithExceptions(selector.term, exceptions, options, roles).observeChanges({
		added: function(_id, record) {
			return pub.added('autocompleteRecords', _id, record);
		},
		changed: function(_id, record) {
			return pub.changed('autocompleteRecords', _id, record);
		},
		removed: function(_id, record) {
			return pub.removed('autocompleteRecords', _id, record);
		}
	});

	this.ready();

	this.onStop(function() {
		return cursorHandle.stop();
	});
});
