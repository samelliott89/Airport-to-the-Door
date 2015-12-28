qantasApp = angular.module 'qantasApp'

qantasApp.factory 'FlightResource', ($resource, transform) ->
    $resource "#{config.apiBase}/flights/:date", {date: '@date'},

    # example API calls
    # GET: '/flights/10-11-2012'
    # GET with a date and fligt numbers as parameters:
    #
        get:
            method: 'get'
            isArray: true
            transformResponse: transform.response 'flights'

        getForDate:
            method: 'get'
            url: "#{config.apiBase}/flights/:date/flight_number/:flight_number"
            transformResponse: transform.response 'flight'