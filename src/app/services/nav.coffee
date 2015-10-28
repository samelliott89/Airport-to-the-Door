qantasApp = angular.module 'qantasApp'

qantasApp.factory 'nav', ($rootScope, $timeout, $window) ->

    forceMenuButton = false

    titles =
        'profileCtrl': 'Profile'
        'feedCtrl': 'Shifts'
        'settingsCtrl': 'Settings'
        'searchCtrl': 'Search'

    _moveTo = (funcName, [page, options]) ->
        template = "templates/#{page}.html"
        options ?= {}

        options.$title = titles[page]

        ons.ready ->
            $rootScope.appNavigator[funcName] template, options
            $rootScope.slidingMenu.close()

    _isFirstPage = ->
        pages = $rootScope.appNavigator.getPages()

        if forceMenuButton
            return true

        if pages.length is 1
            return true
        else
            return false

    _checkSwipableMenu = ->
        if _isFirstPage()
            $rootScope.slidingMenu.setSwipeable true
        else
            $rootScope.slidingMenu.setSwipeable false

    _replacePrevPage = (page) ->
        pages = $rootScope.appNavigator.getPages()
        index = pages.length - 2
        if index < 0
            return
        $rootScope.appNavigator.insertPage index, page
        pages.splice index, 1

    # We only want to swipe to reveal sidebar on the 'root' pages
    # Listen to navigation changes
    $rootScope.$on 'login', (ev, currentUser) ->
        _do = -> ons.ready ->
            unless $rootScope.appNavigator
                return $timeout _do, 1000

            $rootScope.appNavigator.on 'postpush', _checkSwipableMenu
            $rootScope.appNavigator.on 'postpop', _checkSwipableMenu

        $timeout _do, 500

    openInAppBrowser: (url) ->
        $window.open url, '_blank', 'location=no,closebuttoncaption=Close,toolbarposition=top'

    resetTo: ->
        forceMenuButton = true

        $rootScope.appNavigator.once 'postpush', -> forceMenuButton = false
        $rootScope.appNavigator.once 'postpop', -> forceMenuButton = false

        _moveTo 'resetToPage', arguments

    goto: ->
        _moveTo 'pushPage', arguments

    setRootPage: (page) ->
        template = "templates/#{page}.html"

        ons.ready ->
            $rootScope.slidingMenu.setMainPage template

    getParams: (key) ->
        page = $rootScope.appNavigator.getCurrentPage()

        if key
            return page.options[key]
        else
            return page.options

    back: (page) ->
        ons.ready -> $rootScope.appNavigator.popPage()

    isFirstPage: _isFirstPage

    toggleMenu: ->
        ons.ready -> $rootScope.slidingMenu.toggle()

    getBackButtonTitle: ->
        pages = $rootScope.appNavigator.getPages()

        unless pages.length > 1
            return undefined

        previousPage = pages[pages.length - 2]
        pageNameRegex = /templates\/(.+).html/
        pageName = previousPage.page.match(pageNameRegex)[1]

        return titles[pageName] or 'Back'