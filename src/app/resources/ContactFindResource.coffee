qantasApp = angular.module 'qantasApp'

qantasApp.factory 'ContactFindResource', ($resource, transform) ->
    $resource "#{config.apiBase}/v1/contacts/find", {},

        find:
            method: 'post'
            transformResponse: transform.response 'data'