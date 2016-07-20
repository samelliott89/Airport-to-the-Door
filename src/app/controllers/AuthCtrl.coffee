qantasApp = angular.module 'qantasApp'

qantasApp.controller 'AuthCtrl', ($rootScope, $scope, auth, errorList, pg, nav, phoneValidationHelper) ->
    inProgress = false
    window.editProfile = this

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
        return if inProgress
        inProgress = true
        @errors = null

        credentials =
            email: @email
            password: @password
            # hard coded in until we find
            # a work around for this
            phone_locale: 'AU'

        window.loginUserModal.show()

        auth.login credentials
            .then ->
                nav.setRootPage 'navigator'
            .catch lolHandleErrors
            .finally ->
                inProgress = false
                window.loginUserModal.hide()

    @registerSubmit = =>
        return if inProgress
        inProgress = true

        credentials =
            given_name: @given_name
            surname: @surname
            phone_number: @phone
            phone_locale: 'AU'
            email: @email
            password: @password

        window.registerUserModal.show()

        auth.register credentials
            .then ->
                nav.setRootPage 'onboardingCtrl'
            .catch lolHandleErrors
            .finally ->
                inProgress = false
                window.registerUserModal.hide()

    @auth = auth
    @nav = nav

    return
