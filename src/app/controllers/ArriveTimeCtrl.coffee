qantasApp = angular.module 'qantasApp'

qantasApp.controller 'ArriveTimeCtrl', ($http, nav, storage) ->

    jqLite = angular.element
    selectedFlight = storage.get 'flightObj'
    localTime = selectedFlight.local_departure_time
    friendlyTime = moment('DD-MM-YYYY_HH-MM-SS', localTime, true)
    formatTime = new Date(friendlyTime)
    @finalTime = moment(formatTime).format('MMMM Do YYYY, h:mm:ss a')
    @timeRemaining = moment(@finalTime).startOf('hour').fromNow()

    @submitValue = (value) ->
        @value = value
        $('.buttonOne').addClass('animated bounceOut')
        $('.buttonTwo').addClass('animated bounceOut')
        $('.buttonThree').addClass('animated bounceOut')
        $('.buttonFour').addClass('animated bounceOut')
        $('.textOne').addClass('animated bounceOutUp')
        $('.textTwo').addClass('animated bounceOutDown')
        setTimeout (->
            $('.removeElement').hide()
        ), 500

        storage.set 'minutesBefore', @value

    @submitAmount = ->
        nav.goto 'rideCountCtrl'

    @clearValue = ->
        @value = null
        nav.resetTo 'arriveTimeCtrl'

    return


