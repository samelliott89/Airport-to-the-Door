qantasApp = angular.module 'qantasApp'

qantasApp.controller 'PollingMatchCtrl', ($http, $scope, MatchResource, nav) ->

    @isLoading = true

    MatchResource.getMatch()
        .$promise.then (match) ->
            # no need for a handler as logic
            # will be held in template
            $scope.requestStatus = match.status
            $scope.$apply
            console.log 'match status on polling view', $scope.requestStatus
        .catch (err) ->
            if err.status == 404
                $scope.requestStatus = 'NO MATCH FOUND'
                $scope.$apply
                console.log 'requestStatus', $scope.requestStatus
            else
                pg.alert {title: 'Error', msg: 'An error occured'}
                console.log 'err status is', err.status

            @isLoading = false

    @goBack = ->
        nav.setRootPage 'navigator'
        console.log 'going back'

    @rejectProposedMatch = ->
        MatchResource.cancelMatch()
            .$promise.then (res) ->
                console.log 'canceled match is', res
            .catch (err) ->
                console.log 'err is', err
            .finally ->
                nav.setRootPage 'navigator'

    return