qantasApp = angular.module 'qantasApp'

qantasApp.factory 'auth', ($rootScope, $window, $http, $q, pg, storage, UserResource) ->
    window.pg = pg
    factory = { currentUser: new UserResource() }
    $rootScope.currentUser = factory.currentUser

    factory.hasTrait = (trait) ->
        factory.currentUser.traits?[trait] is true

    factory.start = ->
        token = storage.get 'authToken'
        return unless token

        userInfo = storage.get('userInfo') or {}
        _.extend factory.currentUser, userInfo

        $http.get "#{config.apiBase}/api"
            .then (resp) ->
                unless resp.data.isAuthenticated
                    factory.logout()
                    return

                _.extend factory.currentUser, userInfo, resp.data.user
                storage.set 'userInfo', factory.currentUser

                $http.get "#{config.apiBase}/v1/users/#{factory.currentUser.id}"
            .then (resp) ->
                _.extend factory.currentUser, userInfo, resp.data.user
                storage.set 'userInfo', factory.currentUser
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
            _.extend factory.currentUser, resp.data.user
            storage.set 'userInfo', factory.currentUser
            storage.set 'authToken', resp.data.token
            dfd.resolve factory.currentUser
            $rootScope.$broadcast 'login', factory.currentUser

        $http.post "#{config.apiBase}/v1/auth/login", credentials
            .then postLogin
            .catch dfd.reject

        return dfd.promise

    factory.register = (credentials) ->
        $http.post "#{config.apiBase}/v1/auth/register", credentials

    factory.logout = (preventBroadcast) ->
        storage.clearAll()
        factory.currentUser = new UserResource()
        $rootScope.$broadcast 'logout', factory.currentUser  unless preventBroadcast
        return factory.currentUser

    factory.isAuthenticated = ->
        !!factory.currentUser.id

    return factory
