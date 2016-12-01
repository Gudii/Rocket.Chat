Template.handin.helpers
  fileUploadAllowedMediaTypes: ->
    return RocketChat.settings.get('FileUpload_MediaTypeWhiteList')

Template.handin.events
  'change .upload-form input[type=file]': (event, template) ->
    console.log ("ok")
		e = event.originalEvent or event
		files = e.target.files
		if not files or files.length is 0
			files = e.dataTransfer?.files or []

		filesToUpload = []
		for file in files
			filesToUpload.push
				file: file
				name: file.name

		fileUpload filesToUpload

  'click .button': ->
    console.log ("OK")
