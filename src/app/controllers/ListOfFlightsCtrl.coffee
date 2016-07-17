qantasApp = angular.module 'qantasApp'

qantasApp.controller 'ListOfFlightsCtrl', ($http, auth, nav, storage) ->

    @flights = storage.get 'listOfFlights'
    @flightsAvailable = @flights.length

    @goToFlightSummary = (selectedFlight) ->
        storage.set 'flightObj', selectedFlight
        nav.goto 'arriveTimeCtrl', {'forwards': true}

    return
