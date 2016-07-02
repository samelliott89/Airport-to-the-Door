qantasApp = angular.module 'qantasApp'

qantasApp.controller 'ArriveTimeCtrl', ($http, nav, storage) ->

    selectedFlight = storage.get 'flightObj'
    @selectedFlightNumber = selectedFlight.flight_number

    localDatetime = selectedFlight.local_departure_datetime
    momentDatetime = moment(localDatetime, 'DD-MM-YYYY_HH-mm-ss')
    @formattedTimeOfFlight = momentDatetime.format('h:mm a')
    @relativeTimeUntilFlight = momentDatetime.fromNow()

    @submitValue = (value) ->
        @value = value
        $('.buttonOne').removeClass('rollIn').addClass('bounceOut')
        $('.buttonTwo').removeClass('rollIn').addClass('bounceOut')
        $('.buttonThree').removeClass('rollIn').addClass('bounceOut')
        $('.buttonFour').removeClass('rollIn').addClass('bounceOut')
        # $('.textOne').addClass('bounceOutUp')
        # $('.textTwo').addClass('bounceOutDown')

        storage.set 'minutesBefore', @value

        if @value == 30
            @timeBefore = '30 minutes'
        else if @value == 60
            @timeBefore = '1 hour'
        else if @value == 120
            @timeBefore = '2 hours'
        else if @value == 180
            @timeBefore = '3 hours'

        # kind of fucking gross,
        # but will come up with better way to use animations
        setTimeout (->
            nav.goto 'rideCountCtrl'
        ), 800


    @clearValue = ->
        @value = null
        nav.resetTo 'arriveTimeCtrl'

    return


