qantasApp = angular.module 'qantasApp'

qantasApp.controller 'RideCountCtrl', ($http, auth, nav, storage) ->

    _listOfButtons = [
        '#1'
        '#2'
        '#3'
    ]
    _buttonElement = '.rideAnimationButton'
    _textElement = '.rideAnimationText'

    _selectAnimationById = (amount) ->
        console.log 'amount', amount
        id = '#' + amount
        $(id).removeClass('rollIn').addClass('bounceOut')
        listOfElementsToHide = _.without(_listOfButtons, id)

        console.log 'listOfElementsToHide', listOfElementsToHide

        for element in listOfElementsToHide
            $(element).removeClass('rollIn').addClass('fadeOut')
            console.log 'hiding element', element
            console.log $(element)

        setTimeout (->
            _goToNextView()
        ), 800

    _goToNextView = ->
        nav.goto 'mapCtrl'
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

    @submitValue = (partySize) ->
        console.log 'partySize is', partySize
        _selectAnimationById(partySize)
        storage.set 'partySize', partySize

    _addIntroAnimations()

    return
