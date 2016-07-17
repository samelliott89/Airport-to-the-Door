qantasApp = angular.module 'qantasApp'

qantasApp.filter 'readableDistance', ->

    toReadableDistance = (distance) ->
        km = parseFloat(distance) / 1000
        return Math.round(km * 10) / 10 + 'km'

    return toReadableDistance
