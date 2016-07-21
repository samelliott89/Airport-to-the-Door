qantasApp = angular.module 'qantasApp'

qantasApp.filter 'readableDistance', ->

    toReadableDistance = (distance) ->
        km = parseFloat(distance) / 1000
        truncated = Math.round(km * 10) / 10

        return Math.max(truncated, 0.1) + 'km'

    return toReadableDistance
