qantasApp = angular.module 'qantasApp'

qantasApp.controller 'MatchConfirmCtrl', (nav, storage, MatchResource) ->

    @request = nav.getParams 'request'

    # $('#flightNumber').hide()
    $('#depAirportName').hide()
    $('#desAirportName').hide()
    $('#arrivalTime').hide()

    $('#flightNumber').ready ->
        $('#depAirportName').show()
        $('#flightNumber').ready ->
            $('#desAirportName').show()
            $('#flightNumber').ready ->
                $('#arrivalTime').show()

    @confirmRequest = ->
        request =
            pickup_latitude: _location.lat
            pickup_longitude: _location.lng
            flight_number: _flight.flight_number
            airport: _flight.departure_airport
            arrival_datetime: _arrivalDatetime

        MatchResource.requestMatch request
            .$promise.then (match) ->
                nav.goto 'pollingMatchCtrl'
                console.log 'match is', match
            .catch (err) ->
                console.log 'err is', err
                pg.alert {title: 'Error', msg: err.status}

    @cancelMatch = ->
        MatchResource.cancelMatch()
            .$promise.then (res) ->
                console.log 'canceled match is', res
            .catch (err) ->
                console.log 'cancel match err is', err
            .finally ->
                storage.clearFlightData()
                nav.setRootPage 'navigator'

    _getArrivalDatetime = (flight, arrivalBeforeMinutes) ->
        flightDepartureDatetime = _flight.local_departure_datetime
        flightDepartureMoment = moment(flightDepartureDatetime, 'DD-MM-YYYY_HH-mm-ss')
        arrivalMoment = moment(flightDepartureMoment).subtract(arrivalBeforeMinutes, 'minutes')
        return arrivalMoment.format('DD-MM-YYYY_HH-mm-ss')

    _location = nav.getParams 'location'
    _flight = nav.getParams 'flight'
    _arrivalDatetime = _getArrivalDatetime(_flight, storage.get 'minutesBefore')

    @departureAirportName = _flight.departure_airport_name
    @destinationAirportName = _flight.destination_airport_name
    @flightNumber = _flight.flight_number
    @arrivalDatetime = _arrivalDatetime

    return
