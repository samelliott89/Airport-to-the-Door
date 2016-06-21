qantasApp = angular.module 'qantasApp'

qantasApp.controller 'PollingMatchCtrl', ($http, $scope, MatchResource, nav, requestStatusCheck) ->

    $scope.request = requestStatusCheck.getRequest()
    # update bindings
    $scope.$apply

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