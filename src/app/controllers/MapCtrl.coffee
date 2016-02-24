qantasApp = angular.module 'qantasApp'

qantasApp.controller 'MapCtrl', ($scope, auth, nav, MatchResource, NgMap) ->

    intialZoomLevel = 9
    # fallBackLocation random for now
    fallBackLocation = '[-33.8895885. 151.1897138]'
    defaultMapType = google.maps.MapTypeId.TERRAIN
    $scope.map = {}

    # $scope.map =
    #     zoom: intialZoomLevel
    #     center: fallBackLocation
    #     setZoom: 8
        # options =
        #     mapTypeId: 'TERRAIN'
        #     streetViewControl: false
        #     panControl: false
        #     disableDefaultUI: true
        #     zoomControl: true
        #     disableDoubleClickZoom: true
        #     zoom: 8
        #     setZoom: 8
        # control: {}

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
                nav.goto 'pollingMatchCtrl',
                console.log 'match is', match
            .catch (err) ->
                console.log 'err is', err

    return