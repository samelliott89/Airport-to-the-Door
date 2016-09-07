qantasApp = angular.module 'qantasApp'

qantasApp.controller 'PollingMatchCtrl', ($http, $scope, pg, $interval, MatchResource, nav, storage) ->

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
                $interval.cancel _poll_promise
                storage.clearFlightData()
                nav.setRootPage 'navigator'
            .catch (err) ->
                console.log 'cancel match err is', err

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
        # hack to hide the circle spinner as soon as this state resolves
        $('#circleSpinner').hide()
        $scope.title = 'Congratulations'
        $scope.subTitle = 'You will be travelling with ' + state.proposal.given_name + '.'
        $scope.state = state

    _formatNumber = (number) ->
        formattedNumber = number.replace(/\s/g, '')

        return formattedNumber

    # TODO(Sam Elliott) make these two functions one function
    # and differ on just the prepended protocol
    _callUser = (proposal) ->
        mobile = _formatNumber(proposal.phone_number)
        link = 'tel://' + mobile
        if window.isCordova
            window.open link, '_system'
        else
            window.open link, '_blank'

    _messageUser = (proposal) ->
        mobile = _formatNumber(proposal.phone_number)
        link = 'sms://' + mobile
        if window.isCordova
            window.open link, '_system'
        else
            window.open link, '_blank'

    _pollMatchRequest = ->
        MatchResource.getMatch()
            .$promise.then (state) ->
                _renderMatchRequestState state
                $scope.isLoading = false
                $scope.state = state
                $scope.$apply
            .catch (err) ->
                console.log 'an error occured', err
                if err.status is 404
                    $scope.isLoading = false
                    $interval.cancel _poll_promise
                    storage.clearFlightData()
                    nav.setRootPage 'navigator'

    @makeContact = ->
        proposal = $scope.state.proposal
        contactName = proposal.given_name

        actions = [
            {label: 'Call', action: -> _callUser proposal }
            {label: 'Message', action: -> _messageUser proposal }
        ]

        pg.actionSheet {
            title: 'Contact ' + contactName
            actions: actions
            cancel: { label: 'Cancel', action: -> }
        }

    @finish = ->
        _actuallyCancelRequest()

    @cancelMatch = ->
        pg.confirm {
            title: 'Cancel request'
            msg: 'Are you sure you want to cancel your request?'
            buttons: {
                'Yes': _actuallyCancelRequest
                'No': ->
            }
        }

    @rejectProposedMatch = ->
        MatchResource.rejectProposedMatch()
            .$promise.then (state) ->
                _renderMatchRequestState state
            .catch (err) ->
                console.log 'reject proposed match err is', err
                pg.alert {title: 'Error', msg: 'Error is' + err.status}

    @acceptProposedMatch = ->
        MatchResource.acceptProposedMatch()
        .$promise.then (state) ->
            _renderMatchRequestState state
        .catch (err) ->
            console.log 'accept proposed match err is ', err
            pg.alert {title: 'Error', msg: 'Error is ' + err.status}

    state = nav.getParams 'matchRequest'
    $scope.state = state
    _poll_promise = $interval _pollMatchRequest, _POLL_RATE_MS
    _renderMatchRequestState state

    return
