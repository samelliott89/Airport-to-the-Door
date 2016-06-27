qantasApp = angular.module 'qantasApp'

qantasApp.directive 'shiftsWeekScroller', ($timeout) ->

    isDayInViewport = (day) ->
        rect = day.getBoundingClientRect()
        return rect.top >= 0 &&
          rect.left >= 0 &&
          rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
          rect.right <= (window.innerWidth || document.documentElement.clientWidth)

    restrict: 'A'
    scope:
        selectedDayIndex: '=shiftsWeekScroller'
    link: (scope, element, attrs) ->

        scope.$watch 'selectedDayIndex', (newValue, oldValue) ->
            return if newValue is oldValue

            _do = ->
                selectedDay = $(element).find('.week__day--selected')[0]
                unless isDayInViewport(selectedDay)
                    selectedDay.scrollIntoView()

            $timeout _do, 50
