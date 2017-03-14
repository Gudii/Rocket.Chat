class ModelKeys extends RocketChat.models._Base
  constructor: ->
    super(arguments...)

    @tryEnsureIndex { 'User': 1}, { sparse: 1}
    @tryEnsureIndex { 'rid': 1}
    @tryEnsureIndex { 'sKey': 1}
    @tryEnsureIndex { 'tKey': 1}
    @tryEnsureIndex { 'Created_at': 1}

  # INSERT
  saveKey: (username, rid, sKey, tKey, ts) ->
    key =
      user: username
      room: rid
      Key:
        sKey: sKey
        tKey: tKey
      ts: ts

    @insert key
    return key

RocketChat.models.Keys = new ModelKeys('key')
