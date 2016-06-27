qantasApp = angular.module 'qantasApp'

qantasApp.controller 'PollingMatchCtrl', ($http, $scope, MatchResource, nav, requestStatusCheck, storage) ->

    @isLoading = true

    requestStatusCheck.getRequest()
        .then (request) ->
            $scope.request = request
            @isLoading = false
            if request.status is not 'NO_MATCH_FOUND' or not 'REQUESTED'
                console.log 'proposed', request.proposedFlight, request.proposedUser
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
                storage.clearFlightData()
                nav.setRootPage 'navigator'

    @rejectProposedMatch = ->
        MatchResource.rejectProposedMatch()
            .$promise.then (res) ->
                console.log 'rejected proposed match is', res
            .catch (err) ->
                console.log 'reject proposed match err is', err
            .finally ->
                storage.clearFlightData()
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