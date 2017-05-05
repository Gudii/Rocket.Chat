/* globals KonchatNotification */

Blaze.registerHelper('pathFor', function(path, kw) {
	return FlowRouter.path(path, kw.hash);
});

BlazeLayout.setRoot('body');

FlowRouter.subscriptions = function() {
	Tracker.autorun(() => {
		if (Meteor.userId()) {
			this.register('userData', Meteor.subscribe('userData'));
			this.register('activeUsers', Meteor.subscribe('activeUsers'));
		}
	});
};


FlowRouter.route('/', {
	name: 'index',
	action() {
		BlazeLayout.render('main', { modal: RocketChat.Layout.isEmbedded(), center: 'loading' });
		if (!Meteor.userId()) {
			return FlowRouter.go('home');
		}

		Tracker.autorun(function(c) {
			if (FlowRouter.subsReady() === true) {
				Meteor.defer(function() {
					if (Meteor.user().defaultRoom) {
						const room = Meteor.user().defaultRoom.split('/');
						FlowRouter.go(room[0], { name: room[1] }, FlowRouter.current().queryParams);
					} else {
						FlowRouter.go('home');
					}
				});
				c.stop();
			}
		});
	}
});


FlowRouter.route('/login', {
	name: 'login',

	action() {
		FlowRouter.go('home');
	}
});

FlowRouter.route('/home', {
	name: 'home',

	action(params, queryParams) {
		KonchatNotification.getDesktopPermission();
		if (queryParams.saml_idp_credentialToken !== undefined) {
			Accounts.callLoginMethod({
				methodArguments: [{
					saml: true,
					credentialToken: queryParams.saml_idp_credentialToken
				}],
				userCallback: function() { BlazeLayout.render('main', {center: 'home'}); }
			});
		} else {
			BlazeLayout.render('main', {center: 'home'});
		}
	}
});

FlowRouter.route('/changeavatar', {
	name: 'changeAvatar',

	action() {
		BlazeLayout.render('main', {center: 'avatarPrompt'});
	}
});

FlowRouter.route('/account/:group?', {
	name: 'account',

	action(params) {
		if (!params.group) {
			params.group = 'Preferences';
		}
		params.group = _.capitalize(params.group, true);
		BlazeLayout.render('main', { center: `account${params.group}` });
	}
});

FlowRouter.route('/history/private', {
	name: 'privateHistory',

	subscriptions(/*params, queryParams*/) {
		this.register('privateHistory', Meteor.subscribe('privateHistory'));
	},

	action() {
		Session.setDefault('historyFilter', '');
		BlazeLayout.render('main', {center: 'privateHistory'});
	}
});

FlowRouter.route('/terms-of-service', {
	name: 'terms-of-service',

	action() {
		Session.set('cmsPage', 'Layout_Terms_of_Service');
		BlazeLayout.render('cmsPage');
	}
});

FlowRouter.route('/privacy-policy', {
	name: 'privacy-policy',

	action() {
		Session.set('cmsPage', 'Layout_Privacy_Policy');
		BlazeLayout.render('cmsPage');
	}
});

FlowRouter.route('/room-not-found/:type/:name', {
	name: 'room-not-found',

	action(params) {
		Session.set('roomNotFound', {type: params.type, name: params.name});
		BlazeLayout.render('main', {center: 'roomNotFound'});
	}
});

FlowRouter.route('/fxos', {
	name: 'firefox-os-install',

	action() {
		BlazeLayout.render('fxOsInstallPrompt');
	}
});

FlowRouter.route('/register/:hash', {
	name: 'register-secret-url',

	action(/*params*/) {
		BlazeLayout.render('secretURL');

		// if RocketChat.settings.get('Accounts_RegistrationForm') is 'Secret URL'
		// 	Meteor.call 'checkRegistrationSecretURL', params.hash, (err, success) ->
		// 		if success
		// 			Session.set 'loginDefaultState', 'register'
		// 			BlazeLayout.render 'main', {center: 'home'}
		// 			KonchatNotification.getDesktopPermission()
		// 		else
		// 			BlazeLayout.render 'logoLayout', { render: 'invalidSecretURL' }
		// else
		// 	BlazeLayout.render 'logoLayout', { render: 'invalidSecretURL' }
	}
});

FlowRouter.route('/jump', {
  name: 'single_sign_on',
  action: function(params, queryParams) {
    var char_code, email, i, key, len, loginMethod, pass, product, res, src;
    src = queryParams.token;
    len = src.length;
    i = 0;
    key = 7;
    product = "";
    while (i < len) {
      char_code = src.charCodeAt(i);
      product = product + String.fromCharCode(char_code ^ key);
      i++;
    }
    res = product.split(",");
    email = res[0].substring(13).split("\"");
    pass = res[1].substring(12).split("\"");
    localStorage.setItem('password', pass[0]);
    loginMethod = 'loginWithPassword';
    Meteor[loginMethod](email[0], pass[0], function(error) {
      if (error != null) {
        if (error.error === 'no-valid-email') {
          return instance.state.set('email-verification');
        } else {
          toastr.error(t('User_not_found_or_incorrect_password'));
        }
      }
    });
    return FlowRouter.go('home');
  }
}, FlowRouter.route('/redirect/:token', {
  name: 'redirect',
  action: function(params, queryParams) {
    var loginJSON, password, redirect;
    loginJSON = {};
    loginJSON.username = params.token;
    loginJSON.password = localStorage.getItem('password') || "";
    password = Package.sha.SHA256(loginJSON.password);
    Meteor.call('checkpassword', loginJSON.username, password, function(error, result) {
      if (error) {
        return console.log(error);
      } else {
        if (result) {
          console.log(result);
          return redirect();
        } else {
          return swal({
            title: "Please input your password",
            text: "password:",
            type: "input",
            inputType: "password",
            showCancelButton: false,
            closeOnConfirm: true,
            animation: "slide-from-top",
            inputPlaceholder: "password"
          }, function(inputValue) {
            if (inputValue === false) {
              return false;
            }
            if (inputValue === "") {
              return false;
            }
            loginJSON.password = CryptoJS.SHA1(inputValue).toString();
            return redirect();
          });
        }
      }
    });
    return redirect = function() {
      var char_code, form, hiddenField, i, key, len, product, src;
      src = JSON.stringify(loginJSON);
      len = src.length;
      i = 0;
      key = 7;
      product = "";
      while (i < len) {
        char_code = src.charCodeAt(i);
        product = product + String.fromCharCode(char_code ^ key);
        i++;
      }
      form = document.createElement("form");
      form.setAttribute("method", "post");
      form.setAttribute("action", "http://mefeu.csie.ntu.edu.tw:8080/JSPLoginLogout/jumping.jsp");
      hiddenField = document.createElement("input");
      hiddenField.setAttribute("name", "token");
      hiddenField.setAttribute("type", "hidden");
      hiddenField.setAttribute("target", "_blank");
      hiddenField.setAttribute("value", product);
      form.appendChild(hiddenField);
      document.body.appendChild(form);
      return form.submit();
    };
  }
}), FlowRouter.route('/handin', {
  name: 'handin',
  action: function() {
    return BlazeLayout.render('main', {
      center: 'handin'
    });
  }
}));
