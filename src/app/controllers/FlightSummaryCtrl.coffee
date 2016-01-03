qantasApp = angular.module 'qantasApp'

qantasApp.controller 'FlightSummaryCtrl', ($http, auth, nav, storage) ->

    # flightNumber, 'QF1234'
    @flightNumber = storage.get 'flightNumber'
    # flightDate, 'Tuesday 24th October'
    @flightDate = storage.get 'flight_date'
    # Dummy lat,long for now
    @latLong =
        location:
            latitude: 45
            longitude: -73

    console.log 'flightNumber', @flightNumber
    console.log 'flightDate', @flightDate
    console.log 'latLong', @latLong

    prepareFlightInfo = ->
        flightInfo = []

    @findRide = ->
        # Collect local storage values and create object to post to API
        nav.goto 'mapCtrl'

    prepareFlightInfo()

    return
