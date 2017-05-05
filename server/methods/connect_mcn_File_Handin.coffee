Future = Npm.require( 'fibers/future' )
Meteor.methods
  file_handin: (mcnFileData) ->
    console.log mcnFileData
    try
      RocketChat.models.mcnHandinRecord.saveHandinRecord mcnFileData
    catch e
      console.log e

    future = new Future()
    try
      Meteor.http.call("POST", "http://140.112.124.238/api/upload_record",
          {data: {username: mcnFileData.username, type: mcnFileData.type, comment: mcnFileData.comment, img: mcnFileData.img}},
          (error, result) ->
            #console.log result
            #console.log error
            future.return(result)
      )
    catch error
      console.log error

    return future.wait()
