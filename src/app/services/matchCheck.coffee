qantasApp = angular.module 'qantasApp'

qantasApp.factory 'auth', ($rootScope, $window, $http, $q, storage, MatchResource) ->

    factory.matchCheck = ->

        $http.get "#{config.apiBase}/match/request"
            .$promise.then (response) ->
                console.log response
            .catch (err) ->
                console.log err

    return factory
