qantasApp = angular.module 'qantasApp'

qantasApp.factory 'prefs', ($rootScope, $http, auth, storage) ->
    LS_KEY = 'shiftsPrefs'
    CHANGED_EVENT_NAME = 'shifts.prefs.changed'

    factory = JSON.parse(storage.get(LS_KEY) or '{}')

    handleSettingsResponse = (resp) ->
        unless resp.status is 200
            console.error 'Unexpected response code'
            console.log resp
            return

        _.extend factory, resp.data.settings
        $rootScope.$broadcast CHANGED_EVENT_NAME
        factory.$updateLocalStorage()

    handleSettingsResponseError = (resp) ->
        console.log 'settings http error:'
        console.log resp

    factory.$fetch = ->
        $http.get "#{config.apiBase}/v1/users/#{auth.currentUser.id}/settings"
            .then handleSettingsResponse
            .catch handleSettingsResponseError

    factory.$updateLocalStorage = ->
        storage.set LS_KEY, JSON.stringify(factory)

    factory.$sync = ->
        factory.$updateLocalStorage()
        $http.post "#{config.apiBase}/v1/users/#{auth.currentUser.id}/settings", factory
            .then handleSettingsResponse
            .catch handleSettingsResponseError

    factory.$set = ->

        if arguments.length is 1
            [newOptions] = arguments
            _.extend factory, newOptions
        else
            [key, value] = arguments
            factory[key] = value

        $rootScope.$broadcast CHANGED_EVENT_NAME
        factory.$sync()

    return factory