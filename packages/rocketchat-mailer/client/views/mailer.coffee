import toastr from 'toastr'
Template.mailer.helpers
	fromEmail: ->
		return RocketChat.settings.get 'From_Email'

Template.mailer.events
	'click .send': (e, t) ->

		e.preventDefault()
		from = "mefeu.mcn@gmail.com"
		subject = $(t.find('[name=subject]')).val()
		body = $(t.find('[name=body]')).val()
		temp = RocketChat.models.Users.find().fetch()

		i=0
		while i<temp.length
			#console.log (temp[i])
			if temp[i].emails[0].address isnt undefined
				Meteor.call 'Mailer.sendMail', from, temp[i].emails[0].address, subject, body, (error, result) ->
					console.log ("OK")
			i++

			#nthu yuan
