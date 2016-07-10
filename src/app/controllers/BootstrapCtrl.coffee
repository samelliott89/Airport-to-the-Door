qantasApp = angular.module 'qantasApp'

qantasApp.controller 'BootstrapCtrl', (nav, MatchResource) ->
    ons.ready ->
        MatchResource.getMatch()
        .$promise.then (matchRequest) ->
            nav.goto 'pollingMatchCtrl', {matchRequest: matchRequest}
        .catch (err) ->
            console.log 'err status is', err.status
            if err.status == 404
                nav.goto 'dateOfFlightCtrl'
            else
                nav.setRootPage 'authCtrl'

    return



