qantasApp = angular.module 'qantasApp'

qantasApp.controller 'MatchConfirmCtrl', (nav, storage, pg, $scope, MatchResource) ->

    $('#flightNumber').addClass('animated bounceInLeft')
    $('#trip').addClass('animated bounceInRight')
    $('#arrivalTime').addClass('animated bounceInLeft')

    @confirmRequest = ->
        window.requestMatchModal.show()
        request =
            pickup_latitude: _location.lat
            pickup_longitude: _location.lng
            flight_number: _flight.flight_number
            airport: _flight.departure_airport
            arrival_datetime: _arrivalDatetime

        MatchResource.requestMatch request
            .$promise.then (matchRequest) ->
                window.requestMatchModal.hide()
                console.log 'match is', matchRequest
                nav.goto 'pollingMatchCtrl', {'matchRequest': matchRequest}
            .catch (err) ->
                window.requestMatchModal.hide()
                console.log 'err is', err
                pg.alert {title: 'Error', msg: 'Error is' + err.status}


    @cancelRequest = ->
        pg.confirm {
            title: 'Cancel request'
            msg: 'Are you sure you want to cancel your request?'
            buttons: {
                'Yes': _actuallyCancelRequest
                'Cancel': ->
            }
        }

    _getArrivalDatetime = (flight, arrivalBeforeMinutes) ->
        flightDepartureDatetime = _flight.local_departure_datetime
        flightDepartureMoment = moment(flightDepartureDatetime, 'DD-MM-YYYY_HH-mm-ss')
        arrivalMoment = moment(flightDepartureMoment).subtract(arrivalBeforeMinutes, 'minutes')

        return arrivalMoment.format('DD-MM-YYYY_HH-mm-ss')

    _actuallyCancelRequest = ->
        storage.clearFlightData()
        nav.setRootPage 'navigator'

    _location = nav.getParams 'location'
    _flight = nav.getParams 'flight'
    _arrivalDatetime = _getArrivalDatetime(_flight, storage.get 'minutesBefore')

    @departureAirport = if _flight.departure_airport is 'YSSY' then 'SYD' else _flight.departure_airport
    @departureAirportName = _flight.departure_airport_name

    @destinationAirport = if _flight.destination_airport is 'YSSY' then 'SYD' else _flight.destination_airport
    @destinationAirportName = _flight.destination_airport_name

    @flightNumber = _flight.flight_number
    @arrivalDatetime = _arrivalDatetime

    return
