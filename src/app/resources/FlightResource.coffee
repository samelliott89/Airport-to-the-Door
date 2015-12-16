qantasApp = angular.module 'qantasApp'

qantasApp.factory 'FlightResource', ($resource, transform) ->
    $resource "#{config.apiBase}/flights/:date", {date: '@date'},

        get:
            method: 'get'
            isArray: true
            transformResponse: transform.response 'flights'

        getForDate:
            method: 'get'
            url: "#{config.apiBase}/flights/:date/flight_number/:flight_number"
            transformResponse: transform.response 'flight'