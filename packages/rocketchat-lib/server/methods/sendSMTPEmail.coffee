Meteor.methods
	sendSMTPEmail: (from,to,subject,body) ->

		if not Meteor.userId()
			throw new Meteor.Error 'error-invalid-user', "Invalid user", { method: 'sendSMTPTestEmail' }

		user = Meteor.user()
		unless user.emails?[0]?.address
			throw new Meteor.Error 'error-invalid-email', "Invalid email", { method: 'sendSMTPTestEmail' }

		this.unblock()

		header = RocketChat.placeholders.replace(RocketChat.settings.get('Email_Header') || '');
		footer = RocketChat.placeholders.replace(RocketChat.settings.get('Email_Footer') || '');

		console.log 'Sending test email to ' + to

		try
			Email.send
				to: to
				from: from
				subject: subject
				html: header + "<p>" + body + "</p>" + footer
		catch error
			throw new Meteor.Error 'error-email-send-failed', 'Error trying to send email: ' + error.message, { method: 'sendSMTPTestEmail', message: error.message }

		return {
			message: "Your_mail_was_sent_to_s"
			params: to
		}

# Limit a user to sending 1 test mail/second
DDPRateLimiter.addRule
	type: 'method'
	name: 'sendSMTPEmail'
	userId: (userId) ->
		return true
, 10, 1000
