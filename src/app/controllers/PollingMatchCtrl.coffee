qantasApp = angular.module 'qantasApp'

qantasApp.controller 'PollingMatchCtrl', ($http, $scope, $interval, MatchResource, nav, storage) ->
    _POLL_RATE_MS = 3000
    _STATE = {
        REQUESTED: 'REQUESTED',
        PROPOSED: 'PROPOSED',
        ACCEPTED: 'ACCEPTED',
        CONFIRMED: 'CONFIRMED'
    }

    _renderMatchRequestState = (state) ->
        console.log 'poll state', state
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

        $scope.$apply

    _renderRequestedState = (state) ->
        $scope.title = 'Finding match...'
        $scope.subTitle = 'We are looking for someone to match you with. We will let you know when we find someone!'

    _renderProposedState = (state) ->
        $scope.title = 'Waiting...'
        $scope.subTitle = state.proposal.given_name + ' would like to share a ride with you. Click Accept to proceed'

    _renderAcceptedState = (state) ->
        $scope.title = 'Match accepted'
        $scope.subTitle = 'We are waiting for reply from your .'

    _renderConfirmedState = (state) ->
        $scope.title = 'Congratulations'
        $scope.subTitle = 'You will be travelling with ' + state.request.given_name + '.'

    pollMatchRequest = ->
        console.log 'polling...'
        MatchResource.getMatch()
            .$promise.then -> _renderMatchRequestState
            .catch (err) ->
                console.log 'an error occured', err

            # update bindings
            $scope.$apply

    @cancelMatch = ->
        MatchResource.cancelMatch()
            .$promise.then (res) ->
                console.log 'canceled match is', res
            .catch (err) ->
                console.log 'cancel match err is', err
            .finally ->
                $interval.cancel(_poll_promise)
                storage.clearFlightData()
                nav.setRootPage 'navigator'

    @rejectProposedMatch = ->
        MatchResource.rejectProposedMatch()
            .$promise.then _renderMatchRequestState
            .catch (err) ->
                console.log 'reject proposed match err is', err

    @acceptProposedMatch = ->
        MatchResource.acceptProposedMatch()
        .$promise.then _renderMatchRequestState
        .catch (err) ->
            console.log 'accept proposed match err is', err

    state = nav.getParams 'matchRequest'
    _renderMatchRequestState state
    _poll_promise = $interval pollMatchRequest, _POLL_RATE_MS

    return
