qantasApp = angular.module 'qantasApp'

qantasApp.factory 'authInterceptor', ($rootScope, $q, storage, nav) ->
    request: (req) ->

        if window.templateHashes?[req.url]
            req.url = "#{req.url}?rel=#{window.templateHashes[req.url]}"
            console.log 'req', req.url

        req.headers ?= {}
        token = storage.get 'auth_token'
        isApiCall = req.url.indexOf(config.apiBase) is 0

        if token and isApiCall
            req.headers.Authorization = token

        req

    response: (response) ->
        if response.status is 401
            # TODO: Improve error handling here
            console.error 'server has invalidated token'

        response or $q.when response

qantasApp.config ($httpProvider) ->
    $httpProvider.interceptors.push 'authInterceptor'