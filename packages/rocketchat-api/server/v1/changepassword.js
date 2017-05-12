RocketChat.API.v1.addRoute('changepassword', { authRequired: false}, {
  post() {
    if (!this.bodyParams.username) {
      return RocketChat.API.v1.failure('username is empty');
    }
    var user, new_password;
    user = RocketChat.models.Users.findOneByEmailAddress(this.bodyParams.username);
    this.bodyParams.old_password = Package.sha.SHA256(this.bodyParams.old_password);

    function checkPassword (user, currentPassword) {
      var ref, ref1;
      if (!s.trim(typeof user !== "undefined" && user !== null ? (ref = user.services) != null ? (ref1 = ref.password) != null ? ref1.bcrypt : void 0 : void 0 : void 0)) {
        return true;
      }

      if (!currentPassword) {
        return false;
      }
      var passCheck;
      passCheck = Accounts._checkPassword(user, {
        digest: currentPassword,
        algorithm: 'sha-256'
      });

      if (passCheck.error) {
        return false;
      }
      return true;
    }

    if (this.bodyParams.new_password != null) {
      console.log(checkPassword(user, this.bodyParams.old_password));
      if (!checkPassword(user, this.bodyParams.old_password)) {
        return RocketChat.API.v1.failure('Invalid password');
      }
    }
    new_password = _.trim(this.bodyParams.new_password);
    Accounts.setPassword(user._id, new_password, {
      logout: 0
    });
    return RocketChat.API.v1.success('success');
  }
});
