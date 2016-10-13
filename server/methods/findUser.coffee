Meteor.methods
  findUser: (account_email, account_pass) ->
    exist = RocketChat.models.Users.findOne ({name: account_email})
    #console.log ("exist :" + exist)

    result = {}

    if exist
      #console.log ("OK")
      result.status = true
    else
      #console.log ("Need")
      result.status = false

    result.email = account_email
    result.password = account_pass

    return result
