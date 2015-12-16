qantasApp = angular.module 'qantasApp'

qantasApp.controller 'FlightNumberCtrl', ($http, auth, nav, storage, FlightResource) ->

    # Function to hide keyboard after regex for flight number is satisifed
    hideKeyboard = ->
        document.activeElement.blur()
        Array::forEach.call document.querySelectorAll('input, textarea'), (it) ->
            it.blur()

    @submitFlightNumber = ->
        @finalFlightNumber = 'QF' + @flightNumber
        storage.set 'flightNumber', @finalFlightNumber
        nav.goto 'dateOfFlightCtrl'

    @clear = ->
        @flightNumber = null
        nav.resetTo 'flightNumberCtrl'

    hideKeyboard()

    return
