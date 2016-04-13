qantasApp = angular.module 'qantasApp'

qantasApp.controller 'MapCtrl', ($scope, $element, auth, nav, MatchResource, pg, leafletData, ReverseGeocodeResource, storage) ->

    intialZoomLevel = 14
    # fallBackLocation random for now
    fallBackLat = -33.85
    fallBackLng = 151.20
    @isLoading = false

    # set defaults on load
    usersCurrentLocation =
        lat: fallBackLat
        lng: fallBackLng

    # test
    @reverseGeoCodeLookupString = 'hello'

    # set defaults for map load
    angular.extend $scope,
        sydney:
            lat: fallBackLat
            lng: fallBackLng
            zoom: intialZoomLevel
        layers:
            baselayers:
                googleRoadmap:
                    name: 'Google Streets'
                    layerType: 'ROADMAP'
                    type: 'google'
        defaults:
            scrollWheelZoom: false

    # function that looks up human readable address
    # based on lat.lng
    _reverseGeoCodeLookup = (location) ->
        @lat = location.latlng.lat
        @lng = location.latlng.lng

        ReverseGeocodeResource.getAddress {latitude: @lat, longitude: @lng}
            .$promise.then (response) ->
                console.log 'address', response.address
                # if null is returned, default to
                # the orignal lat, lng of the user
                if response is null
                    @reverseGeoCodeLookupString = @lat + ' , ' + @lng
                else
                    @reverseGeoCodeLookupString = response.address
                    console.log '@reverseGeoCodeLookupString', @reverseGeoCodeLookupString
            .catch (err) ->
                pg.alert {title: 'Error', msg: 'An error occured'}
                console.log 'err status is', err.status, err.message

    # a funcion that deals with the current
    # status of a TIDY THIS UP
    _requestStatusHandler = (requestStatus) ->
        @matchExists = true

        if requestStatus == 'REQUESTED'
            @requestStatus = requestStatus
            nav.goto 'pollingMatchCtrl'
            console.log requestStatus

        else if requestStatus == 'PROPOSAL'
            console.log requestStatus
            nav.goto 'pollingMatchCtrl'
            @requestStatus = requestStatus

        else if requestStatus == 'ACCEPTED'
            console.log requestStatus
            @requestStatus = requestStatus
            nav.goto 'pollingMatchCtrl'

        else if requestStatus == 'CONFIRMED'
            console.log requestStatus
            @requestStatus = requestStatus
            nav.goto 'pollingMatchCtrl'

    _updateCurrentUserPoint = (location) ->
        usersCurrentLocation =
            lat: location.latlng.lat
            lng: location.latlng.lng

    # function that updates the circle and marker on the map when the user updates their location
    _updateMarkerAndCircle = (location, map) ->
        radius = location.accuracy / 2
        console.log 'radius', radius
        L.marker(location.latlng).addTo(map).bindPopup('You are within ' + radius + ' meters from this location').openPopup()
        L.circle(location.latlng, radius).addTo map

    _checkIfMatchExists = ->
        MatchResource.getMatch()
            .$promise.then (res) ->
                requestStatus = res.status
                _requestStatusHandler(requestStatus)
                @isLoading = true
            .catch (err) ->
                if err.status == 404
                    @requestStatus = 'NO MATCH FOUND'
                    @matchExists = false
                    console.log @requestStatus
                    console.log 'err status is', err.status, err.message
                else
                    pg.alert {title: 'Error', msg: 'An error occured'}
                    console.log 'err status is', err.status, err.message

     # create the map
     # with the following params
    _createMap = ->
        # fetch the map object
        leafletData.getMap().then (map) ->

            # create a marker
            L.circleMarker([fallBackLat, fallBackLng],
                color: '#FFFFFF'
                fillColor: '#FFFFFF'
            ).addTo(map)

            # get the locate object
            # and set some params
            L.control.locate(
                position: 'bottomright' # set the location of the control
                follow: true
                drawCircle: true # controls whether a circle is drawn that shows the uncertainty about the location
                setView: true # automatically sets the map view to the user's location, enabled if `follow` is true
                markerClass: L.circleMarker
                circlePadding: [20, 20] #padding around accuracy circle, value is passed to setBounds
                locateOptions:
                    enableHighAccuracy: true

                onLocationFound = (location) ->
                    window.findingLocationModal.hide()

                    # fetch the user friendly location
                    # and update it
                    _reverseGeoCodeLookup(location)
                    # update the user location
                    # in local storage
                    _updateCurrentUserPoint(location)

                    # update the marker and circle object
                    _updateMarkerAndCircle(location, map)

                    # radius = location.accuracy / 2
                    # L.marker(location.latlng).addTo(map).bindPopup('You are within ' + radius + ' meters from this point').openPopup()
                    # L.circle(location.latlng, radius).addTo map

                map.on('locationfound', onLocationFound)

                # on location error, throw a message
                onLocationError = (err) ->

                    pg.alert {title: 'Error', msg: err.message}

                map.on('locationerror', onLocationError)

                ).addTo(map)

    _hideElementsOnMap = ->
        # get elements from map
        mapIconToHide = document.querySelector('.leaflet-control-locate')
        zoomeIconToHide = document.querySelector('.leaflet-control-zoom')
        streetIconToHide = document.querySelector('.leaflet-control-layers')

        iconsToHide = [
            mapIconToHide,
            zoomeIconToHide,
            streetIconToHide
        ]

        # placeholder to fix L object
        # not loading on first load of map
        # after full reload
        if mapIconToHide != null
            for icon in iconsToHide
                icon.style.visibility = 'hidden'

    @updateCurrentLocation = ->
        document.querySelector('.leaflet-bar-part').click()
        window.findingLocationModal.show()

        return true

    # cancel request function
    @cancelRequest = ->
        MatchResource.cancelMatch()
            .$promise.then (res) ->
                console.log 'response is', res
                pg.alert {title: 'Canceled', msg: 'Your request was canceled'}
            .catch (err) ->
                console.log 'err is', err.message
                pg.alert {title: 'Error', msg: err.message}

    @sendRequest = ->

        flightToMatch = storage.get 'flightObj'

        flightNumber = flightToMatch.flight_number
        airport = flightToMatch.departure_airport
        pickupLatitude = usersCurrentLocation.lat
        pickupLongitude = usersCurrentLocation.lng

        # TODO: update this to pull from local storage
        arrivalDateTime = '20-02-2016_09-00-00'

        mockRequest =
            pickup_latitude: pickupLatitude
            pickup_longitude: pickupLongitude
            flight_number: flightNumber
            airport: 'SYD'
            arrival_datetime: '20-02-2016_09-00-00'

        MatchResource.requestMatch mockRequest
            .$promise.then (match) ->
                nav.goto 'pollingMatchCtrl'
                console.log 'match is', match
            .catch (err) ->
                console.log 'err is', err
                pg.alert {title: 'Error', msg: err.status }

    # check if match exists
    _checkIfMatchExists()
    # execute create map
    _createMap()
    # hide all elements on map
    # with timeout to allow map locate
    # object to load
    setTimeout (->
        _hideElementsOnMap()

        return
    ), 300

    return