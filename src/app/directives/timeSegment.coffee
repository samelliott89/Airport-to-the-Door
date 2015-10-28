qantasApp = angular.module 'qantasApp'

padOut = (n, width, z) ->
    z = z or '0'
    n = n + ''
    (if n.length >= width then n else new Array(width - n.length + 1).join(z) + n)

qantasApp.directive 'segment', ->
    restrict: 'A'
    scope:
        segment: '='
        default: '@'
    link: (scope, element, attrs) ->
        sectionMap = {start: 0, end: 3}
        prefix = sectionMap[scope.shiftSection]
        scope.hourIndex   = prefix + 0
        scope.minuteIndex = prefix + 1
        scope.periodIndex = prefix + 2
        pad = false
        targetLength = 2

        if attrs.hasOwnProperty 'pad'
            pad = true

        scope.$watch 'segment', (newValue) ->
            if newValue and newValue.length
                if pad and newValue.length < targetLength
                    toPad = targetLength - newValue.length
                    newValue = padOut newValue, targetLength

                element.text newValue
                element.removeClass 'default-value'
            else if scope.default and scope.default.length
                element.text scope.default
                element.addClass 'default-value'
