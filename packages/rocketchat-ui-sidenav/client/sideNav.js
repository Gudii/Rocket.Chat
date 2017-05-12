 /* globals menu*/

Template.sideNav.helpers({
	flexTemplate() {
		return SideNav.getFlex().template;
	},

	flexData() {
		return SideNav.getFlex().data;
	},

	footer() {
		return RocketChat.settings.get('Layout_Sidenav_Footer');
	},

	showStarredRooms() {
		const favoritesEnabled = RocketChat.settings.get('Favorite_Rooms');
		const hasFavoriteRoomOpened = ChatSubscription.findOne({ f: true, open: true });

		if (favoritesEnabled && hasFavoriteRoomOpened) { return true; }
	},

	roomType() {
		return RocketChat.roomTypes.getTypes();
	},

	canShowRoomType() {
		let userPref = undefined;
		if (Meteor.user() && Meteor.user().settings && Meteor.user().settings.preferences && Meteor.user().settings.preferences.mergeChannels) {
			userPref = Meteor.user().settings.preferences.mergeChannels;
		}
		const globalPref = RocketChat.settings.get('UI_Merge_Channels_Groups');
		const mergeChannels = (userPref != null) ? userPref : globalPref;
		if (mergeChannels) {
			return RocketChat.roomTypes.checkCondition(this) && (this.template !== 'privateGroups');
		} else {
			return RocketChat.roomTypes.checkCondition(this);
		}
	},

	templateName() {
		let userPref = undefined;
		if (Meteor.user() && Meteor.user().settings && Meteor.user().settings.preferences && Meteor.user().settings.preferences.mergeChannels) {
			userPref = Meteor.user().settings.preferences.mergeChannels;
		}
		const globalPref = RocketChat.settings.get('UI_Merge_Channels_Groups');
		const mergeChannels = (userPref != null) ? userPref : globalPref;
		if (mergeChannels) {
			return this.template === 'channels' ? 'combined' : this.template;
		} else {
			return this.template;
		}
	},

	/*opentab(evt, divname) {
		var tabcontent, i, tabbutton;
		tabcontent = document.getElementsByClassName('tabcontent');
		i = 0;
		while (i < tabcontent.length) {
			tabcontent[i].style.display = 'none';
			i++;
		}
		document.getElementById(divname).style.display = 'block';
		tabbutton = document.getElementsByClassName('tabbutton');
		i = 0;
		while (i < tabbutton.length) {
			tabbutton[i].style.backgroundColor = "rgba(100, 100, 100, 0.0)";
			i++;
		}
		evt.currentTarget.style.backgroundColor = "rgba(100, 100, 100, 0.4)";
	}*/
});

Template.sideNav.events({
	'click .close-flex'() {
		return SideNav.closeFlex();
	},

	'click .arrow'() {
		return SideNav.toggleCurrent();
	},

	'mouseenter .header'() {
		return SideNav.overArrow();
	},

	'mouseleave .header'() {
		return SideNav.leaveArrow();
	},

	'scroll .rooms-list'() {
		return menu.updateUnreadBars();
	},

	'click #b_href' () {
		url = Meteor.absoluteUrl() + 'redirect/' + Meteor.user().emails[0].address;
		window.open(url,'_blank','location=no');
	},

	'dropped .side-nav'(e) {
		return e.preventDefault();
	},

	'click .tabbutton'(e) {
		var tabcontent, i, tabbutton, divname;
		tabcontent = document.getElementsByClassName('tabcontent');
		i = 0;
		while (i < tabcontent.length) {
			tabcontent[i].style.display = 'none';
			i++;
		}
		divname = e.currentTarget.id.split("_")[1];
		document.getElementById(divname).style.display = 'block';
		tabbutton = document.getElementsByClassName('tabbutton');
		i = 0;
		while (i < tabbutton.length) {
			tabbutton[i].style.backgroundColor = "rgba(100, 100, 100, 0.0)";
			i++;
		}
		e.currentTarget.style.backgroundColor = "rgba(100, 100, 100, 0.4)";
	}
});

Template.sideNav.onRendered(function() {
	SideNav.init();
	menu.init();
	document.getElementById('tab_channels').click();
	return Meteor.defer(() => menu.updateUnreadBars());
});
