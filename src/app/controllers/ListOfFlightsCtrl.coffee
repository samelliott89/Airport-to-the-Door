qantasApp = angular.module 'qantasApp'

qantasApp.controller 'ListOfFlightsCtrl', ($http, auth, nav, storage) ->

    @flights = storage.get 'listOfFlights'
    @flightsAvailable = @flights.length

    @goToFlightSummary = (selectedFlight) ->
        console.log selectedFlight
        storage.set 'flightObj', selectedFlight
        nav.goto 'arriveTimeCtrl'

  return