qantasApp = angular.module 'qantasApp'

qantasApp.directive 'flightListItem', ->
    return (scope) ->
        touchOn = ->
            if (!$(@).hasClass('flight-selected'))
                $(@).addClass('flight-selected')

        touchOff = ->
            if ($(@).hasClass('flight-selected'))
                $(@).removeClass('flight-selected')

        if (scope.$last)
            $('.flight-list ons-list-item').on('touchstart', touchOn)
            $('.flight-list ons-list-item').on('touchend touchmove', touchOff)
