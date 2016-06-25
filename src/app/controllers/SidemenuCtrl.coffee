qantasApp = angular.module 'qantasApp'

qantasApp.controller 'SidemenuCtrl', ($scope, $http, $window, nav, pg, auth, requestStatusCheck) ->

    requestStatusCheck.getRequest()
        .then (request) ->
            if request.status == 'NO_MATCH_FOUND'
                console.log 'request.status', request.status
                $scope.showPollingView = false
                $scope.$apply

            else
                console.log 'request.status', request.status
                $scope.showPollingView = false
                $scope.$apply

    @logout = ->
        nav.resetTo 'flightNumberCtrl'
        auth.logout()

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