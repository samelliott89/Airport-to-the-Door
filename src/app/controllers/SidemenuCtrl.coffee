qantasApp = angular.module 'qantasApp'

qantasApp.controller 'SidemenuCtrl', ($scope, $http, $window, nav, pg, storage, auth) ->

    @links = storage.get 'sidemenuLinks'

    $http.get config.apiBase + '/v1'
        .success (data) =>
            @links = _.filter data.links, (link) ->
                if link.enabledPlatforms is undefined
                    return true
                else
                    return window.platform in link.enabledPlatforms

            storage.set 'sidemenuLinks', @links

    @openLink = ({href}) ->
        if href[...4] is 'http'
            nav.openInAppBrowser href
        else
            $window.open href

    @logout = ->
        nav.resetTo 'flightNumberCtrl'
        auth.logout()

    @shareSheet = ->

        if window.isNativeAndroid
            msg = auth.currentUser.displayName + ' invited you to join Atum. Download the app from the Play Store.'
            link = config.androidStoreURL
        else
            msg = auth.currentUser.displayName + ' invited you to join Atum. Download the app from the App Store.'
            link = config.appleStoreURL

        pg.openShareSheet {
            msg: msg
            link: link
        }

    return