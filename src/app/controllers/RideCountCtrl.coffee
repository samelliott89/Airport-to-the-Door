qantasApp = angular.module 'qantasApp'

qantasApp.controller 'RideCountCtrl', ($http, auth, nav, storage) ->

    @submitValue = (value) ->
        @value = value
        storage.set 'rideCount', @value
        $('.buttonOne').removeClass('rollIn').addClass('bounceOutLeft')
        $('.buttonTwo').removeClass('rollIn').addClass('bounceOutRight')

        $('.textOne').addClass('fadeOut')

        setTimeout (->
            nav.goto 'mapCtrl'
        ), 400

    @clearValue = ->
        @value = null
        nav.resetTo 'rideCountCtrl'

    return
