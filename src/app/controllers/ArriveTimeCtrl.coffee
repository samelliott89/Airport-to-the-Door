qantasApp = angular.module 'qantasApp'

qantasApp.controller 'ArriveTimeCtrl', ($http, nav, storage) ->

    jqLite = angular.element

    selectedFlight = storage.get 'flightObj'
    rawTime = selectedFlight.local_departure_time
    @finalTime = moment(@rawTime).format('MMM Do YY')
    console.log '@finalTime flight time is', @finalTime

    @submitValue = (value) ->
        @value = value
        $('.buttonOne').addClass('animated bounceOut')
        $('.buttonTwo').addClass('animated bounceOut')
        $('.buttonThree').addClass('animated bounceOut')
        $('.buttonFour').addClass('animated bounceOut')
        $('.textOne').addClass('animated bounceOutUp')
        setTimeout (->
            $('.removeElement').hide()
        ), 500

    @submitAmount = ->
        storage.set 'rideCount', @value
        nav.goto 'flightSummaryCtrl'

    @clearValue = ->
        @value = null
        nav.resetTo 'arriveTimeCtrl'

    # Use this method to combine all the storage keys to one object to post to server
    # finalObj = _.extend({}, firstObj, secondObj)

    return


