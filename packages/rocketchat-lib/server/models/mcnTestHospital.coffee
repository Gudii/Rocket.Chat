class ModelmcnTestHospital extends RocketChat.models._Base
  constructor: ->
    super(arguments...)

    @tryEnsureIndex { 'uploadedAt': 1 }

  # INSERT
  saveHandinRecord: (mcnFileData) ->
    data =
      username: mcnFileData.username
      type: mcnFileData.type
      comment: mcnFileData.comment
      img: mcnFileData.img


    @insert data
    return data

RocketChat.models.mcnTestHospital = new ModelmcnTestHospital('mcnTestHospital')
