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
	'click .more-direct-messages': ->
		SideNav.setFlex "listDirectMessagesFlex"
		SideNav.openFlex()
		
Template.directMessages.onRendered ->
	switch Meteor.user()._id
		when 'smSAr4bi5qpFxNDRm','GWwBE8wxtTWxETN8g','dYJamDTs4Ankcbcqi','HHDABfJQ5D6eDZF9F','gcJwMyiqgzpMPTZR5','v4kXaZzwrB3imJdjt' then
		else
			Tracker.autorun =>
				Meteor.defer ->
					Meteor.call 'add_consultant', 'GWwBE8wxtTWxETN8g', (err, result) ->
						if err?
							return toastr.error err.reason
					Meteor.call 'add_consultant', 'dYJamDTs4Ankcbcqi', (err, result) ->
						if err?
							return toastr.error err.reason
					Meteor.call 'add_consultant', 'gcJwMyiqgzpMPTZR5', (err, result) ->
						if err?
							return toastr.error err.reason
					Meteor.call 'add_consultant', 'HHDABfJQ5D6eDZF9F', (err, result) ->
						if err?
							return toastr.error err.reason
