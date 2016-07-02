qantasApp = angular.module 'qantasApp'

qantasApp.factory 'transform', ($rootScope) ->
    response: (key, opts = {}) ->
        (raw) ->
            if opts.broadcast
                $rootScope.$broadcast opts.broadcast

            if _.isNull(key)
                return null
            else
                return angular.fromJson(raw)[key]

qantasApp.filter 'ordinal', ->
    (input) ->
        return '' unless input

        if typeof input is 'object'
            # assuming to be a date object
            input = input.getDate()

        else if ':' in input
            # assuming to be a UTC string
            input = (new Date(input)).getDate()

        ordinals = [
            'th'
            'st'
            'nd'
            'rd'
        ]

        v = parseInt(input) % 100
        ordinals[(v - 20) % 10] or ordinals[v] or ordinals[0]

qantasApp.service 'month', -> (number) ->

    month = new Array()

    month[0] = 'January'
    month[1] = 'February'
    month[2] = 'March'
    month[3] = 'April'
    month[4] = 'May'
    month[5] = 'June'
    month[6] = 'July'
    month[7] = 'August'
    month[8] = 'September'
    month[9] = 'October'
    month[10] = 'November'
    month[11] = 'December'

    monthString = month[number]

    return monthString

qantasApp.service 'errorList', -> (err) ->
    _.map err.details, (fieldError) -> fieldError.msg
