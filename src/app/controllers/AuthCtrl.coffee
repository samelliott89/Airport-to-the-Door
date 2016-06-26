qantasApp = angular.module 'qantasApp'

qantasApp.controller 'AuthCtrl', ($rootScope, $scope, auth, errorList, pg, nav, phoneValidationHelper) ->
    inProgress = false
    addedDummyPhonePrefix = false
    @isValidNumber = false

    window.editProfile = this

    @onPhoneNumberChange = ->
        @isValidNumber = phoneValidationHelper.isNumberValid @phone
        # TODO(SK): This is a hack to prepopulate the phone input (once) until we reevaluate a better
        # way of parsing/rendering phone numbers that doesn't rely on the horrendous phoneFormat lib
        if not @phone && not addedDummyPhonePrefix
            addedDummyPhonePrefix = true
            @phone = '+61'
        else
            @phone = phoneValidationHelper.formatPhoneNumber @phone

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
        return if inProgress
        inProgress = true

        credentials =
            given_name: @given_name
            surname: @surname
            phone_number: @phone
            phone_locale: 'AU'
            email: @email
            password: @password

        console.log 'preparing credentials', credentials

        window.registerUserModal.show()

        auth.register credentials
            .then (data) ->
                console.log 'response', data
                auth.login credentials
            .then (user) ->
                console.log 'user', user

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
