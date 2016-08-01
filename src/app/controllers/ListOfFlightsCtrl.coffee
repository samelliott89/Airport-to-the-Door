qantasApp = angular.module 'qantasApp'

qantasApp.controller 'ListOfFlightsCtrl', ($http, auth, nav, storage) ->
    flightInFuture = (flight) ->
        localDepartureTime = moment(flight.local_departure_datetime, 'DD-MM-YYYY_HH-mm-ss')
        return localDepartureTime >= moment()

    @goToFlightSummary = (selectedFlight) ->
        storage.set 'flightObj', selectedFlight
        nav.goto 'arriveTimeCtrl', {'forwards': true}

    allFlights = storage.get 'listOfFlights'
    @flights = allFlights.filter flightInFuture
    @flightsAvailable = @flights.length

    return
