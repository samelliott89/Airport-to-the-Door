qantasApp = angular.module 'qantasApp'

qantasApp.controller 'MapCtrl', ($scope, $element, auth, nav, MatchResource, pg, leafletData, ReverseGeocodeResource, storage) ->
    DEFAULT_LAT = -33.8688
    DEFAULT_LNG = 151.2093
    DEFAULT_ZOOM_LEVEL = 17

    _map = null
    _mostRecentLocation = null

    _geolocationConfig =
        maximumAge: 3000
        timeout: 5000
        enableHighAccuracy: true

    _markerRadius = 8
    _markerConfig =
        fillOpacity: 1
        stroke: false
        fillColor: '#68000C'

    _accuracyCircleConfig =
        stroke: false
        fillColor: '#E6001B'

    _marker = null
    _accuracyCircle = null

    # set defaults for map load
    # that extend the angular scope
    $scope.defaultLocation =
        lat: DEFAULT_LAT
        lng: DEFAULT_LNG
        zoom: DEFAULT_ZOOM_LEVEL

    $scope.layers =
        baselayers:
            googleRoadmap:
                name: 'Google Streets'
                layerType: 'ROADMAP'
                type: 'google'

    @panToUserLocation = ->
        if _mostRecentLocation
            _map.panTo(new L.LatLng(_mostRecentLocation.lat, _mostRecentLocation.lng))
            _onPanZoomEnd()

    @onSetPickupLocation = ->
        flightToMatch = storage.get 'flightObj'
        center = _map.getCenter()

        # confirm with the user the details
        # they've inputted
        nav.goto 'matchConfirmCtrl', {location: center, flight: flightToMatch, animation: 'lift'}

    _onPanZoomEnd = ->
        _reverseGeoCodeLookup(_map.getCenter())

    _createMap = ->
        leafletData.getMap('map').then((map) ->
            # TODO(SK): Fix hack. Remove all the leaflet controls.
            $('#map').find('.leaflet-control-container').remove()
            _map = map
            _map.on('dragend', _onPanZoomEnd)
            _map.on('zoomend', _onPanZoomEnd)
            _createGeolocation()
        )

    _createGeolocation = ->
        navigator.geolocation.getCurrentPosition(
            (position) ->
                if _map
                    _map.panTo(new L.LatLng(position.coords.latitude, position.coords.longitude))
                    _reverseGeoCodeLookup({lat: position.coords.latitude, lng: position.coords.longitude})
        )

        navigator.geolocation.watchPosition(
            (position) ->
                _mostRecentLocation =
                    lat: position.coords.latitude
                    lng: position.coords.longitude
                if _map
                    _drawPosition(_mostRecentLocation, position.coords.accuracy)
            (error) ->
                console.log(error)
            _geolocationConfig
        )

    _drawPosition = (position, accuracy) ->
        if not _accuracyCircle or not _marker
            _marker = L.circleMarker(position, _markerConfig)
            _marker.setRadius(_markerRadius)
            _map.addLayer(_marker)
            _accuracyCircle = L.circle(position, accuracy, _accuracyCircleConfig)
            _map.addLayer(_accuracyCircle)
        else
            _marker.setLatLng(position)
            _accuracyCircle.setLatLng(position)
            _accuracyCircle.setRadius(accuracy)

    _reverseGeoCodeLookup = (location) ->
        lat = location.lat
        lng = location.lng
        ReverseGeocodeResource.getAddress {latitude: lat, longitude: lng}
        .$promise
        .then (response) ->
            if response and response.address
                $scope.pageTitle = response.address
            else
                $scope.pageTitle = ''
        .catch (err) ->
            console.log 'err status is', err.status

    _createMap()
    return
