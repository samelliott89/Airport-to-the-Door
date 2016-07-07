qantasApp = angular.module 'qantasApp'

qantasApp.controller 'MapCtrl', ($scope, $element, auth, nav, MatchResource, pg, leafletData, ReverseGeocodeResource, storage) ->
    DEFAULT_LAT = -33.8688
    DEFAULT_LNG = 151.2093
    DEFAULT_ZOOM_LEVEL = 17

    _locate = null
    _map = null

    $scope.pageTitle = ''

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

    @defaults =
        scrollWheelZoom: false

    @panToUserLocation = ->
        if _locate
            _locate.start()

    @onSetPickupLocation = ->
        flightToMatch = storage.get 'flightObj'
        center = _map.getCenter()

        # confirm with the user the details
        # they've inputted
        nav.goto 'matchConfirmCtrl', {location: center, flight: flightToMatch, animation: 'lift'}

    _onLocationFound = ->
        _locate.start()

    _onLocationError = (err) ->
        pg.alert {title: 'Error', msg: err.message}

    _onPanEnd = ->
        _reverseGeoCodeLookup(_map.getCenter())

    _createMap = ->
        leafletData.getMap('map').then((map) ->
            # TODO(SK): Fix hack. Remove all the leaflet controls.
            $('#map').find('.leaflet-control-container').remove()

            _map = map
            _map.on('locationfound', _onLocationFound)
            _map.on('locationerror', _onLocationError)
            _map.on('moveend', _onPanEnd)

            _locate = L.control.locate(
                drawMarker: true
                markerStyle:
                    color: '#353752'
                    fillColor: '#3B5998'
                    fillOpacity: 0.7,
                    weight: 2,
                    opacity: 0.9,
                    radius: 5
                drawCircle: true # controls whether a circle is drawn that shows the uncertainty about the location
                circleStyle:
                    color: '#353752'
                    fillColor: '#3B5998'
                locateOptions:
                    enableHighAccuracy: true
                setView: 'once'
            )

            _locate.addTo(_map)
            _locate.start()
        )

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

    $(_createMap)

    return
