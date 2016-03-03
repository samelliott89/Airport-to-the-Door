qantasApp = angular.module 'qantasApp'

qantasApp.factory 'FlightResource', ($resource, transform) ->
    $resource "#{config.apiBase}/flights/:date?carrier=QFA", {date: '@date', airport: '@airport'},

    # example API calls
    # GET: '/flights/10-11-2012/airport/syd'
    # GET with a date and fligt numbers as parameters:
    #
        get:
            method: 'get'
            isArray: true
            transformResponse: transform.response 'flights'

        getForDate:
            method: 'get'
            url: "#{config.apiBase}/flights/:date/flight_number/:flight_number?carrier=QFA"
            transformResponse: transform.response 'flight'

        # gets a list of flights for a date and airport param
        getForDateAndAirport:
            method: 'get'
            url: "#{config.apiBase}/flights/:date/airport/:airport?carrier=QFA"
            isArray: true
            transformResponse: transform.response 'flights'