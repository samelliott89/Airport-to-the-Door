qantasApp = angular.module 'qantasApp'

qantasApp.controller 'MapCtrl', ($scope, auth, nav) ->

    intialZoomLevel = 8
    # fallBackLocation random for now
    fallBackLocation = '-33.8909257, 151.1959506'
    defaultMapType = google.maps.MapTypeId.TERRAIN

    # Initialise google map
    $scope.googleMap =
        zoom: intialZoomLevel
        center: fallBackLocation
        options:
            mapTypeId: defaultMapType
            streetViewControl: false
            panControl: false
            disableDefaultUI: true
            zoomControl: true
            disableDoubleClickZoom: true
            minZoom: 0
        control: {}

    @updateCurrentLocation = ->
        console.log 'getting users current location'

    @proceed = ->
        nav.goto 'contactCtrl'

    return