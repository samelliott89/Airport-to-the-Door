qantasApp = angular.module 'qantasApp'

qantasApp.filter 'readableDistance', ->

    toReadableDistance = (distance) ->
        km = parseFloat(distance) / 1000

        if km is 0
            return 'nearby'
        else
            return Math.round(km * 10) / 10 + 'km'

    return toReadableDistance
