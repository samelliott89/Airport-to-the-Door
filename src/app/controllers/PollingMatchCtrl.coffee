qantasApp = angular.module 'qantasApp'

qantasApp.controller 'PollingMatchCtrl', ($http, $scope, MatchResource, nav) ->

    @isLoading = true

    MatchResource.getMatch()
        .$promise.then (match) ->
            if (match.status == 'REQUESTED')
                $scope.viewRequestTitleStatus = 'Finding match...'
                $scope.viewRequestMessage = 'We are looking for someone to match you with. We will let you know when we find someone!'

            else

                if (match.status == 'PROPOSAL')
                    $scope.viewRequestTitleStatus = 'Waiting...'
                    $scope.viewRequestMessage = 'We have found someone, we are just waiting for a reply.'

                else if (match.status == 'ACCEPTED')
                    $scope.viewRequestTitleStatus = 'Match accepted'
                    $scope.viewRequestMessage = 'Your match has accepted your proposal.'

                else if (match.status == 'CONFIRMED')
                    $scope.viewRequestTitleStatus = 'Match found'
                    $scope.viewRequestMessage = 'You have a confimed match.'

                    # the proposed user as part of request
                    # only available for PROPOSAL, ACCEPTED OR CONFIRMED
                    $scope.proposedFlight = match.proposal

                    # the proposed request
                    # only available for PROPOSAL, ACCEPTED OR CONFIRMED
                    $scope.proposedUser = match.request

            # the current status of the request
            $scope.requestStatus = match.status

            $scope.$apply

            console.log 'match status', $scope.requestStatus, $scope.proposedFlight, $scope.proposedUser

        .catch (err) ->

            if err.status == 404
                $scope.requestStatus = 'NO MATCH FOUND'
                $scope.viewRequestTitleStatus = 'No request'
                $scope.viewRequestMessage = 'You have not put in a request to match with anyone.'

                $scope.$apply
                console.log 'requestStatus', $scope.requestStatus
            else
                pg.alert {title: 'Error', msg: 'An error occured'}
                console.log 'err status is', err.status

        @isLoading = false

    @goBack = ->
        nav.setRootPage 'navigator'

    @rejectProposedMatch = ->
        MatchResource.cancelMatch()
            .$promise.then (res) ->
                console.log 'canceled match is', res
            .catch (err) ->
                console.log 'err is', err
            .finally ->
                nav.setRootPage 'navigator'

    return