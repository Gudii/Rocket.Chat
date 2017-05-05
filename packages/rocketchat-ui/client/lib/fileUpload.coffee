readAsDataURL = (file, callback) ->
	reader = new FileReader()
	reader.onload = (ev) ->
		callback ev.target.result, file

	reader.readAsDataURL file

readAsArrayBuffer = (file, callback) ->
	reader = new FileReader()
	reader.onload = (ev) ->
		callback ev.target.result, file

	reader.readAsArrayBuffer file


@fileUpload = (files) ->
	roomId = Session.get('openedRoom')
	files = [].concat files

	consume = ->
		file = files.pop()
		if not file?
			swal.close()
			return

		readAsDataURL file.file, (fileContent) ->
			if not RocketChat.fileUploadIsValidContentType file.file.type
				swal
					title: t('FileUpload_MediaType_NotAccepted')
					text: file.file.type || "*.#{s.strRightBack(file.file.name, '.')}"
					type: 'error'
					timer: 3000
				return

			if file.file.size is 0
				swal
					title: t('FileUpload_File_Empty')
					type: 'error'
					timer: 1000
				return

			text = ''
			Addwatermark = ''

			if file.file.type.split('/')[0].indexOf('image') >= 0  #if file is image then add watermark
				canvas = document.createElement('canvas')
				ctx = canvas.getContext('2d')
				img = new Image()
				img.src = fileContent
				url = ""
				dataurl = ""
				img.onload = ->
					canvas.width = img.naturalWidth
					canvas.height = img.naturalHeight
					ctx.drawImage(img, 0, 0)
					ctx.fillStyle = "#c3c3c5"; # watermark text style
					ctx.fillText("Copyright (c) 2017 Copyright Holder All Rights Reserved", 5, canvas.height - 1)
					url = canvas.toDataURL()
					dataurl = canvas.toDataURL()
					byteString = ""
					if url.split(',')[0].indexOf('base64') >= 0 #convert url to File object, otherwise cannot store files
						byteString = atob(url.split(',')[1])
					else
						byteString = unescape(url.split(',')[1])
					mimeString = url.split(',')[0].split(':')[1].split(';')[0]
					ia = new Uint8Array(byteString.length)
					for i in [0..byteString.length]
						ia[i] = byteString.charCodeAt(i)
					Addwatermark = new File([ia], file.name, {type:file.type})
					file.file = Addwatermark
			Meteor.setTimeout ->
				if file.type is 'audio'
					text = """
						<div class='upload-preview'>
							<audio  style="width: 100%;" controls="controls">
								<source src="#{fileContent}" type="audio/wav">
								Your browser does not support the audio element.
							</audio>
						</div>
						<div class='upload-preview-title'>
							<input id='file-name' style='display: inherit;' value='#{Handlebars._escape(file.name)}' placeholder='#{t("Upload_file_name")}'>
							<input id='file-description' style='display: inherit;' value='' placeholder='#{t("Upload_file_description")}'>
						</div>
					"""
				else if file.type is 'video'
					text = """
						<div class='upload-preview'>
							<video  style="width: 100%;" controls="controls">
								<source src="#{fileContent}" type="video/webm">
								Your browser does not support the video element.
							</video>
						</div>
						<div class='upload-preview-title'>
							<input id='file-name' style='display: inherit;' value='#{Handlebars._escape(file.name)}' placeholder='#{t("Upload_file_name")}'>
							<input id='file-description' style='display: inherit;' value='' placeholder='#{t("Upload_file_description")}'>
						</div>
					"""
				else
					text = """
						<div class='upload-preview'>
							<div class='upload-preview-file' style='background-image: url(#{url})'></div>
						</div>
						<div class='upload-preview-title'>
							<input id='file-name' style='display: inherit;' value='#{Handlebars._escape(file.name)}' placeholder='#{t("Upload_file_name")}'>
							<input id='file-description' style='display: inherit;' value='' placeholder='#{t("Upload_file_description")}'>
						</div>
					"""

				swal
					title: t('Upload_file_question')
					text: text
					showCancelButton: true
					closeOnConfirm: false
					closeOnCancel: false
					confirmButtonText: t('Send')
					cancelButtonText: t('Cancel')
					html: true
				, (isConfirm) ->
					consume()
					if isConfirm isnt true
						return

					record =
						name: document.getElementById('file-name').value or file.name or file.file.name
						size: file.file.size
						type: file.file.type
						rid: roomId
						description: document.getElementById('file-description').value

					upload = fileUploadHandler record, file.file

					uploading = Session.get('uploading') or []
					uploading.push
						id: upload.id
						name: upload.getFileName()
						percentage: 0

					Session.set 'uploading', uploading

					upload.onProgress = (progress) ->
						uploading = Session.get('uploading')

						item = _.findWhere(uploading, {id: upload.id})
						if item?
							item.percentage = Math.round(progress * 100) or 0
							Session.set 'uploading', uploading

					upload.start()

					Tracker.autorun (c) ->
						cancel = Session.get "uploading-cancel-#{upload.id}"
						if cancel
							upload.stop()
							c.stop()

							uploading = Session.get 'uploading'
							if uploading?
								item = _.findWhere(uploading, {id: upload.id})
								if item?
									item.percentage = 0
								Session.set 'uploading', uploading

							Meteor.setTimeout ->
								uploading = Session.get 'uploading'
								if uploading?
									item = _.findWhere(uploading, {id: upload.id})
									Session.set 'uploading', _.without(uploading, item)
							, 1000
			, 100
	consume()
