qantasApp = angular.module 'qantasApp'

qantasApp.controller 'UpdatePasswordCtrl', ($scope, $http, auth, pg, nav, UserResource) ->

    profileId = auth.currentUser.id

    @updatePass = ->
        unless @newPassword is @newPassword2
            pg.alert {msg: 'The passwords do not match, please try again.'}
            return

        $http.post "#{config.apiBase}/v1/users/#{profileId}/changePassword", {oldPassword: @oldPassword, newPassword: @newPassword}
            .then (resp) ->
                pg.alert {msg: 'Your password has been reset.', title: 'Password Update'}
            .then ->
                nav.back('profileCtrl')
            .catch (err) ->
                pg.alert {msg: 'The password you provided was incorrect', err, title: 'Wrong password'}

    return