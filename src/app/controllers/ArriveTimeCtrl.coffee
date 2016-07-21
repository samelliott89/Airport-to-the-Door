qantasApp = angular.module 'qantasApp'

qantasApp.controller 'ArriveTimeCtrl', ($http, nav, storage) ->

    _selectedFlight = storage.get 'flightObj'
    _localDatetime = _selectedFlight.local_departure_datetime
    _momentDatetime = moment(_localDatetime, 'DD-MM-YYYY_HH-mm-ss')
    _buttonElement = '.animationButton'
    _textElement = '.animationText'
    _listOfButtons = [
        '#60'
        '#120'
        '#180'
        '#240'
    ]

    @selectedFlightNumber = _selectedFlight.flight_number
    @formattedTimeOfFlight = _momentDatetime.format('h:mm a')
    @relativeTimeUntilFlight = _momentDatetime.fromNow()

    _selectAnimationById = (amount) ->
        id = '#' + amount
        $(id).removeClass('rollIn').addClass('bounceOut')
        listOfElementsToHide = _.without(_listOfButtons, id)

        for element in listOfElementsToHide
            $(element).removeClass('rollIn').addClass('fadeOut')

        setTimeout (->
            _goToNextView()
        ), 800

    _goToNextView = ->
        console.log '_goToNextView'
        nav.goto 'rideCountCtrl'
        setTimeout (->
            _removeAnimatedClass()
        ), 800

    _addIntroAnimations = ->
        console.log '_addIntroAnimations'
        $(_buttonElement).addClass('animated rollIn')
        $(_textElement).addClass('animated fadeIn')

    _removeAnimatedClass = ->
        console.log '_removeAnimatedClass'
        $(_buttonElement).removeClass('animated')
        $(_textElement).removeClass('animated')

    @submitValue = (value) ->
        _selectAnimationById(value)
        storage.set 'minutesBefore', value
        console.log 'submitValue', value

    _addIntroAnimations()

    return



