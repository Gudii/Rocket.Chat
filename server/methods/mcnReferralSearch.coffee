Future = Npm.require( 'fibers/future' )
Meteor.methods
  referral_search: (data) ->
    console.log data
    try
      result = RocketChat.models.mcnTestHospital.find().fetch()
      console.log result
    catch e
      console.log e

    return result
