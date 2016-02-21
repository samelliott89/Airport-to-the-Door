qantasApp = angular.module 'qantasApp'

qantasApp.controller 'MapCtrl', ($scope, auth, nav, MatchResource) ->

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

    @requestMatch = ->

        mockRequest =
            pickup_latitude: -33.8650,
            pickup_longitude: 151.2094,
            flight_number: 'QFA1',
            airport: 'SYD',
            arrival_datetime: '20-02-2016_09-00-00'

        MatchResource.requestMatch mockRequest
            .$promise.then (match) ->
                console.log 'match is', match
            .catch (err) ->
                console.log 'err is', err

    return