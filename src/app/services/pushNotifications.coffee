qantasApp = angular.module 'qantasApp'

qantasApp.factory 'pushNotifications', ($rootScope, $q, pg, auth, storage, prefs ) ->

    class NotificationPermissionsSoftReject extends Error then constructor: -> super

    pushNotification = window.plugins?.pushNotification
    platformIsSupported = pushNotification?

    factory = {}

    _noSupport = ->
        console.warn 'Push notifications are not supported on this platform, so skipping sync.'

    factory.start = ->

        if deviceIsIOS

            _tokenHandler = (deviceToken) ->
                console.log 'Token - ', deviceToken
                prefs.$set 'deviceID', deviceToken
                prefs.$set 'deviceType', 'IOS'

                if prefs.deviceID?
                    console.log 'Device ID set for user'
                else
                    console.log 'Could not set device id'

            _errorHandler = (error) ->
                console.log 'Error - ', error

            pushNotification.register _tokenHandler, _errorHandler,
                'badge': 'true'
                'sound': 'true'
                'alert': 'true'
                'ecb': 'onNotificationAPN'

        if deviceIsAndroid

            _successHandler = (token) ->
                #Set Device ID
                prefs.$set 'deviceID', deviceToken
                prefs.$set 'deviceType', 'Android'

                #Check if deviceid is set properly
                if prefs.deviceID?
                    console.log 'Device ID set for user'
                else
                    console.log 'Could not set device id'

            _errorHandler = (error) ->
                console.log 'Error - ', error

            pushNotification.register _successHandler, _errorHandler,
                'senderID': '295549078823' # GCM Sender ID
                'ecb': 'onNotification'

    onNotificationGCM = ( notificationReceived ) ->
        switch notificationReceived.event
            when 'registered'
                if notificationReceived.regid.length > 0
                    deviceRegistered notificationReceived.regid
            when 'message'
                if notificationReceived.foreground
                    # When the app is running foreground.
                    alert notificationReceived.message
            when 'error'
                console.log 'Error: ' + notificationReceived.msg
            else
                console.log 'An unknown event was received'
                break
        return

    # Wrap each function to check if platform is supported
    _.each factory, (func, funcName) ->
        factory[funcName] = ->
            return _noSupport() unless platformIsSupported
            func arguments...


    return factory
