qantasApp = angular.module 'qantasApp'

qantasApp.factory 'UserResource', ($resource, transform) ->
    $resource "#{config.apiBase}/v1/users/:id", {id: '@id'},

        get:
            method: 'get'
            transformResponse: transform.response 'user'

        update:
            method: 'post'
            transformResponse: transform.response 'user', {broadcast: 'shifts.user.changed'}