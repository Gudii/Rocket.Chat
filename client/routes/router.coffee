Blaze.registerHelper 'pathFor', (path, kw) ->
	return FlowRouter.path path, kw.hash

BlazeLayout.setRoot 'body'

FlowRouter.subscriptions = ->
	Tracker.autorun =>
		if Meteor.userId()
			@register 'userData', Meteor.subscribe('userData')
			@register 'activeUsers', Meteor.subscribe('activeUsers')


FlowRouter.route '/',
	name: 'index'

	action: ->
		BlazeLayout.render 'main', { modal: RocketChat.Layout.isEmbedded(), center: 'loading' }
		if not Meteor.userId()
			return FlowRouter.go 'home'

		Tracker.autorun (c) ->
			if FlowRouter.subsReady() is true
				Meteor.defer ->
					if Meteor.user().defaultRoom?
						room = Meteor.user().defaultRoom.split('/')
						FlowRouter.go room[0], { name: room[1] }, FlowRouter.current().queryParams
					else
						FlowRouter.go 'home'
				c.stop()


FlowRouter.route '/login',
	name: 'login'

	action: ->
		FlowRouter.go 'home'


FlowRouter.route '/home',
	name: 'home'

	action: ->
		RocketChat.TabBar.showGroup 'home'
		BlazeLayout.render 'main', {center: 'home'}
		KonchatNotification.getDesktopPermission()


FlowRouter.route '/changeavatar',
	name: 'changeAvatar'

	action: ->
		RocketChat.TabBar.showGroup 'changeavatar'
		BlazeLayout.render 'main', {center: 'avatarPrompt'}

FlowRouter.route '/account/:group?',
	name: 'account'

	action: (params) ->
		unless params.group
			params.group = 'Preferences'
		params.group = _.capitalize params.group, true
		RocketChat.TabBar.showGroup 'account'
		BlazeLayout.render 'main', { center: "account#{params.group}" }


FlowRouter.route '/history/private',
	name: 'privateHistory'

	subscriptions: (params, queryParams) ->
		@register 'privateHistory', Meteor.subscribe('privateHistory')

	action: ->
		Session.setDefault('historyFilter', '')
		RocketChat.TabBar.showGroup 'private-history'
		BlazeLayout.render 'main', {center: 'privateHistory'}


FlowRouter.route '/terms-of-service',
	name: 'terms-of-service'

	action: ->
		Session.set 'cmsPage', 'Layout_Terms_of_Service'
		BlazeLayout.render 'cmsPage'

FlowRouter.route '/privacy-policy',
	name: 'privacy-policy'

	action: ->
		Session.set 'cmsPage', 'Layout_Privacy_Policy'
		BlazeLayout.render 'cmsPage'

FlowRouter.route '/room-not-found/:type/:name',
	name: 'room-not-found'

	action: (params) ->
		Session.set 'roomNotFound', {type: params.type, name: params.name}
		BlazeLayout.render 'main', {center: 'roomNotFound'}

FlowRouter.route '/fxos',
	name: 'firefox-os-install'

	action: ->
		BlazeLayout.render 'fxOsInstallPrompt'

FlowRouter.route '/register/:hash',
	name: 'register-secret-url'
	action: (params) ->
		BlazeLayout.render 'secretURL'

#Gudi
FlowRouter.route '/jump',
	name: 'single_sign_on'
	action: (params,queryParams)->
		#console.log (queryParams)
		src = queryParams.token
		#console.log ("src: " + src)
		len = src.length
		#console.log ("len: " + len)
		i = 0
		key = 7
		product = ""
		while i < len
			char_code = src.charCodeAt(i)
			product = product + String.fromCharCode(char_code^key)
			i++
		#console.log (product)
		res = product.split(",")
		#console.log (res)
		email = res[0].substring(13).split("\"")
		#console.log (email[0])
		pass = res[1].substring(12).split("\"")
		localStorage.setItem('password',pass[0])
		loginMethod = 'loginWithPassword'

		Meteor[loginMethod] email[0], pass[0], (error) ->
			if error?
				if error.error is 'no-valid-email'
					instance.state.set 'email-verification'
				else
					toastr.error t 'User_not_found_or_incorrect_password'
					return
		FlowRouter.go 'home'

	FlowRouter.route '/redirect/:token',
		name: 'redirect'
		action: (params, queryParams)->
			loginJSON = {}
			loginJSON.username = params.token
			loginJSON.password = localStorage.getItem('password') or ""
			password = Package.sha.SHA256(loginJSON.password)
			Meteor.call 'checkpassword', loginJSON.username, password, (error,result) ->
				if error
					console.log (error)
				else
					if result
						console.log (result)
						redirect()
					else
						swal {
							title: "Please input your password"
							text: "password:"
							type: "input"
							inputType: "password"
							showCancelButton: false
							closeOnConfirm: true
							animation: "slide-from-top"
							inputPlaceholder: "password"
						}, (inputValue) ->
							if inputValue is false
								return false

							if inputValue is ""
								return false

							loginJSON.password = CryptoJS.SHA1(inputValue).toString()
							redirect()
			redirect = ->
				src = JSON.stringify(loginJSON)
				len = src.length
				i = 0
				key = 7
				product = ""
				while i<len
					char_code = src.charCodeAt(i)
					product = product + String.fromCharCode(char_code^key)
					i++

				form = document.createElement("form")
				form.setAttribute("method", "post")
				form.setAttribute("action", "http://mefeu.csie.ntu.edu.tw:8080/JSPLoginLogout/jumping.jsp")

				hiddenField = document.createElement("input")
				hiddenField.setAttribute("name","token")
				hiddenField.setAttribute("type","hidden")
				hiddenField.setAttribute("target","_blank")
				hiddenField.setAttribute("value",product)
				form.appendChild(hiddenField)
				document.body.appendChild(form)

				form.submit()

	FlowRouter.route '/handin',
		name: 'handin'

		action: ->

			BlazeLayout.render 'main', {center: 'handin'}
		# if RocketChat.settings.get('Accounts_RegistrationForm') is 'Secret URL'
		# 	Meteor.call 'checkRegistrationSecretURL', params.hash, (err, success) ->
		# 		if success
		# 			Session.set 'loginDefaultState', 'register'
		# 			BlazeLayout.render 'main', {center: 'home'}
		# 			KonchatNotification.getDesktopPermission()
		# 		else
		# 			BlazeLayout.render 'logoLayout', { render: 'invalidSecretURL' }
		# else
		# 	BlazeLayout.render 'logoLayout', { render: 'invalidSecretURL' }
