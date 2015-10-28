qantasApp = angular.module 'qantasApp'

qantasApp.factory 'storage', ($window) ->
    ls = $window.localStorage

    set: (key, value) ->
        ls[key] = JSON.stringify value

    get: (key) ->
        try
            JSON.parse ls[key]
        catch
            undefined

    clearAll: -> ls.clear()

    remove: (key) ->
        ls.removeItem key