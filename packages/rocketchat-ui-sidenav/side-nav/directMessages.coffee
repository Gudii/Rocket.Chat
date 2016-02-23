Template.directMessages.helpers
	rooms: ->
		query = { t: { $in: ['d']}, f: { $ne: true }, open: true }

		if Meteor.user()?.settings?.preferences?.unreadRoomsMode
			query.alert =
				$ne: true

		return ChatSubscription.find query, { sort: 't': 1, 'name': 1 }
	isActive: ->
		return 'active' if ChatSubscription.findOne({ t: { $in: ['d']}, f: { $ne: true }, open: true, rid: Session.get('openedRoom') }, { fields: { _id: 1 } })?

Template.directMessages.events
	'click .add-room': (e, instance) ->
		SideNav.setFlex "directMessagesFlex"
		SideNav.openFlex()

Template.directMessages.onRendered ->
	if Meteor.user().username != 'bruce1' && 'bruce'
		Tracker.autorun =>
				Meteor.defer ->
					Meteor.call 'createDirectMessage', 'bruce1', (err, result) ->
						if err?
							return toastr.error err.reason
					Meteor.call 'createDirectMessage', 'bruce', (err, result) ->
						if err?
							return toastr.error err.reason
