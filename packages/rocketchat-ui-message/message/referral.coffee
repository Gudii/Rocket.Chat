import toastr from 'toastr'

katexSyntax = ->
	if RocketChat.katex.katex_enabled()
		return "$$KaTeX$$"   if RocketChat.katex.dollar_syntax_enabled()
		return "\\[KaTeX\\]" if RocketChat.katex.parenthesis_syntax_enabled()

	return false

Template.referral.helpers
	fileUploadAllowedMediaTypes: ->
		return RocketChat.settings.get('FileUpload_MediaTypeWhiteList')

	showFileUpload: ->
		if (RocketChat.settings.get('FileUpload_Enabled'))
			roomData = Session.get('roomData' + this._id)
			if roomData?.t is 'd'
				return RocketChat.settings.get('FileUpload_Enabled_Direct')
			else
				return true
		else
			return RocketChat.settings.get('FileUpload_Enabled')


Template.referral.events
	'click #submit' : (event) ->
		lx = 0
		ly = 0
		division = document.getElementById "form1"
		division = division.value
		console.log division
		temp = Meteor.call 'referral_search', division, (error, result) ->
			console.log result
			arr = []
			for i of result
				hospital = {
					name : result[i].HospitalName
					beds : result[i].AvailableBeds
					divisions : result[i].Division
					locationX : result[i].locationX
					locationY : result[i].locationY
					dis : (result[i].locationX-lx)*(result[i].locationX-lx)+(result[i].locationY-ly)*(result[i].locationY-ly)
				}
				if hospital.beds == 0
					continue
				divs = hospital.divisions
				for i of divs
					if divs[i] == division
						arr.push hospital
			arr.sort (a,b) ->
				return a.dis - b.dis
			console.log arr

Template.messageBox.onCreated ->
	@isMessageFieldEmpty = new ReactiveVar true
	@showMicButton = new ReactiveVar false
	@showVideoRec = new ReactiveVar false

	@autorun =>
		videoRegex = /video\/webm|video\/\*/i
		videoEnabled = !RocketChat.settings.get("FileUpload_MediaTypeWhiteList") || RocketChat.settings.get("FileUpload_MediaTypeWhiteList").match(videoRegex)
		if RocketChat.settings.get('Message_VideoRecorderEnabled') and (navigator.getUserMedia? or navigator.webkitGetUserMedia?) and videoEnabled and RocketChat.settings.get('FileUpload_Enabled')
			@showVideoRec.set true
		else
			@showVideoRec.set false

		wavRegex = /audio\/wav|audio\/\*/i
		wavEnabled = !RocketChat.settings.get("FileUpload_MediaTypeWhiteList") || RocketChat.settings.get("FileUpload_MediaTypeWhiteList").match(wavRegex)
		if RocketChat.settings.get('Message_AudioRecorderEnabled') and (navigator.getUserMedia? or navigator.webkitGetUserMedia?) and wavEnabled and RocketChat.settings.get('FileUpload_Enabled')
			@showMicButton.set true
		else
			@showMicButton.set false


Meteor.startup ->
	RocketChat.Geolocation = new ReactiveVar false

	Tracker.autorun ->
		if RocketChat.settings.get('MapView_Enabled') is true and RocketChat.settings.get('MapView_GMapsAPIKey')?.length and navigator.geolocation?.getCurrentPosition?
			success = (position) =>
				RocketChat.Geolocation.set position

			error = (error) =>
				console.log 'Error getting your geolocation', error
				RocketChat.Geolocation.set false

			options =
				enableHighAccuracy: true
				maximumAge: 0
				timeout: 10000

			navigator.geolocation.watchPosition success, error
		else
			RocketChat.Geolocation.set false
