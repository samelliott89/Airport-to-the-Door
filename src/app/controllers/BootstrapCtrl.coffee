qantasApp = angular.module 'qantasApp'

qantasApp.controller 'BootstrapCtrl', (nav, auth, pg, MatchResource) ->
    ons.ready ->
        MatchResource.getMatch()
        .$promise.then (matchRequest) ->
            nav.goto 'pollingMatchCtrl', {matchRequest: matchRequest, animation: 'lift'}
        .catch (err) ->
            console.log 'err status is', err.status
            if err.status == 404
                nav.goto 'dateOfFlightCtrl', {animation: 'lift'}
            else
                nav.setRootPage 'authCtrl'
                pg.alert {msg: 'Unfortunately an error occurred and we had to log you out.', title: 'An error occurred'}

    return