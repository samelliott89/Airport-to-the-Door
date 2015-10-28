qantasApp = angular.module 'qantasApp'

qantasApp.controller 'ResetPasswordCtrl', ($http, $rootScope, $scope, pg, nav) ->

    @resetPass = ->
        $http.post "#{config.apiBase}/v1/requestPasswordReset", {email: @email}
            .then ->
                pg.alert {msg: 'You will be sent an email with instructions on how to reset your password.', title: 'Password Reset'}
            .catch (err) ->
                pg.alert {msg: 'An error occured'}
            .finally ->
                nav.setRootPage('authCtrl')

    return