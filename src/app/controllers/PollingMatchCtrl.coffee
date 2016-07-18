qantasApp = angular.module 'qantasApp'

qantasApp.controller 'PollingMatchCtrl', ($http, $scope, $interval, MatchResource, nav, storage) ->

    _POLL_RATE_MS = 3000

    _STATE =
        REQUESTED: 'REQUESTED'
        PROPOSED: 'PROPOSED'
        ACCEPTED: 'ACCEPTED'
        CONFIRMED: 'CONFIRMED'

    $scope.isLoading = true

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
        $scope.status = state.status
        $scope.isLoading = false
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
        $scope.subTitle = 'You will be travelling with ' + state.proposal.given_name + '.'

    _callUser = ->
        console.log 'calling user'
        mobile = '+61437634569'
        link = 'tel:' + mobile
        window.open(link, '_self')

    _messageUser = ->
        console.log '_messageUser being called'
        mobile = '+61437634569'
        link = 'sms:' + mobile
        window.open(link, '_self')

    _pollMatchRequest = ->
        MatchResource.getMatch()
            .$promise.then (state) ->
                _renderMatchRequestState state
                console.log '_pollMatchRequest being run', state
                $scope.isLoading = false
            .catch (err) ->
                console.log 'an error occured', err
                if err.status is 404
                    $scope.isLoading = false
                    $interval.cancel _poll_promise
                    storage.clearFlightData()
                    nav.setRootPage 'navigator'

    @makeContact = ->
        user = state.proposal
        contactName = user.given_name

        actions = [
            {label: 'Call ', action: -> _callUser() }
            {label: 'Message', action: -> _messageUser() }
        ]

        pg.actionSheet {
            title: contactName
            actions: actions
            destructive: { label: 'Reset', action: @rejectProposedMatch() }
            cancel: { label: 'Cancel', action: -> }
        }

    @cancelMatch = ->
        pg.confirm {
            title: 'Cancel request'
            msg: 'Are you sure you want to cancel your request?'
            buttons: {
                'Yes': _actuallyCancelRequest
                'Cancel': ->
            }
        }

    @rejectProposedMatch = ->
        MatchResource.rejectProposedMatch()
            .$promise.then (state) ->
                _renderMatchRequestState state
            .catch (err) ->
                console.log 'reject proposed match err is', err

    @acceptProposedMatch = ->
        MatchResource.acceptProposedMatch()
        .$promise.then (state) ->
            _renderMatchRequestState state
        .catch (err) ->
            console.log 'accept proposed match err is', err

    state = nav.getParams 'matchRequest'
    $scope.state = state
    console.log (nav.getParams 'matchRequest')
    _poll_promise = $interval _pollMatchRequest, _POLL_RATE_MS
    _renderMatchRequestState state


    return
