Template.sideNav.helpers
	flexTemplate: ->
		return SideNav.getFlex().template

	flexData: ->
		return SideNav.getFlex().data

	footer: ->
		return RocketChat.settings.get 'Layout_Sidenav_Footer'

	showStarredRooms: ->
		favoritesEnabled = RocketChat.settings.get 'Favorite_Rooms'
		hasFavoriteRoomOpened = ChatSubscription.findOne({ f: true, open: true })

		return true if favoritesEnabled and hasFavoriteRoomOpened

	roomType: ->
		return RocketChat.roomTypes.getTypes()

	canShowRoomType: ->
		return RocketChat.roomTypes.checkCondition(@)

	templateName: ->
		return @template

	window.opentab = (evt, divname) ->
		tabcontent = document.getElementsByClassName('tabcontent')
		i = 0
		while i < tabcontent.length
			tabcontent[i].style.display = 'none'
			i++
		document.getElementById(divname).style.display = 'block'
		tabbutton = document.getElementsByClassName('tabbutton')
		i = 0
		while i < tabbutton.length
			tabbutton[i].style.backgroundColor = "rgba(100, 100, 100, 0.0)"
			i++
		evt.currentTarget.style.backgroundColor = "rgba(100, 100, 100, 0.4)"
		return

Template.sideNav.events
	'click .close-flex': ->
		SideNav.closeFlex()

	'click .arrow': ->
		SideNav.toggleCurrent()

	'mouseenter .header': ->
		SideNav.overArrow()

	'mouseleave .header': ->
		SideNav.leaveArrow()

	'scroll .rooms-list': ->
		menu.updateUnreadBars()


	'click #b_href': ->
		url = Meteor.absoluteUrl() + 'redirect/' + Meteor.user().emails[0].address
		window.open(url,'_blank','location=no')

	'dropped .side-nav': (e) ->
		e.preventDefault()


Template.sideNav.onRendered ->
	SideNav.init()
	menu.init()
	document.getElementById('default').click();
	Meteor.defer ->
	menu.updateUnreadBars()
