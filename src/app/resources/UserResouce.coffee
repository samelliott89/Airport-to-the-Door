qantasApp = angular.module 'qantasApp'

qantasApp.factory 'UserResource', ($resource, transform) ->
    $resource "#{config.apiBase}/users/:userId", {userId: '@userId'},

        get:
            method: 'get'
            transformResponse: transform.response 'user'

        update:
            method: 'post'
            transformResponse: transform.response 'user', {broadcast: 'shifts.user.changed'}