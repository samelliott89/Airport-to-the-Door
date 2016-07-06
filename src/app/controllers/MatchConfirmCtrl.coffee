qantasApp = angular.module 'qantasApp'

qantasApp.controller 'MatchConfirmCtrl', (nav, storage, MatchResource) ->

    @request = nav.getParams 'request'

    # $('#flightNumber').hide()
    $('#depAirportName').hide()
    $('#desAirportName').hide()
    $('#arrivalTime').hide()

    $('#flightNumber').ready ->
        $('#depAirportName').show()
        $('#flightNumber').ready ->
            $('#desAirportName').show()
            $('#flightNumber').ready ->
                $('#arrivalTime').show()


    @confirmRequest = ->
        MatchResource.requestMatch @request
            .$promise.then (match) ->
                nav.goto 'pollingMatchCtrl'
                console.log 'match is', match
            .catch (err) ->
                console.log 'err is', err
                pg.alert {title: 'Error', msg: err.status}

    @cancelMatch = ->
        MatchResource.cancelMatch()
            .$promise.then (res) ->
                console.log 'canceled match is', res
            .catch (err) ->
                console.log 'cancel match err is', err
            .finally ->
                storage.clearFlightData()
                nav.setRootPage 'navigator'

    return