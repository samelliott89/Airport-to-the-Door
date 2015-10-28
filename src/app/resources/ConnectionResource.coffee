qantasApp = angular.module 'qantasApp'

qantasApp.factory 'ConnectionResource', ($resource, transform) ->
    $resource "#{config.apiBase}/v1/users/:userId/friends", {userId: 'userID'},

        get:
            method: 'get'
            isArray: true
            transformResponse: transform.response 'users'

        connect:
            method: 'post'
            transformResponse: transform.response null, {broadcast: 'shifts.connections.changed'}

        unconnect:
            method: 'delete'
            transformResponse: transform.response null, {broadcast: 'shifts.connections.changed'}
