qantasApp = angular.module 'qantasApp'

qantasApp.controller 'FlightNumberCtrl', ($http, auth, nav, storage, FlightResource) ->

    # Function to hide keyboard after regex for flight number is satisifed
    hideKeyboard = ->
        document.activeElement.blur()
        Array::forEach.call document.querySelectorAll('input, textarea'), (it) ->
            it.blur()

    getListOfFlights = ->
        FlightResource.get('2015.18.22': @date)
            .then (flights) ->
                console.log 'flights', flights

    @submitFlightNumber = ->
        @finalFlightNumber = 'QF' + @flightNumber
        storage.set 'flightNumber', @finalFlightNumber
        nav.goto 'dateOfFlightCtrl'

    @clear = ->
        @flightNumber = null
        nav.resetTo 'flightNumberCtrl'

    hideKeyboard()
    getListOfFlights()

    return
