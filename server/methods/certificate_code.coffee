Future = Npm.require( 'fibers/future' )
Meteor.methods
  certificate_code: (uid, formData, email, pass) ->
    future = new Future()
    code = formData.captcha
    Meteor.http.call("POST", "http://mefeu.csie.ntu.edu.tw/api/certificate_code",
      {data: {uid: uid, code: code}},
      (error, result) ->
          future.return(result)

    )

    return future.wait()
