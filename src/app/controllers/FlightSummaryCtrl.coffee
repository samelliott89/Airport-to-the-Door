qantasApp = angular.module 'qantasApp'

qantasApp.controller 'FlightSummaryCtrl', ($http, auth, nav, storage) ->

    # flightNumber, 'QF1234'
    @flight = storage.get 'flightObj'

    @findRide = ->
        # Collect local storage values and create object to post to API
        nav.goto 'mapCtrl'


    return
