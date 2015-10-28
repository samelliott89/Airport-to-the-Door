qantasApp = angular.module 'qantasApp'

qantasApp.factory 'UserResource', ($resource, transform) ->
    $resource "#{config.apiBase}/v1/users/:id", {id: '@id'},

        get:
            method: 'get'
            transformResponse: transform.response 'user'

        update:
            method: 'post'
            transformResponse: transform.response 'user', {broadcast: 'shifts.user.changed'}

        getConnections:
            method: 'get'
            url: "#{config.apiBase}/v1/users/:id/friends"
            isArray: true
            transformResponse: transform.response 'users'

        getPendingConnections:
            method: 'get'
            url: "#{config.apiBase}/v1/users/:id/friends/pending"
            isArray: true
            transformResponse: transform.response 'users'