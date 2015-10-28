qantasApp = angular.module 'qantasApp'

qantasApp.controller 'AuthCtrl', ($rootScope, $scope, auth, errorList, pg, nav) ->
    inProgress = false

    # Prevent the side menu from appearing
    ons.ready ->
        $rootScope.slidingMenu.setSwipeable false

    if auth.isAuthenticated()
        nav.setRootPage 'navigator'

    lolHandleErrors = (err) ->
        error = (err?.data) or {}
        title = 'Oops'
        messages = ['Unknown error occured - Please try again later.']

        switch error.error
            when 'ValidationFailed'
                title = 'Could not register'
                messages = errorList error
            when 'AuthFailed'
                title = 'Could not log in'
                messages = errorList error
            else
                if error.message
                    messages = [error.message]

        message = messages.join '\n'
        pg.alert {title: title, msg: message}

    @loginSubmit = =>
        return   if inProgress
        inProgress = true
        @errors = null

        credentials =
            email: @email
            password: @password

        window.loginUserModal.show()

        auth.login credentials
            .then (user) ->
                setTimeout (->
                    analytics.track 'App Login'
                ), 1000

                nav.setRootPage 'navigator'
            .finally ->
                inProgress = false
                window.loginUserModal.hide()
            .catch lolHandleErrors

    @registerSubmit = =>
        return   if inProgress
        inProgress = true

        credentials =
            email: @email
            displayName: @displayName
            password: @password

        window.registerUserModal.show()

        auth.register credentials
            .then (data) ->
                auth.login credentials
            .then (user) ->

                setTimeout (->
                    analytics.track 'App Register'
                ), 1000

                $rootScope.$broadcast 'register'
                nav.setRootPage 'navigator'
            .finally ->
                inProgress = false
                window.registerUserModal.hide()
            .catch lolHandleErrors

    @auth = auth
    @nav = nav

    return
