qantasApp = angular.module 'qantasApp'

qantasApp.controller 'AuthCtrl', ($rootScope, $scope, auth, errorList, pg, nav, phoneValidationHelper) ->
    inProgress = false
    window.editProfile = this

    # Prevent the side menu from appearing
    ons.ready ->
        $rootScope.slidingMenu.setSwipeable false

    if auth.isAuthenticated()
        nav.setRootPage 'navigator'

    handleErrors = (err) ->
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
                window.loginUserModal.hide()
                nav.setRootPage 'navigator'
            .catch (err) ->
                window.loginUserModal.hide()
                handleErrors err
            .finally ->
                inProgress = false

    @registerSubmit = =>
        if @password isnt @passwordConfirm
            console.log 'passwords did not match'

            # clear passwords
            @password = null
            @passwordConfirm = null
            pg.alert {title: 'Password error', msg: 'The passwords you entered did not match. Please try again.'}

        else
            console.log 'passwords matched'
            return if inProgress
            inProgress = true

            credentials =
                given_name: @given_name
                surname: @surname
                phone_number: @phone
                # hard coded in until we find
                # a work around for this
                phone_locale: 'AU'
                email: @email
                password: @password

            window.registerUserModal.show()

            auth.register credentials
                .then ->
                    window.registerUserModal.hide()
                    nav.setRootPage 'onboardingCtrl'
                .catch (err) ->
                    window.registerUserModal.hide()
                    handleErrors err
                .finally ->
                    inProgress = false

    @auth = auth
    @nav = nav

    return
