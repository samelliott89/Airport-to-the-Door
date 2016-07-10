qantasApp = angular.module 'qantasApp'

qantasApp.controller 'SidemenuCtrl', ($scope, $http, $window, nav, pg, auth) ->
    @logout = ->
        nav.resetTo 'flightNumberCtrl'
        window.logoutUser.show()
        auth.logout()
        window.logoutUser.hide()

    @shareSheet = ->
        if window.isNativeAndroid
            msg = auth.currentUser.displayName + ' invited you to join Atum. Download the app from the Play Store.'
            link = config.androidStoreURL
        else if window.isNativeiOS
            msg = auth.currentUser.displayName + ' invited you to join Atum. Download the app from the App Store.'
            link = config.appleStoreURL
        else
            console.error 'This is not supported on web'

        if window.isNativeAndroid or window.isNativeiOS

            pg.openShareSheet {
                msg: msg
                link: link
            }

    return
