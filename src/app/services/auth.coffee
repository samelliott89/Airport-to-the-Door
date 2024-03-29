qantasApp = angular.module 'qantasApp'

qantasApp.factory 'auth', ($rootScope, $window, $http, $q, pg, nav, storage, UserResource) ->
    # Set some variables for this factory and create a new user
    window.pg = pg
    factory = { currentUser: new UserResource() }
    $rootScope.currentUser = factory.currentUser

    factory.hasTrait = (trait) ->
        factory.currentUser.traits?[trait] is true
    # Set some variables for this factory and create a new user
    factory.start = ->

        # Check is user has an authToken
        token = storage.get 'auth_token'

        return unless token

        userInfo = storage.get('user_info') or {}
        _.extend factory.currentUser, userInfo
        storage.set 'user_info', factory.currentUser

        $http.get "#{config.apiBase}/users/#{factory.currentUser.user_id}"
            .then (resp) ->
                _.extend factory.currentUser, userInfo, resp.data
                storage.set 'user_info', factory.currentUser

                return

            .catch (err) ->
                console.log 'Error communicating with server on startup'
                console.log err

                if err.status in [400, 401, 403, 404]

                    message = 'Login details have expired. Please log in again.'

                    factory.logout()
                else
                    message = 'Error communicating with the server. Some functionality may not be available.'

                pg.alert {title: 'Oops.', msg: message}

                return

    factory.login = (credentials) ->
        dfd = $q.defer()

        postLogin = (resp) ->
            _.extend factory.currentUser, resp.data
            storage.set 'user_info', factory.currentUser
            storage.set 'auth_token', resp.data.auth_token
            dfd.resolve factory.currentUser

        $http.post "#{config.apiBase}/auth/login", credentials
            .then postLogin
            .catch dfd.reject

        return dfd.promise

    factory.register = (credentials) ->
        dfd = $q.defer()

        postRegister = (resp) ->
            _.extend factory.currentUser, resp.data
            storage.set 'user_info', factory.currentUser
            storage.set 'auth_token', resp.data.auth_token
            dfd.resolve factory.currentUser

        $http.post "#{config.apiBase}/auth/signup", credentials
            .then postRegister
            .catch dfd.reject

        return dfd.promise

    factory.logout = ->
        storage.clearAll()
        factory.currentUser = new UserResource()
        nav.setRootPage 'authCtrl'

    factory.isAuthenticated = ->
        !!factory.currentUser.user_id

    return factory
