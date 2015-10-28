qantasApp = angular.module 'qantasApp'

qantasApp.directive 'shiftsShiftList', ($rootScope, auth, nav) ->
    restrict: 'EA'
    replace: true
    templateUrl: 'templates/directives/shiftList.html'
    scope:
        shifts: '='
        feed: '='
    link: (scope, ele, attrs) ->
        _onShiftUpdate = (shifts) ->
            _.each shifts, (shift) ->
                shift.showCoworkers = globalShowCoworkers and shift.coworkers?.length > 0

            scope.schedule = _.chain(shifts)
                .groupBy (shift) ->
                    day = new Date shift.start
                    dayOfWeek = day.getDay()
                    day.setDate day.getDate() - dayOfWeek
                    day.toDateString()
                .pairs()
                .sortBy ([_startOfWeek, shifts]) ->
                    startOfWeek = _startOfWeek.split(' ')[1...].join(' ')
                    moment startOfWeek, 'MMMM DD YYYY'
                .map ([startOfWeek, shifts]) -> {startOfWeek, shifts}
                .each (week) ->
                    {startOfWeek, shifts} = week
                    week.hoursWorked = 0
                    for shift in shifts
                        if shift.isDayOff
                            continue
                        dur = new Date(shift.end) - new Date(shift.start)
                        week.hoursWorked += dur
                .value()

            window.schedule = scope.schedule

        _onFeedUpdate = (feed) ->
            scope.schedule = feed

        globalShowCoworkers = false

        # We put this onto the rootscope due to some weird directive scope issues
        $rootScope.gotoShift = (shift) ->
            view = ons.navigator.pages[0].name
            dayOff = shift.isDayOff
            profileView = 'templates/profileCtrl.html'
            connectionView = 'templates/connectionCtrl.html'
            feedView = 'templates/flightNumberCtrl.html'
            if !dayOff and shift.ownerID is auth.currentUser.id
                nav.goto 'shiftViewCtrl', {shift}
            else if (dayOff and view == profileView) or (dayOff and view == connectionView)
                console.log 'noView'
            else if (dayOff and view == feedView)
                nav.goto 'dayOffViewCtrl', {shift}

        scope.$watch attrs.showCoworkers, (newValue) ->
            globalShowCoworkers = attrs.hasOwnProperty 'showCoworkers'
            scope.showCoworkers = globalShowCoworkers

        if _.has attrs, 'feed'
            scope.$watch 'feed', _onFeedUpdate

        if _.has attrs, 'shifts'
            scope.$watch 'shifts', _onShiftUpdate

        return