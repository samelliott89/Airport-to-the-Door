window.isCordova = window.hasOwnProperty('cordova')

qantasApp = angular.module 'qantasApp', [
    'onsen'
    'ngResource'
    'ipCookie'
    'ngAnimate'
    'angularFileUpload'
    'geolocation'
    # 'ngMap'
]

# Implement fast click on the documentbody
qantasApp.run ->
    document.addEventListener 'deviceready', ->
        if 'addEventListener' of document
            document.addEventListener 'DOMContentLoaded', (->
                FastClick.attach document.body
                return
                ), false

# Hide keyboard when the window scrolls. Window should never scroll
qantasApp.run ->
    func = (ev) ->
        if window.scrollY > 0
            document.activeElement.blur()

    window.ontouchmove = _.throttle func, 100, true

# Create a global promise for when cordova plugins are ready
# and set some device-detection variables
qantasApp.run ($q, $timeout) ->
    dfd = $q.defer()
    window.$deviceReady = dfd.promise

    # These will be overridded on native devices when deviceready is fired
    if window.navigator.userAgent.match(/iPhone|iPad|iPod/)
        window.platform = 'webiOS'
    else if window.navigator.userAgent.match(/android|Android/)
        window.platform = 'webAndroid'
    else
        window.platform = 'other'

    document.addEventListener 'deviceready', (->

        window.isNativeAndroid = window.isCordova and (window.device.platform.toLowerCase() is 'android')
        window.isNativeiOS = window.isCordova and (window.device.platform.toLowerCase() is 'ios')
        window.isNativeiOSEmulator = window.device.model is 'x86_64'

        if window.isNativeAndroid
            window.platform = 'nativeAndroid'
        else if window.isNativeiOS
            window.platform = 'nativeiOS'
        else
            window.platform = 'nativeOther'

        if window.cordova.getAppVersion?
            window.cordova.getAppVersion (version) ->
                window.qantasAppVersion = version
                dfd.resolve()
        else
            dfd.resolve()
    )

# Bunch of first-run one-liners
qantasApp.run ($rootScope, $timeout, DialogView, IOSAlertDialogAnimator, prefs, analyticsSetup, templatePrefetch) ->
    # Hide necessary elements
    window.jQuery('.hide-on-first-load').css({visibility: 'visible'})

    # Enable the 'alert dialog animation' (fade in and drop down from top) for regular ons-dialogs
    DialogView.registerAnimator 'iosAlertStyle', new IOSAlertDialogAnimator()

    # Sync preferences
    # $rootScope.$on 'login', prefs.$fetch

    # Prefetch necessary templates
    $timeout templatePrefetch.run, 1000, false

# Setup some notitication things
qantasApp.run ($rootScope, localNotifications) ->
    $rootScope.isCordova = window.isCordova
    $rootScope.isNativeAndroid = window.isNativeAndroid
    $rootScope.isNativeiOSEmulator = window.isNativeiOSEmulator

    document.addEventListener 'deviceready', ->
        return unless window.cordova?.plugins?.notification?.badge?

        window.cordova.plugins.notification.badge.hasPermission (granted) ->
            return unless granted
            window.cordova.plugins.notification.badge.configure {autoClear: true}

        $rootScope.$on 'login',  -> localNotifications.syncOnShiftChanges()
        $rootScope.$on 'logout', -> localNotifications.clearAll()

qantasApp.run ($rootScope, $location, $timeout, auth, nav, matchCheck) ->
    $rootScope.nav = nav
    $rootScope.auth = auth
    $rootScope.matchCheck = matchCheck

    # Add match check here to check if
    # there is or is not a match currently
    # awaiting the user

    ons.ready ->
        auth.start()
        # Important: this controls the first page the user sees
        # If you never do this, it'll get stuck on a blank page
        if auth.isAuthenticated()
            nav.setRootPage 'navigator'
        else
            nav.setRootPage 'authCtrl'

        $rootScope.$on 'logout', (ev, currentUser) ->
            nav.setRootPage 'authCtrl'
