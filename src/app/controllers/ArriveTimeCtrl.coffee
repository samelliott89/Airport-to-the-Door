qantasApp = angular.module 'qantasApp'

qantasApp.controller 'ArriveTimeCtrl', ($http, nav, storage) ->

    selectedFlight = storage.get 'flightObj'
    @selectedFlightNumber = selectedFlight.flight_number

    localDatetime = selectedFlight.local_departure_datetime
    momentDatetime = moment(localDatetime, 'DD-MM-YYYY_HH-mm-ss')
    @formattedTimeOfFlight = momentDatetime.format('h:mm a')
    @relativeTimeUntilFlight = momentDatetime.fromNow()

    @submitValue = (value) ->
        $('.buttonOne').removeClass('rollIn').addClass('bounceOut')
        $('.buttonTwo').removeClass('rollIn').addClass('bounceOut')
        $('.buttonThree').removeClass('rollIn').addClass('bounceOut')
        $('.buttonFour').removeClass('rollIn').addClass('bounceOut')

        $('.textOne').addClass('fadeOut')
        $('.textTwo').addClass('fadeOut')

        storage.set 'minutesBefore', value

        # kind of fucking gross,
        # but will come up with better way to use animations
        setTimeout (->
            nav.goto 'rideCountCtrl'
        ), 800

    return


