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

qantasApp.service 'errorList', -> (err) ->
    _.map err.details, (fieldError) -> fieldError.msg
