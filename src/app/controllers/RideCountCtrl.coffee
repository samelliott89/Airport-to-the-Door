qantasApp = angular.module 'qantasApp'

qantasApp.controller 'RideCountCtrl', ($http, auth, nav, storage) ->

    jqLite = angular.element

    @submitValue = (value) ->
        @value = value
        storage.set 'rideCount', @value
        $('.buttonOne').addClass('animated bounceOutLeft')
        $('.buttonTwo').addClass('animated bounceOutRight')
        $('.textOne').addClass('animated bounceOutRight')
        # kind of fucking gross,
        # but will come up with better way to use animations
        setTimeout (->
            nav.goto 'mapCtrl'
        ), 400

    @clearValue = ->
        @value = null
        nav.resetTo 'rideCountCtrl'

    return
