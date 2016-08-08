qantasApp = angular.module 'qantasApp'

qantasApp.controller 'ResetPasswordCtrl', ($http, pg, nav) ->

    @resetPassword = ->
        creds =
            phone_number: @phone
            # hard coded in until we find
            # a work around for this
            phone_locale: 'AU'
        $http.post "#{config.apiBase}/auth/resetpassword", creds
            .then (resp) ->
                pg.alert {msg: 'You will be sent a new password via text. Use it to log in and update your password.', title: 'Password Reset'}
            .catch (err) ->
                pg.alert {msg: 'An error occured'}
            .finally ->
                nav.setRootPage('authCtrl')

    return
