import moment from 'moment'

fixCordova = (url) ->
	if url?.indexOf('data:image') is 0
		return url

	if Meteor.isCordova and url?[0] is '/'
		url = Meteor.absoluteUrl().replace(/\/$/, '') + url
		query = "rc_uid=#{Meteor.userId()}&rc_token=#{Meteor._localStorage.getItem('Meteor.loginToken')}"
		if url.indexOf('?') is -1
			url = url + '?' + query
		else
			url = url + '&' + query

	if Meteor.settings.public.sandstorm or url.match /^(https?:)?\/\//i
		return url
	else if navigator.userAgent.indexOf('Electron') > -1
		return __meteor_runtime_config__.ROOT_URL_PATH_PREFIX + url
	else
		return Meteor.absoluteUrl().replace(/\/$/, '') + __meteor_runtime_config__.ROOT_URL_PATH_PREFIX + url

Template.messageAttachment.helpers
	fixCordova: fixCordova

	parsedText: ->
		renderMessageBody { msg: this.text }

	loadImage: ->
		if Meteor.user()?.settings?.preferences?.autoImageLoad is false and this.downloadImages? is not true
			return false

		if Meteor.Device.isPhone() and Meteor.user()?.settings?.preferences?.saveMobileBandwidth and this.downloadImages? is not true
			return false

		return true

	getImageHeight: (height) ->
		return height || 200

	color: ->
		switch @color
			when 'good' then return '#35AC19'
			when 'warning' then return '#FCB316'
			when 'danger' then return '#D30230'
			else return @color

	collapsed: ->
		if this.collapsed?
			return this.collapsed
		else
			return Meteor.user()?.settings?.preferences?.collapseMediaByDefault is true

	time: ->
		messageDate = new Date(@ts)
		today = new Date()
		if messageDate.toDateString() is today.toDateString()
			return moment(@ts).format(RocketChat.settings.get('Message_TimeFormat'))
		else
			return moment(@ts).format(RocketChat.settings.get('Message_TimeAndDateFormat'))

	injectIndex: (data, previousIndex, index) ->
		data.index = previousIndex + '.attachments.' + index
		return

	window.handin_this = ->
		img=document.getElementById("theimg").src
		text =
			'<div class="upload-preview">
				<fieldset>
					<div class="input-line">
						<label>分類</label>
						<div>
							<select name="disease" id="disease">
				　				<option value="創傷超音波 Trauma-FAST">創傷超音波 Trauma-FAST</option>
							　	<option value="腎臟 kidney">腎臟 kidney</option>
							　	<option value="腹部主動脈 Abdominal Aorta">腹部主動脈 Abdominal Aorta</option>
							　	<option value="膽囊 Gallbladde">膽囊 Gallbladder</option>
								<option value="其他 Others">其他 Others</option>
							</select>
						</div>
					</div>

					<div class="input-line">
						<label>備註</label>
						<div>
							<input type="text" id="comment">
						</div>
					</div>
				</fieldset>
				<img src="' + img + '" height=200>
			</div>'
		swal
			title : "Handin!"
			text : text
			showCancelButton: true
			closeOnConfirm: false
			closeOnCancel: false
			html : true
		, (isConfirm) ->
			if isConfirm isnt true
				swal.close()
			mcnFileData =
				username : Meteor.user().name
				type : document.getElementById('disease').value
				comment : document.getElementById('comment').value
				img : img
			console.log (mcnFileData)
			Meteor.call 'file_handin', mcnFileData, (error, result) ->
			swal
				title: "Success"
				type: "success"
				timer: 3000

Meteor.startup ->
	wmark.init
		'position': "bottom-right",
		'opacity': 50,
		'className': "gallery-item",
		'path': "/images/logo/copyright.png"
