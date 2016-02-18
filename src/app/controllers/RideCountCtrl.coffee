qantasApp = angular.module 'qantasApp'

qantasApp.controller 'RideCountCtrl', ($http, auth, nav, storage) ->

    jqLite = angular.element

    @submitValue = (value) ->
        @value = value
        $('.buttonOne').addClass('animated bounceOutLeft')
        $('.buttonTwo').addClass('animated bounceOutRight')
        $('.textOne').addClass('animated bounceOutRight')
        setTimeout (->
            $('.removeElement').hide()
        ), 300

    @submitCount = ->
        storage.set 'rideCount', @value
        nav.goto 'mapCtrl'

    @clearValue = ->
        @value = null
        nav.resetTo 'rideCountCtrl'

    # Use this method to combine all the storage keys to one object to post to server
    # finalObj = _.extend({}, firstObj, secondObj)

    return
