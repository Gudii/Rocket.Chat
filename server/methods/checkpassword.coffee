Meteor.methods
  checkpassword: (email,password) ->
    user = RocketChat.models.Users.findOneByEmailAddress email
    unless s.trim(user?.services?.password?.bcrypt)
      return true

    unless password
      return false

    passCheck = Accounts._checkPassword(user, { digest: password, algorithm: 'sha-256' });
    if passCheck.error
      return false
    return true
