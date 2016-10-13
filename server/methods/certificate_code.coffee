Future = Npm.require( 'fibers/future' )
Meteor.methods
  certificate_code: (uid, formData, email, pass) ->
    future = new Future()
    code = formData.captcha
    Meteor.http.call("POST", "http://140.112.124.238/api/certificate_code",
      {data: {uid: uid, code: code}},
      (error, result) ->
          #console.log (result)
          future.return(result)

    )

    return future.wait()
