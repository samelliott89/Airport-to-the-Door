qantasApp = angular.module 'qantasApp'

qantasApp.controller 'ArriveTimeCtrl', ($http, nav, storage) ->
    selectedFlight = storage.get 'flightObj'
    @selectedFlightNumber = selectedFlight.flight_number

    localDatetime = selectedFlight.local_departure_datetime
    momentDatetime = moment(localDatetime, 'DD-MM-YYYY-HH-mm-ss')
    @formattedDateOfFlight = momentDatetime.format('MMMM Do')
    @relativeTimeUntilFlight = momentDatetime.fromNow()

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
        ), 300

        storage.set 'minutesBefore', @value

        if @value == 30
            @timeBefore = '30 minutes'
        else if @value == 60
            @timeBefore = '1 hour'
        else if @value == 120
            @timeBefore = '2 hours'
        else if @value == 180
            @timeBefore = '3 hours'

    @submitAmount = ->

        flightTime = selectedFlight.local_departure_datetime
        minutesBefore = storage.get 'minutesBefore'

        # add these two values together and then
        # set in object as arrivalTime

        nav.goto 'rideCountCtrl'

    @clearValue = ->
        @value = null
        nav.resetTo 'arriveTimeCtrl'

    return


