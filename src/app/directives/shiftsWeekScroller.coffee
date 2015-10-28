qantasApp = angular.module 'qantasApp'

qantasApp.directive 'shiftsWeekScroller', ($timeout) ->
    restrict: 'A'
    scope:
        selectedDayIndex: '=shiftsWeekScroller'
    link: (scope, element, attrs) ->

        scope.$watch 'selectedDayIndex', (newValue, oldValue) ->
            return  if newValue is oldValue

            _do = ->
                selectedDay = element.find('.week__day--selected')
                isVisible = selectedDay.visible()
                unless isVisible
                    selectedDay[0].scrollIntoView()

            $timeout _do, 50