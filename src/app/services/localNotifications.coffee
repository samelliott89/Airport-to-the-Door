qantasApp = angular.module 'qantasApp'

window._startTime = -> setInterval(( -> console.log new Date), 1000)

qantasApp.factory 'localNotifications', ($rootScope, $q, pg, auth, storage, prefs, ShiftResource) ->

    class NotificationPermissionsSoftReject extends Error then constructor: -> super

    pgNotification = window.plugin?.notification
    platformIsSupported = pgNotification?.local
    LOCAL_STORAGE_KEY = 'localNotifications'
    LOCAL_SHIFT_REMINDER_STORAGE_KEY = 'shiftRemindNoti'
    SHIFT_REMINDER_MINUTES_DEFAULT = 120
    SHIFT_REMINDER_DELAY = config.defaultShiftReminderTime
    shiftRemindNoti = {}
    lastFetchedShifts = []
    skipFirstPrefChange = true

    document.addEventListener 'deviceready', ->
        pgNotification = window.plugin?.notification
        platformIsSupported = pgNotification?.local

        if platformIsSupported
            pgNotification.local.oncancelall = ->

    factory = {}

    _noSupport = ->
        console.warn 'Local notifications are not supported on this platform, so skipping sync.'

    _makeNotificationID = (shift) ->
        start = parseInt(new Date(shift.start).getTime() / 10000)
        rand = Math.floor(Math.random() * 1000) + 1
        parseInt(start + rand)

    _makeNotificationIDForShiftReminder = (scheduleDate) ->
        start = parseInt(new Date(scheduleDate).getTime() / 10000)
        rand = Math.floor(Math.random() * 1000) + 1
        parseInt(start + rand)

    _makeSingleNotification = (shift) ->
        minutesBefore = parseInt(prefs.shiftReminderMinutes or SHIFT_REMINDER_MINUTES_DEFAULT)
        scheduledTime = new Date(shift.start)
        scheduledTime.setMinutes(scheduledTime.getMinutes() - minutesBefore)

        # Skip if in the past
        if scheduledTime < Date.now()
            return

        shift = _.omit shift, 'coworkers'
        start = moment(shift.start).format('h:mm A')
        end = moment(shift.end).format('h:mm A')

        if minutesBefore <= 90
            timeUntil = "#{minutesBefore} minutes"
        else
            timeUntil = "#{minutesBefore / 60} hours"

        newNoti = {
            id: _makeNotificationID shift
            title: "Your shift starts in #{timeUntil}."
            text: "You work today from #{start} to #{end}"
            at: scheduledTime
            data: {id: shift.id}
            badge: 0
        }

        return newNoti

    _fetchShiftsAndSyncNotifications = ->
        ShiftResource.getForUser {userId: auth.currentUser.id}
            .$promise.then (shifts) ->
                factory.syncShifts shifts

    _defineLastShift = (shifts) ->

        if shifts?.length
            lastShiftInArray = shifts[shifts.length - 1]
            endOfShift = new Date(lastShiftInArray.start)
            remindShiftScheduleTime = endOfShift.setMinutes(endOfShift.getMinutes() + SHIFT_REMINDER_DELAY)
            finalScheduleDate = new Date(remindShiftScheduleTime)
            _makeShiftReminderNotification finalScheduleDate

    _makeShiftReminderNotification = (scheduleDate) ->

        # check for permission
        factory.checkPermissions()
            .then ->
                #create notification object
                shiftRemindNoti = {
                    id: _makeNotificationIDForShiftReminder scheduleDate
                    title: 'You haven\'t addded your schedule in a while.'
                    text: 'Just a friendly reminder to do so.'
                    at: scheduleDate
                    badge: 0
                }

                factory.addSingleReminder shiftRemindNoti
                console.log 'shiftRemindNoti', shiftRemindNoti

            return shiftRemindNoti

    factory.softAskForPermissions = ->
        dfd = $q.defer()

        pg.confirm {
            title: 'Enable shift reminders?'
            msg: 'Atum can set notifications to remind you of upcomming shifts.\n\nThis can be changed later in Settings.'
            buttons: {
                'Enable': ->
                    dfd.resolve()
                    prefs.$set 'softNotifcationPermission', true
                'No thanks': ->
                    dfd.reject new NotificationPermissionsSoftReject()
                    prefs.$set {
                        softNotifcationPermission: false
                        shiftReminderMinutes: 0
                    }
            }
        }

        return dfd.promise

    factory.checkPermissions = ->
        dfd = $q.defer()

        hasSoftGranted = prefs.softNotifcationPermission
        console.log 'softNotifcationPermission', prefs.softNotifcationPermission

        switch hasSoftGranted
            when undefined then return factory.softAskForPermissions()
            when true      then dfd.resolve()
            when false     then dfd.reject new NotificationPermissionsSoftReject()

        return dfd.promise

    factory.clearAll =  ->
        dfd = $q.defer()

        pgNotification.local.cancelAll ->
            storage.set LOCAL_STORAGE_KEY, {}
            dfd.resolve()

        return dfd.promise

    factory.addMultiple = (notifications) ->
        dfd = $q.defer()
        pgNotification.local.schedule notifications, ->
            dfd.resolve()
            toStore = storage.get(LOCAL_STORAGE_KEY) or {}
            _.each notifications, (noti) -> toStore[noti.id] = noti
            storage.set LOCAL_STORAGE_KEY, toStore

        return dfd.promise

    factory.addSingleReminder = (notification) ->
        dfd = $q.defer()
        pgNotification.local.schedule notification, ->
            dfd.resolve()
            toStore = storage.get(LOCAL_SHIFT_REMINDER_STORAGE_KEY) or {}
            storage.set LOCAL_SHIFT_REMINDER_STORAGE_KEY, toStore

        return dfd.promise

    # Sync ensures there's local notifications scheduled for the given shifts.
    factory.syncShifts = (shifts) ->
        lastFetchedShifts = shifts

        factory.checkPermissions()
            .then ->
                console.log 'Permissions have been granted'
                # Permissions have been granted
                factory.clearAll()
            .then ->
                notifications = _.chain shifts
                    .map _makeSingleNotification
                    .filter _.isObject # Ensure empty notifications are removed
                    .value()

                    # Create reminder to add schedule (3) days after last shift in array
                    # Commented out this function as it's causing iOS 9 build to crash
                    # _defineLastShift shifts

                if notifications.length
                    factory.addMultiple notifications
            .catch (err) ->
                if err instanceof NotificationPermissionsSoftReject
                    # No permission for notifications
                    console.warn 'No permissions'
                else
                    console.error 'Unexpected error with local notifications:'
                    console.log err.stack or err

    factory.syncOnShiftChanges = ->
        $rootScope.$on 'shifts.shifts.changed', _fetchShiftsAndSyncNotifications

        $rootScope.$on 'shifts.prefs.changed', ->
            if skipFirstPrefChange
                skipFirstPrefChange = false
                return

            if prefs.shiftReminderMinutes <= 0
                factory.clearAll()
            else
                factory.syncShifts lastFetchedShifts

    # Wrap each function to check if platform is supported
    _.each factory, (func, funcName) ->
        factory[funcName] = ->
            return _noSupport() unless platformIsSupported
            func arguments...

    return factory