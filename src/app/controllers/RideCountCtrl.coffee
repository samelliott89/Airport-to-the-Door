qantasApp = angular.module 'qantasApp'

qantasApp.controller 'RideCountCtrl', ($http, auth, nav, storage) ->

    @submitValue = (value) ->
        @value = value
        storage.set 'rideCount', @value
        $('.buttonOne').removeClass('rollIn').addClass('bounceOutLeft')
        $('.buttonTwo').removeClass('rollIn').addClass('bounceOutRight')
        $('.textOne').removeClass('rollIn').addClass('bounceOutRight')

        $('.textOne').addClass('fadeOut')

        # kind of fucking gross,
        # but will come up with better way to use animations
        #
        setTimeout (->
            nav.goto 'mapCtrl'
        ), 400

    @clearValue = ->
        @value = null
        nav.resetTo 'rideCountCtrl'

    return
