qantasApp = angular.module 'qantasApp'

qantasApp.factory 'auth', ($rootScope, $window, $http, $q, pg, storage, UserResource) ->
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

        $http.get "#{config.apiBase}/health/check"
            .then (status) ->
                unless status.data.message == 'Ok'
                    factory.logout()
                    return

                storage.set 'user_info', factory.currentUser

        $http.get "#{config.apiBase}/users/#{factory.currentUser.user_id}"
            .then (resp) ->
                _.extend factory.currentUser, userInfo, resp.data
                storage.set 'user_info', factory.currentUser
                $rootScope.$broadcast 'login', factory.currentUser
                return
            .catch (err) ->
                console.log 'Error communicating with server on startup'
                console.log err

                if err.status in [400, 401, 403, 404]
                    msg = 'Login details have expired. Please log in again.'
                    factory.logout()
                else
                    msg = 'Error communicating with the server. Some functionality may not be available.'

                pg.alert {msg, title: 'Oops.'}
                return

    factory.login = (credentials) ->
        dfd = $q.defer()

        postLogin = (resp) ->
            _.extend factory.currentUser, resp.data
            storage.set 'user_info', factory.currentUser
            storage.set 'auth_token', resp.data.auth_token
            dfd.resolve factory.currentUser
            $rootScope.$broadcast 'login', factory.currentUser

        $http.post "#{config.apiBase}/auth/login", credentials
            .then postLogin
            .catch dfd.reject

        return dfd.promise

    factory.register = (credentials) ->
        $http.post "#{config.apiBase}/auth/signup", credentials

    factory.logout = (preventBroadcast) ->
        storage.clearAll()
        factory.currentUser = new UserResource()
        $rootScope.$broadcast 'logout', factory.currentUser unless preventBroadcast
        return factory.currentUser

    factory.isAuthenticated = ->
        !!factory.currentUser.user_id

    return factory
