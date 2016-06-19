qantasApp = angular.module 'qantasApp'

makeDay = (dayNumber, lol, lol2, absDate, day) ->
    unless day
        day = new Date
        day.setSeconds 0
        day.setMilliseconds 0
        absDate ?= day.getDate() + dayNumber
        day.setDate absDate

    {
        day,
        start: {keys: [], period: 'am'}
        end: {keys: [], period: 'pm'}
    }

makeHourFromDate = (date) ->
    hours = date.getHours()
    period = 'am'

    if hours >= 12
        period = 'pm'

    if hours > 12
        hours = hours - 12

    minutes = date.getMinutes().toString()
    minLength = 2
    if minutes.length < minLength
        toPad = minLength - minutes.length
        padding = Array(toPad + 1).join('0')
        minutes = padding + minutes

    keys = (hours.toString() + minutes).split('')

    return {keys, period}

makeSchedule = (days) ->
    [0...days].map makeDay

makeHour = (hour, period) ->
    parsedHour = parseInt(hour) or 0
    if parsedHour is 12 and period is 'am'
        parsedHour = 0
    else if parsedHour is 12 and period is 'pm'
        parsedHour = 12
    else
        parsedHour += 12 if period is 'pm'
    return parsedHour

# Convert a 'schedule day' (item from @schedule) into a time and set
# it onto a date object
setTimeForDateObject = (date, timeObj) ->
    keys = timeObj.keys.slice()
    minutes = keys[(keys.length - 2)...].join('')
    hours = keys[...(keys.length - 2)].join('') or '0'
    date.setHours makeHour hours, timeObj.period
    date.setMinutes parseInt(minutes) or 0
    return date

setDayValidity = (day) ->

    if not hasShift day
        day.isValid = undefined
        return undefined

    times = ['start', 'end']
    isValid = true

    for timeKey in times
        time = day[timeKey]
        keys = time.keys
        hours = keys[...(keys.length - 2)].join('') or '0'
        minutes = keys[(keys.length - 2)...].join('')

        if (hours > 12) or (minutes >= 60)
            time.isValid = false
            isValid = false  if isValid
        else
            time.isValid = true

    day.isValid = isValid
    return isValid

getLastNItems = (arr, n) -> arr.slice(Math.max(arr.length - n, 1))

createDateObject = (day) ->
    setDayValidity day

    start = new Date day.day
    end = new Date day.day

    setTimeForDateObject start, day.start
    setTimeForDateObject end, day.end

    if start.getTime() > end.getTime()
        end.setDate end.getDate() + 1

    return {start, end, id: day.id}

isSameDay = (date1, date2) ->
    date1.getDate() is date2.getDate() and
      date1.getMonth() is date2.getMonth() and
      date1.getFullYear() is date2.getFullYear()

hasShift = (day) ->
    # return true if start or end hour is truthy
    day.start.keys.length and day.end.keys.length

_pluralize = (num, string, suffix = 's') ->
    output = "#{num} #{string}"

    if num isnt 1
        output += suffix

    return output

###
# DATE OF FLIGHT CONTROLLER BEGINS
###

qantasApp.controller 'DateOfFlightCtrl', ($rootScope, $http, auth, nav, prefs, storage, FlightResource) ->

    @selectDay = (index) =>
        # todo: ensure selected day in week is in view
        @selectedDayIndex = index
        @selectedDay = @schedule[index]
        storage.set 'flight_date', @selectedDay
        @selectedField = 'start'
        @justChangedField = true

    @selectShiftField = (field) =>
        @selectedField = field
        @justChangedField = true

    @incrementSelectedDay = =>
        # If there's not another day, add another one!
        newDayIndex = @selectedDayIndex + 1
        unless @schedule[newDayIndex]
            lastDay = @schedule[@schedule.length - 1]
            newDay = new Date lastDay.day
            newDay.setDate newDay.getDate() + 1
            @schedule.push makeDay null, null, null, null, newDay

        @selectDay newDayIndex

    handleDigitPressed = (key, willResetTime) =>
        field = @selectedDay[@selectedField]

        if willResetTime
            field.keys = [key]
        else if field.keys?.length < 4
            field.keys.push key
        else
            selectNextPeriod()
            handleDigitPressed key

    selectNextPeriod = =>
        # Move onto the next field, whether it is the end time or the next day
        if @selectedField is 'start'
            @selectShiftField 'end'
        else
            @incrementSelectedDay()

    addPeriod = (period) =>
        field = @selectedDay[@selectedField]

        # First, set the period for the current time
        field.period = period

        # Then, if less than 3 chars have been entered into the time, we assume
        # They've just entered the hour, so we append 00 for the minutes to the time
        targetLength = 3
        paddBy = 0
        if field.keys.length < targetLength
            field.keys = field.keys.concat ['0', '0']

        selectNextPeriod()

    @keypadClick = (key) =>
        field = @selectedDay[@selectedField]
        @willResetTime = @justChangedField
        @justChangedField = false

        switch key
            when 'next'
                @incrementSelectedDay()

            when 'am', 'pm'
                addPeriod key

            when 'clear'
                field.keys = []
                field.isValid = undefined
                field.period = if @selectedField is 'start' then 'am' else 'pm'
            else
                handleDigitPressed key, @willResetTime

        setDayValidity @selectedDay

    @exit = ->
        numOfShfits = @numberOfShifts()

        _close = ->
            eventName = if @shiftToEdit? then 'Edit' else 'Add'
            nav.back()

        unless numOfShfits > 0
            _close()
            return

        pg.confirm {
            title: 'You have unsaved shifts'
            msg: 'Are you sure you want to leave?'
            buttons: {
                'Yes': _close
                'Cancel': ->
            }
        }

    @printDuration = (day) ->
        unless hasShift day
            return

        {start, end} = createDateObject day
        start = moment start
        end = moment end
        dur = moment.duration(end.diff(start))._data

        output = []

        if dur.hours
            output.push _pluralize dur.hours, 'hour'

        if dur.minutes
            output.push _pluralize dur.minutes, 'minute'

        join = ', '

        if output.length > 1
            last = output.length - 1
            output[last] = '##' + output[last]

        outputString = output.join join
        outputString = outputString.replace join + '##', ' and '
        return outputString

    @saveShifts = ->
        for day in @schedule when hasShift day
            unless (day.isValid is true) or (day.start.isValid is true) or (day.end.isValid is true)
                pg.alert {msg: 'Please fix invalid shifts. Days must have valid 12 hour times.', title: 'Invalid Shifts'}
                return

        window.addShiftsModal.show()

        shiftsToSave = @schedule
            .filter hasShift
            .map createDateObject

        eventName = if @shiftToEdit? then 'Edit' else 'Add'

    @findFlights = ->
        window.findingFlightsModal.show()
        # get the selected day from local storage
        selectedDate = storage.get 'flight_date'
        # set the day key from selectedDate object
        selectedDay = selectedDate.day
        # format date for API
        formatDay = moment(selectedDay).format('DD-MM-YYYY')
        newFormatDay = moment(selectedDay).format('MMMM Do YYYY, h:mm:ss a')
        # set default Airport for API
        airport = 'SYD'
        $('.flight-list').addClass('animated fadeInDown')
        # call resource and pass parameters
        FlightResource.getForDateAndAirport {date: formatDay, airport: airport}
            .$promise.then (flights) ->
                # set list of flights into local storage
                storage.set 'listOfFlights', flights
            .catch (err) ->
                alert 'An error has occured', err
            .finally ->
                window.findingFlightsModal.hide()
                # go to list of flights
                nav.goto 'listOfFlightsCtrl'

    @back = ->
        nav.back()

    # On run
    @isEditing = false

    if @shiftToEdit?
        @isEditing = true
        @shiftToEdit = JSON.parse(JSON.stringify(@shiftToEdit))
        for field in ['start', 'end']
            @shiftToEdit[field] = new Date @shiftToEdit[field]

        day = new Date @shiftToEdit.start
        day.setHours 0
        day.setSeconds 0
        day.setMilliseconds 0

        @schedule = [{
            day,
            start: makeHourFromDate @shiftToEdit.start
            end: makeHourFromDate @shiftToEdit.end
            id: @shiftToEdit.id
        }]
        setDayValidity @schedule[0]
    else
        @schedule = makeSchedule 60

    @selectDay 0

    return