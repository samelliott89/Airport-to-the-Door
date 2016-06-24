qantasApp = angular.module 'qantasApp'

qantasApp.controller 'PollingMatchCtrl', ($http, $scope, MatchResource, nav, requestStatusCheck) ->

    requestStatusCheck.getRequest()
        .then (request) ->
            $scope.request = request
            if (request.status != 'NO_MATCH_FOUND')
                console.log 'flight', request.proposedFlight
                console.log 'user', request.proposedUser
        .catch (err) ->
            console.log 'an error occured', err

        # update bindings
        $scope.$apply

    @goBack = ->
        nav.setRootPage 'navigator'

    @cancelMatch = ->
        MatchResource.cancelMatch()
            .$promise.then (res) ->
                console.log 'canceled match is', res
            .catch (err) ->
                console.log 'cancel match err is', err
            .finally ->
                nav.setRootPage 'navigator'

    @rejectProposedMatch = ->
        MatchResource.rejectProposedMatch()
            .$promise.then (res) ->
                console.log 'rejected proposed match is', res
            .catch (err) ->
                console.log 'reject proposed match err is', err
            .finally ->
                nav.setRootPage 'navigator'

    @acceptProposedMatch = ->
        MatchResource.acceptProposedMatch()
        .$promise.then (request) ->
            console.log 'accept proposed match', res
            $scope.request = request
            $scope.$apply
        .catch (err) ->
            console.log 'accept proposed match err is', err

    return