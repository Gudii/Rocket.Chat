Template.privateGroupsFlex.helpers
	selectedUsers: ->
		return Template.instance().selectedUsers.get()

	name: ->
		return Template.instance().selectedUserNames[this.valueOf()]

	groupName: ->
		return Template.instance().groupName.get()

	error: ->
		return Template.instance().error.get()

	item: -> #NTHU
		return Template.instance().item.get()

	roles: -> #NTHU
		return Template.instance().roles.get()

	autocompleteSettings: ->
		return {
			limit: 10
			# inputDelay: 300
			rules: [
				{
					# @TODO maybe change this 'collection' and/or template
					collection: 'UserAndRoom'
					subscription: 'userAutocomplete'
					field: 'username'
					template: Template.userSearch
					noMatchTemplate: Template.userSearchEmpty
					matchAll: true
					filter:
						exceptions: [Meteor.user().username].concat(Template.instance().selectedUsers.get())
						roles: Template.instance().roles.get()
					selector: (match) ->
						return { term: match}
					sort: 'username'
				},
			]
		}

Template.privateGroupsFlex.events
	'autocompleteselect #pvt-group-members': (event, instance, doc) ->
		instance.selectedUsers.set instance.selectedUsers.get().concat doc.username

		instance.selectedUserNames[doc.username] = doc.name

		event.currentTarget.value = ''
		event.currentTarget.focus()

	'change #pvt-group-roles': (event, instance) -> #NTHU
		test = []
		test = event.currentTarget.value
		test = _.difference Template.instance().item.get(), test

		Template.instance().item.set(test)
		instance.roles.set instance.roles.get().concat event.currentTarget.value

		event.currentTarget.value = ''
		event.currentTarget.focus()

	'click .remove-room-member': (e, instance) ->
		self = @
		users = Template.instance().selectedUsers.get()
		users = _.reject Template.instance().selectedUsers.get(), (_id) ->
			return _id is self.valueOf()

		Template.instance().selectedUsers.set(users)

		$('#pvt-group-members').focus()

	'click .remove-roles': (e, instance) -> #NTHU
		self = @
		instance.item.set instance.item.get().concat self.valueOf()
		role = Template.instance().roles.get()
		role = _.reject Template.instance().roles.get(), (_id) ->
			return _id is self.valueOf()

		Template.instance().roles.set(role)

	'click .cancel-pvt-group': (e, instance) ->
		SideNav.closeFlex ->
			instance.clearForm()

	'click header': (e, instance) ->
		SideNav.closeFlex ->
			instance.clearForm()

	'mouseenter header': ->
		SideNav.overArrow()

	'mouseleave header': ->
		SideNav.leaveArrow()

	'keydown input[type="text"]': (e, instance) ->
		Template.instance().error.set([])

	'keyup #pvt-group-name': (e, instance) ->
		if e.keyCode is 13
			instance.$('#pvt-group-members').focus()

	'keydown #pvt-group-members': (e, instance) ->
		if $(e.currentTarget).val() is '' and e.keyCode is 13
			instance.$('.save-pvt-group').click()

	'click .save-pvt-group': (e, instance) ->
		err = SideNav.validate()
		name = instance.find('#pvt-group-name').value.toLowerCase().trim()
		readOnly = instance.find('#channel-ro').checked
		instance.groupName.set name
		if not err
			Meteor.call 'createPrivateGroup', name, instance.selectedUsers.get(), readOnly, instance.roles.get(), (err, result) ->
				if err
					if err.error is 'error-invalid-name'
						instance.error.set({ invalid: true })
						return
					if err.error is 'error-duplicate-channel-name'
						instance.error.set({ duplicate: true })
						return
					if err.error is 'error-archived-duplicate-name'
						instance.error.set({ archivedduplicate: true })
						return
					return handleError(err)
				SideNav.closeFlex()
				instance.clearForm()
				FlowRouter.go 'group', { name: name }, FlowRouter.current().queryParams
		else
			Template.instance().error.set({fields: err})

		item = []
		for i in RocketChat.models.Roles.find().fetch()
			item = item.concat i._id
			Template.instance().item.set item

Template.privateGroupsFlex.onCreated ->
	instance = this
	instance.selectedUsers = new ReactiveVar []
	instance.selectedUserNames = {}
	instance.error = new ReactiveVar []
	instance.groupName = new ReactiveVar ''
	instance.roles = new ReactiveVar [] #NTHU
	instance.item = new ReactiveVar [] #NTHU
	item = []
	roles = RocketChat.models.Roles.find().fetch()
	for i in roles
		item = item.concat i._id
		Template.instance().item.set item


	instance.clearForm = ->
		instance.error.set([])
		instance.groupName.set('')
		instance.selectedUsers.set([])
		instance.find('#pvt-group-name').value = ''
		instance.find('#pvt-group-members').value = ''
		instance.roles.set([]) #NTHU
