qantasApp = angular.module 'qantasApp'

qantasApp.filter 'readableTime', ->

    toReadableTime = (dateTimeString) ->
        momentDatetime = moment(dateTimeString, 'DD-MM-YYYY_HH-mm-ss')
        return momentDatetime.format('h:mm a')

    return toReadableTime
