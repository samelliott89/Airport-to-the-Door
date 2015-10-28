qantasApp = angular.module 'qantasApp'

qantasApp.factory 'ShiftResource', ($resource, transform) ->
    $resource "#{config.apiBase}/v1/shifts/:id", {id: '@id', userId: '@ownerId'},

        get:
            method: 'get'
            transformResponse: transform.response 'shift'

        delete:
            method: 'delete'
            transformResponse: transform.response null, {broadcast: 'shifts.shifts.changed'}

        getForUser:
            method: 'get'
            url: "#{config.apiBase}/v1/users/:userId/shifts"
            isArray: true
            transformResponse: transform.response 'shifts'