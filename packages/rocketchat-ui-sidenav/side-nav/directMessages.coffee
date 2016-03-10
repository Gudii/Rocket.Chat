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
	switch Meteor.user().username
		when 'bruce','Herman_Chang','pluswu','wanchinglienatntu.edu.tw','mike' then
		else
			Tracker.autorun =>
				Meteor.defer ->
					Meteor.call 'createDirectMessage', 'Herman_Chang', (err, result) ->
						if err?
							return toastr.error err.reason
					Meteor.call 'createDirectMessage', 'pluswu', (err, result) ->
						if err?
							return toastr.error err.reason
					Meteor.call 'createDirectMessage', 'wanchinglienatntu.edu.tw', (err, result) ->
						if err?
							return toastr.error err.reason
					Meteor.call 'createDirectMessage', 'mike', (err, result) ->
						if err?
							return toastr.error err.reason
