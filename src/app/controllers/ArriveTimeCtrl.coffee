qantasApp = angular.module 'qantasApp'

qantasApp.controller 'ArriveTimeCtrl', ($http, nav, storage) ->

    jqLite = angular.element

    selectedFlight = storage.get 'flightObj'
    localTime = selectedFlight.local_departure_time
    # @finalTime = moment(localTime).format('MMMM Do YYYY, h:mm:ss')
    @finalTime = moment(localTime).calendar()
    console.log '@finalTime flight time is', @finalTime

    @submitValue = (value) ->
        @value = value
        $('.buttonOne').addClass('animated bounceOut')
        $('.buttonTwo').addClass('animated bounceOut')
        $('.buttonThree').addClass('animated bounceOut')
        $('.buttonFour').addClass('animated bounceOut')
        $('.textOne').addClass('animated bounceOutUp')
        $('.textTwo').addClass('animated bounceOutDown')
        setTimeout (->
            $('.removeElement').hide()
        ), 500

        # storage.set 'minutesBefore', @value
        # nav.goto 'rideCountCtrl'

    @submitAmount = ->
        storage.set 'minutesBefore', @value
        nav.goto 'rideCountCtrl'

    @clearValue = ->
        @value = null
        nav.resetTo 'arriveTimeCtrl'

    # Use this method to combine all the storage keys to one object to post to server
    # finalObj = _.extend({}, firstObj, secondObj)

    return


