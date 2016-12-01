Template.mailer.helpers
	fromEmail: ->
		return RocketChat.settings.get 'From_Email'

Template.mailer.events
	'click .send': (e, t) ->

		e.preventDefault()

		subject = $(t.find('[name=subject]')).val()
		body = $(t.find('[name=body]')).val()
		temp = RocketChat.models.Users.find().fetch()
		console.log (temp)
		i=0
		while i<temp.length
			console.log (temp[i])
			Meteor.call 'sendSMTPEmail', "admin@hconsult.com", temp[i].emails[0].address, subject, body, (error, result) ->
				console.log ("OK")
			i++

			#nthu yuan
