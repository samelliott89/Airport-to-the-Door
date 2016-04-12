qantasApp = angular.module 'qantasApp'

qantasApp.factory 'ReverseGeocodeResource', ($resource, transform) ->
    $resource "#{config.apiBase}/geocode/reverse/latitude/:latitude/longitude/:longitude", {latitude: '@latitude', longitude: '@longitude'},

    # example API calls
    # GET: '/flights/10-11-2012/airport/syd'
    # GET with lat and long as parameters:
    #
        get:
            method: 'get'

    # returns
    # "address": "3 Denham Street" or null