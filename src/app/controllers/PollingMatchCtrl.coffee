qantasApp = angular.module 'qantasApp'

qantasApp.controller 'PollingMatchCtrl', ($http, $scope, $interval, MatchResource, nav, storage) ->

    _POLL_RATE_MS = 3000

    _STATE =
        REQUESTED: 'REQUESTED'
        PROPOSED: 'PROPOSED'
        ACCEPTED: 'ACCEPTED'
        CONFIRMED: 'CONFIRMED'

    _actuallyCancelRequest = ->
        MatchResource.cancelMatch()
            .$promise.then (res) ->
                console.log 'canceled match is', res
            .catch (err) ->
                console.log 'cancel match err is', err
            .finally ->
                $interval.cancel _poll_promise
                storage.clearFlightData()
                nav.setRootPage 'navigator'

    _renderMatchRequestState = (state) ->
        console.log '_renderMatchRequestState being run'
        if state.status != $scope.status
            $scope.state = state
            $scope.status = state.status
            switch state.status
                when _STATE.REQUESTED
                    _renderRequestedState state
                when _STATE.PROPOSED
                    _renderProposedState state
                when _STATE.ACCEPTED
                    _renderAcceptedState state
                when _STATE.CONFIRMED
                    _renderConfirmedState state
                else
                    console.log 'Unexpected state', state.status
            $scope.apply

    _renderRequestedState = (state) ->
        $scope.title = 'Finding you a rideshare...'

    _renderProposedState = (state) ->
        $scope.title = 'We\'ve found you a ride.'

    _renderAcceptedState = (state) ->
        $scope.title = 'Match accepted'

    _renderConfirmedState = (state) ->
        $scope.title = 'Congratulations'

    pollMatchRequest = ->
        MatchResource.getMatch()
            .$promise.then (state) ->
                _renderMatchRequestState state
                console.log 'pollMatchRequest being run', state
            .catch (err) ->
                console.log 'an error occured', err
                if err.status is 404
                    $interval.cancel _poll_promise
                    storage.clearFlightData()
                    nav.setRootPage 'navigator'

    @cancelMatch = ->
        pg.confirm {
            title: 'Are you sure?'
            msg: 'Are you sure you want to cancel and start over?'
            buttons: {
                'Yes': _actuallyCancelRequest
                'No': ->
            }
        }

    @rejectProposedMatch = ->
        $scope.isLoading = true
        MatchResource.rejectProposedMatch()
            .$promise.then (state) ->
                _renderMatchRequestState state
            .catch (err) ->
                console.log 'reject proposed match err is', err
            .finally ->
                $scope.isLoading = false
        $scope.$apply

    @acceptProposedMatch = ->
        MatchResource.acceptProposedMatch()
        .$promise.then (state) ->
            _renderMatchRequestState state
        .catch (err) ->
            console.log 'accept proposed match err is', err
        .finally ->
            $scope.isLoading = false
        $scope.$apply
        
    state = nav.getParams 'matchRequest'
    $scope.state = state
    console.log (nav.getParams 'matchRequest')
    _poll_promise = $interval pollMatchRequest, _POLL_RATE_MS
    _renderMatchRequestState state
    $scope.isLoading = false
    return
