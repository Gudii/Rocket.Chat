Template.adminUsers.helpers
	isReady: ->
		return Template.instance().ready?.get()
	users: ->
		return Template.instance().users()
	isLoading: ->
		return 'btn-loading' unless Template.instance().ready?.get()
	hasMore: ->
		return Template.instance().limit?.get() is Template.instance().users?().length
	emailAddress: ->
		return _.map(@emails, (e) -> e.address).join(', ')
	flexData: ->
		return {
			tabBar: Template.instance().tabBar
			data: Template.instance().tabBarData.get()
		}

Template.adminUsers.onCreated ->
	instance = @
	@limit = new ReactiveVar 50
	@filter = new ReactiveVar ''
	@ready = new ReactiveVar true

	@tabBar = new RocketChatTabBar();
	@tabBar.showGroup(FlowRouter.current().route.name);

	@tabBarData = new ReactiveVar

	RocketChat.TabBar.addButton({
		groups: ['admin-users'],
		id: 'invite-user',
		i18nTitle: 'Invite_Users',
		icon: 'icon-paper-plane',
		template: 'adminInviteUser',
		order: 1
	})

	RocketChat.TabBar.addButton({
		groups: ['admin-users'],
		id: 'add-user',
		i18nTitle: 'Add_User',
		icon: 'icon-plus',
		template: 'adminUserEdit',
		order: 2
	})

	RocketChat.TabBar.addButton({
		groups: ['admin-users']
		id: 'admin-user-info',
		i18nTitle: 'User_Info',
		icon: 'icon-user',
		template: 'adminUserInfo',
		order: 3
	})

	@autorun ->
		filter = instance.filter.get()
		limit = instance.limit.get()
		subscription = instance.subscribe 'fullUserData', filter, limit
		instance.ready.set subscription.ready()

	@users = ->
		filter = _.trim instance.filter?.get()
		if filter
			filterReg = new RegExp s.escapeRegExp(filter), "i"
			query = { $or: [ { username: filterReg }, { name: filterReg }, { "emails.address": filterReg } ] }
		else
			query = {}

		query.type =
			$in: ['user', 'bot']

		return Meteor.users.find(query, { limit: instance.limit?.get(), sort: { username: 1, name: 1 } }).fetch()

Template.adminUsers.onRendered ->
	Tracker.afterFlush ->
		SideNav.setFlex "adminFlex"
		SideNav.openFlex()

Template.adminUsers.events
	'keydown #users-filter': (e) ->
		if e.which is 13
			e.stopPropagation()
			e.preventDefault()

	'keyup #users-filter': (e, t) ->
		e.stopPropagation()
		e.preventDefault()
		t.filter.set e.currentTarget.value

	'click .flex-tab .more': ->
		if RocketChat.TabBar.isFlexOpen()
			RocketChat.TabBar.closeFlex()
		else
			RocketChat.TabBar.openFlex()

	'click .user-info': (e, instance) ->
		thebar = document.getElementsByClassName("flex-tab-bar")[0]
		thebar.style.display = "block"
		e.preventDefault()

		instance.tabBarData.set Meteor.users.findOne @_id
		instance.tabBar.open('admin-user-info')

	'click .info-tabs button': (e) ->
		e.preventDefault()
		$('.info-tabs button').removeClass 'active'
		$(e.currentTarget).addClass 'active'

		$('.user-info-content').hide()
		$($(e.currentTarget).attr('href')).show()

	'click .load-more': (e, t) ->
		e.preventDefault()
		e.stopPropagation()
		t.limit.set t.limit.get() + 50

	'click .send': (e, t) ->

		e.preventDefault()
		subject = $(t.find('[name=subject]')).val()
		body = $(t.find('[name=body]')).val()
		if not subject
			return
		if not body
			return
		temp = RocketChat.models.Users.find().fetch()
		#console.log (temp)
		i=0
		while i<temp.length
			if not temp[i]
				i++
				continue
			if not temp[i].emails
				i++
				continue
			#console.log (temp[i])
			Meteor.call 'sendSMTPEmail', "mefeu.mcn@gmail.com", temp[i].emails[0].address, subject, body, (error, result) ->
				console.log ("OK")
			i++
		#11/24 nthu yuan
