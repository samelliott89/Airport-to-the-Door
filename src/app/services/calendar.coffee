qantasApp = angular.module 'qantasApp'

qantasApp.factory 'calendar', ($http, $q, $rootScope, auth, prefs, pg, ShiftResource, formatFeed) ->

    cal = window.plugins?.calendar
    platformIsSupported = cal?
    factory = {}

    document.addEventListener 'deviceready', ->
        cal = window.plugins?.calendar
        platformIsSupported = cal?

    _unicodeEscape = (str) ->
        str.replace /[\s\S]/g, (character) ->
            escape = character.charCodeAt().toString(16)
            longhand = escape.length > 2
            '\\' + (if longhand then 'u' else 'x') + ('0000' + escape).slice(if longhand then -4 else -2)

    _noSupport = ->
        console.warn 'Calendar is not supported on this platform, so skipping sync.'

    _success = (msg) ->
        console.log 'Calendar success: ' + JSON.stringify(msg)

    _error = (msg) ->
        console.log 'Calendar error: ' + JSON.stringify(msg)

    window.onerror = (msg, file, line) ->
        console.log msg + '; ' + file + '; ' + line

    _fetchShifts = ->
        $http.get "#{config.apiBase}/v1/users/#{auth.currentUser.id}/feed"
            .then ({data}) ->
                feed = formatFeed data
                shifts = _.chain feed
                    .map _.iteratee 'shifts'
                    .flatten()
                    .reject _.iteratee 'isDayOff'
                    .value()
                factory.saveEntries shifts

    _fixDate = (dateString) ->
        return dateString.replace /-/g, '/'


    _difference = (shiftsServer, shiftsCalendar) ->

        shitsOnlyInServer = shiftsServer.filter((server) ->
            return shiftsCalendar.filter((calendar) ->

                # Make sure that both the entries have the same typeof datestring before comparison
                calendarStart = new Date(_fixDate(calendar.startDate)).toISOString()
                calendarEnd = new Date(_fixDate(calendar.endDate)).toISOString()

                serverStart = new Date(server.start).toISOString()
                serverEnd = new Date(server.end).toISOString()

                return calendarStart == serverStart and calendarEnd == serverEnd

                ).length == 0
            )


        return shitsOnlyInServer

    factory.changeCalendar = (oldCalendarName, oldEventTitle) ->

        calendarName = oldCalendarName or 'Work Calendar'
        eventName = oldEventTitle or 'Work Shift'

        pg.confirm {
            title: 'Changing Calendars'
            msg: 'Would you like to remove all your shifts from the old calendar?'
            buttons: {
                'Yes': ->
                    factory.clearCalendar(calendarName, eventName).then (->
                        #factory.addShiftsToCalendar()
                        console.log 'Calendar Cleared!'
                        ),(err) ->
                        console.log err
                        #factory.addShiftsToCalendar()
                'No thanks': ->
                    factory.addShiftsToCalendar()
            }
        }


    factory.clearCalendar = (calendarName, eventTitle) ->
        dfd = $q.defer()

        calendarOptions = {}
        calendarOptions.calendarName = calendarName

        loc = 'Work'
        notes = 'Created By Atum'

        startDate = new Date
        endDate = new Date

        startDate.setDate startDate.getDate() - 712
        endDate.setDate endDate.getDate() + 712

        _findSuccess = (events) ->
            console.log events
            eventIndex = 0
            _removeSequentially = (events) ->
                console.log eventIndex
                console.log calendarName + ' - ' + eventTitle
                factory.removeEntryFromCalendarNamed(events[eventIndex], calendarName, eventTitle).then ((msg) ->
                    eventIndex = eventIndex + 1
                    if eventIndex < events.length
                        _removeSequentially events
                    ), (err) ->
                    console.log err
            _removeSequentially events
            dfd.resolve()

        _findError = (err) ->
            dfd.reject err

        if deviceIsIOS
            cal.findEventWithOptions eventTitle, loc, notes, startDate, endDate, calendarOptions, _findSuccess, _findError

        if deviceIsAndroid
            cal.findEvent eventTitle, loc, notes, startDate, endDate, _findSuccess, _findError

        return dfd.promise


    factory.syncEvents = ->

        # Get all shift events from user's calendar
        # Get all shift events from server
        # Check for new events
        # Add new events from server onto the user's calendar

        calendarOptions = {}
        eventTitle = prefs.calendarTitle or 'Work Shift'
        calendarOptions.calendarName = prefs.calendarName or 'Work Calendar'

        loc = 'Work'
        notes = 'Created By Atum'

        startDate = new Date
        endDate = new Date

        endDate.setDate endDate.getDate() + 712

        _findSuccess = (events) ->
            calendarEvents = events
            $http.get "#{config.apiBase}/v1/users/#{auth.currentUser.id}/feed"
                .then ({data}) ->
                    feed = formatFeed data
                    shifts = _.chain feed
                        .map _.iteratee 'shifts'
                        .flatten()
                        .reject _.iteratee 'isDayOff'
                        .value()
                    serverShifts = shifts

                    if serverShifts.length > 0
                        # Checks to see if server shifts have entries in the users calendar
                        # and adds entries of shits on the server that are not in the users calendar

                        shiftsNotInCalendar = _difference serverShifts, calendarEvents

                        if shiftsNotInCalendar.length > 0
                            factory.saveEntries shiftsNotInCalendar



        _findError = (err) ->
            # Events not found in calendar
            if prefs.calendarSync
                factory.addShiftsToCalendar()

        if deviceIsIOS
            cal.findEventWithOptions eventTitle, loc, notes, startDate, endDate, calendarOptions, _findSuccess, _findError

        if deviceIsAndroid
            cal.findEvent eventTitle, loc, notes, startDate, endDate, _findSuccess, _findError



    factory.saveEvent = (event) ->
        dfd = $q.defer()
        calendarOptions = {}
        eventTitle = prefs.calendarTitle or 'Work Shift'
        calendarOptions.calendarName = prefs.calendarName or 'Work Calendar'

        loc = 'Work'
        notes = 'Created By Atum'

        startDate = new Date _fixDate(event.startDate)
        endDate = new Date _fixDate(event.endDate)

        _createSuccess = (msg) ->
            dfd.resolve JSON.stringify(msg)

        _createError = (msg) ->
            dfd.reject JSON.stringify(msg)

        if deviceIsIOS
            cal.createEventWithOptions eventTitle, loc, notes, starDate, endDate, calendarOptions, _createSuccess, _createError

        if deviceIsAndroid
            cal.createEvent eventTitle, loc, notes, starDate, endDate, _createSuccess, _createError

        return dfd.promise

    factory.removeEntryFromCalendarNamed = (event, calendarName, eventTitle) ->
        dfd = $q.defer()

        calendarOptions = {}
        calendarOptions.calendarName = calendarName

        loc = 'Work'
        notes = 'Created By Atum'

        startDate = new Date _fixDate(event.startDate)
        endDate = new Date _fixDate(event.endDate)

        _removeSuccess = (msg) ->
            dfd.resolve JSON.stringify(msg)

        _removeError = (msg) ->
            dfd.reject JSON.stringify(msg)

        if deviceIsIOS
            cal.deleteEventFromNamedCalendar eventTitle, loc, notes, startDate, endDate, calendarName, _removeSuccess, _removeError

        if deviceIsAndroid
            cal.deleteEvent eventTitle, loc, notes, startDate, endDate, _removeSuccess, _removeError

        return dfd.promise

    factory.removeEntry = (shift) ->
        dfd = $q.defer()

        calendarOptions = {}
        eventTitle = prefs.calendarTitle or 'Work Shift'
        calendarOptions.calendarName = prefs.calendarName or 'Work Calendar'

        loc = 'Work'
        notes = 'Created By Atum'


        starDate = new Date shift.start
        endDate = new Date shift.end

        _removeSuccess = (msg) ->
            dfd.resolve JSON.stringify(msg)

        _removeError = (msg) ->
            dfd.reject JSON.stringify(msg)

        if deviceIsIOS
            cal.deleteEventFromNamedCalendar eventTitle, loc, notes, starDate, endDate, calendarOptions.calendarName, _removeSuccess, _removeError

        if deviceIsAndroid
            cal.deleteEvent eventTitle, loc, notes, starDate, endDate, _removeSuccess, _removeError

        return dfd.promise

    factory.saveEntries = (shifts) ->
        shiftIndex = 0
        _addSequentially = (shifts) ->
            factory.saveEntry(shifts[shiftIndex]).then ((msg) ->
                shiftIndex = shiftIndex + 1
                if shiftIndex < shifts.length
                    _addSequentially shifts
                ), (err) ->
                console.log err
        _addSequentially shifts

    factory.saveEntry = (shift) ->

        dfd = $q.defer()

        calendarOptions = {}
        eventTitle = prefs.calendarTitle or 'Work Shift'
        calendarOptions.calendarName = prefs.calendarName or 'Work Calendar'

        loc = 'Work'
        notes = 'Created By Atum'

        starDate = new Date shift.start
        endDate = new Date shift.end

        _createSuccess = (msg) ->
            dfd.resolve JSON.stringify(msg)

        _createError = (msg) ->
            dfd.reject JSON.stringify(msg)


        if deviceIsIOS
            cal.createEventWithOptions eventTitle, loc, notes, starDate, endDate, calendarOptions, _createSuccess, _createError

        if deviceIsAndroid
            cal.createEvent eventTitle, loc, notes, starDate, endDate, _createSuccess, _createError

        return dfd.promise

    factory.addShiftsToCalendar = ->
        _fetchShifts()

    #Wrap each function to check if platform is supported
    _.each factory, (func, funcName) ->
        return unless _.isFunction func

        factory[funcName] = ->
            return _noSupport() unless platformIsSupported
            func arguments...

    return factory
