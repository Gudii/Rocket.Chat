Future = Npm.require( 'fibers/future' )
Meteor.methods
  acc_verify: (formData) ->
    future = new Future()
    Meteor.http.call("POST", "http://140.112.124.238/api/acc_verify",
      {data: {username: formData.emailOrUsername, password: formData.pass}},
      (error, result) ->

          future.return(result)
    )

    return future.wait()
