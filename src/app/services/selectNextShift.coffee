qantasApp = angular.module 'qantasApp'

qantasApp.factory 'selectNextShift', (auth) -> (feed) ->

    if feed.length is 0
        return {shift: null, shiftIsCurrent: null}

    now = new Date()

    for week in feed
        for shift in week.shifts
            if shift.isDayOff or
               shift.ownerID isnt auth.currentUser.id or
               shift.end < now
                continue

            if now > shift.start and now < shift.end
                # We're in the middle of this shift now
                return {shiftIsCurrent: true, shift}

            return {shiftIsCurrent: false, shift}

    return {shift: null, shiftIsCurrent: null}