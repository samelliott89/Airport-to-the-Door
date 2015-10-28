qantasApp = angular.module 'qantasApp'

qantasApp.factory 'analyticsSetup', ($rootScope, $timeout, auth) -> ->
    _delay = ->
        if arguments.length is 1
            ms = 500
            func = arguments[0]
        else
            [ms, func] = arguments

        $timeout func, ms

    _trackPage = (ev) ->
        pageOptions = ev.enterPage.options or {}
        eventOptions = _.omit pageOptions, ['animation', 'animator', 'onTransitionEnd', '$title']
        eventOptions = _.extend eventOptions, {
            $userId: auth.currentUser?.id or undefined,
            $userDisplayName: auth.currentUser?.displayName or undefined
            $userEmail: auth.currentUser?.email or undefined
        }

        pageName = ev.enterPage.name.split('/').pop().split('.')[0]
        pageName = pageOptions.$title or pageName
        analytics.page pageName, eventOptions

    _identify = -> ons.ready ->
        return unless auth.isAuthenticated()

        user = auth.currentUser

        if user.profilePhoto
            avatar = "#{user.profilePhoto.href}/-/scale_crop/200x200/"
        else
            avatar = "#{user.defaultPhoto}&s=200"

        userTraits = {
            id: user.id
            email: user.email
            name: user.displayName
            avatar: avatar
            isCordova: window.isCordova
            userAgent: window.navigator.userAgent
            createdAt: user.created
            description: user.bio
            connections: user.counts?.connections
            futureShifts: user.counts?.shifts
            platform: window.platform
        }

        if window.qantasAppVersion
            userTraits.appVersion = window.robbyAppVersion

        if window.device
            for key, value of window.device
                userTraits["device_#{key}"] = value

        analytics.identify user.id, userTraits

    ##
    # Run
    ##
    analytics.track 'App startup'

    # Set up page navigation
    $rootScope.$on 'login', -> _delay -> ons.ready ->
        $rootScope.appNavigator.on 'postpush', _trackPage

    # Identify user to services
    $rootScope.$on 'login', _identify
    $rootScope.$on 'register', _identify
