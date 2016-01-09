qantasApp = angular.module 'qantasApp'

qantasApp.controller 'FlightSummaryCtrl', ($http, auth, nav, storage) ->

    # flightNumber, 'QF1234'
    @flight = storage.get 'flightObj'

    # Dummy lat,long for now
    @latLong =
        location:
            latitude: 45
            longitude: -73

    @findRide = ->
        # Collect local storage values and create object to post to API
        nav.goto 'mapCtrl'


    return
