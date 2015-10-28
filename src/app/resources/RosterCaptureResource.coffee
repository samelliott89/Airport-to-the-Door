qantasApp = angular.module 'qantasApp'

qantasApp.factory 'RosterCaptureResource', ($resource, transform) ->
    $resource "#{config.apiBase}/v1/users/:userId/captures", {userId: '@userId'},

        save:
            method: 'post'
            transformResponse: transform.response 'capture'