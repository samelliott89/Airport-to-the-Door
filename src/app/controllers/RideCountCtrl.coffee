qantasApp = angular.module 'qantasApp'

qantasApp.controller 'RideCountCtrl', ($http, auth, nav, storage) ->

    jqLite = angular.element

    @submitValue = (value) ->
        @value = value
        $('.buttonOne').addClass('animated bounceOutLeft')
        $('.buttonTwo').addClass('animated bounceOutRight')
        $('.textOne').addClass('animated bounceOutRight')
        setTimeout (->
            $('.removeElement').hide()
        ), 300

    @submitCount = ->
        console.log 'submitting ride count number to API', @value
        storage.set 'rideCount', @value
        nav.goto 'flightSummaryCtrl'

    @clearValue = ->
        @value = null
        nav.resetTo 'rideCountCtrl'

    return
