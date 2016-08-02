qantasApp = angular.module 'qantasApp'

qantasApp.controller 'SidemenuCtrl', ($scope, $http, $window, nav, pg, auth) ->

    @logout = ->
        nav.resetTo 'flightNumberCtrl'

    return
