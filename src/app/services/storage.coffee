qantasApp = angular.module 'qantasApp'

qantasApp.factory 'storage', ($window) ->
    ls = $window.localStorage

    set: (key, value) ->
        ls[key] = JSON.stringify value

    get: (key) ->
        try
            JSON.parse ls[key]
        catch
            undefined

    clearAll: -> ls.clear()

    clearFlightData: ->
        keysToClear = ['flightObj', 'minutesBefore', 'listOfFlights', 'flightDate', 'flightNumber', 'rideCount']
        for key in keysToClear
            try
                ls.removeItem key
            catch
                undefined

    remove: (key) ->
        ls.removeItem key
