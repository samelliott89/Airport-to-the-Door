qantasApp = angular.module 'qantasApp'

qantasApp.factory 'GeocodeResource', ($resource) ->
    $resource "#{config.apiBase}/geocode/address/:address", {address: '@address'},

    # example API calls
    # GET: '/flights/10-11-2012/airport/syd'
    # GET with lat and long as parameters:
    #
        getLatLng:
            method: 'get'
            url: "#{config.apiBase}/geocode/address/:address"

    # returns
    # "address": "3 Denham Street" or null