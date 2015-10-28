qantasApp = angular.module 'qantasApp'

qantasApp.factory 'duration', -> ->
    shift = {}
    mutate = false

    # The arguments you can supply to this is pretty flexible. Supply either
    # a shift object as the one and only argument, or start and end times
    # as two seperate arguments
    switch arguments.length
        when 1
            shift = {start, end} = arguments[0]
        when 3
            shift = {start, end} = arguments[0]
            mutate = true
        when 2
            [start, end] = arguments
        else
            throw new Error 'Incorrect number of arguments'

    dur = moment.duration moment(end) - moment(start)
    durationPieces = []

    if dur.hours() == 1
        durationPieces.push '1 hour'
    else if dur.hours() > 1
        durationPieces.push "#{dur.hours()} hours"

    if dur.minutes() == 1
        durationPieces.push '1 minute'
    else if dur.minutes() > 1
        durationPieces.push "#{dur.minutes()} minutes"

    duration = durationPieces.join ', '
    if mutate
        shift.duration = duration
    return duration



