qantasApp = angular.module 'qantasApp'

qantasApp.directive 'shiftsDuration', ($timeout, duration) ->
    restrict: 'EA'
    scope:
        start: '='
        end: '='
    link: (scope, element) ->
        ele = element[0]

        defer = (func) -> $timeout func, 10

        # Occasionally the text will blank out for some
        # reason, so this is a hack to try and fix that.
        _repaintHack = ->
            ele.style.display = 'none'
            ele.offsetHeight
            ele.style.display = ''

        _updateDuration = (plzNo = true) ->
            dur = duration scope.start, scope.end
            element.text(dur)  if plzNo
            $timeout _repaintHack, 150

        scope.$watch 'start', _updateDuration
        scope.$watch 'end', _updateDuration