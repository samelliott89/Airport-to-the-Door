qantasApp = angular.module 'qantasApp'

qantasApp.controller 'ListOfFlightsCtrl', ($http, auth, nav, storage) ->

    @isLoading = true

    setup = ->
        @flights = storage.get 'listOfFlights'
        @flightsAvailable = @flights.length
        @isLoading = false

    @goToFlightSummary = (selectedFlight) ->
        storage.set 'flightObj', selectedFlight
        nav.goto 'flightSummaryCtrl'

    setup()

  return