qantasApp = angular.module 'qantasApp'

qantasApp.factory 'SearchResource', ($resource, transform) ->
    $resource "#{config.apiBase}/v1/search", {},

        searchUsers:
            method: 'get'
            url: "#{config.apiBase}/v1/search/users"
            isArray: true
            transformResponse: transform.response 'results'