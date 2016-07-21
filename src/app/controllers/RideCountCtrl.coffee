qantasApp = angular.module 'qantasApp'

qantasApp.controller 'RideCountCtrl', ($http, auth, nav, storage) ->

    _goToNextView = ->
        nav.goto 'mapCtrl'
        setTimeout (->
            _removeAnimatedClass()
        ), 800

    _addIntroAnimations = ->
        $('#buttonOne').addClass('animated rollIn')
        $('#buttonTwo').addClass('animated rollIn')

    _addOutAnimations = ->
        $('#buttonOne').removeClass('rollIn').addClass('bounceOutLeft')
        $('#buttonTwo').removeClass('rollIn').addClass('bounceOutRight')
        $('.textOne').addClass('fadeOut')

    _removeAnimatedClass = ->
        $('#buttonOne').removeClass('animated')
        $('#buttonTwo').removeClass('animated')

    @submitValue = (value) ->
        storage.set 'rideCount', value
        _addOutAnimations()

        setTimeout (->
            _goToNextView()
        ), 400

    _addIntroAnimations()

    return
