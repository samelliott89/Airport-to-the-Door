qantasApp = angular.module 'qantasApp'

qantasApp.directive 'shiftsNextShift', ($interval, selectNextShift) ->
    restrict: 'EA'
    replace: true
    templateUrl: 'templates/directives/nextShift.html'
    scope:
        feed: '='
        showEmpty: '='
    link: (scope) ->
        updateNow = -> scope.now = new Date()

        updateInterval = 5 # seconds
        interval = $interval updateNow, updateInterval * 1000
        updateNow()

        scope.$watch 'feed', ->
            return unless scope.feed
            {shift, shiftIsCurrent} = selectNextShift(scope.feed)
            scope.shift = shift
            scope.shiftIsCurrent = shiftIsCurrent
            scope.now = new Date()

        scope.$on '$destroy', -> $interval.cancel interval
        return