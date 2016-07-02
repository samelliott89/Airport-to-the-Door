qantasApp = angular.module 'qantasApp'

qantasApp.controller 'MapCtrl', ($scope, $element, auth, nav, MatchResource, pg, leafletData, ReverseGeocodeResource, storage) ->

    intialZoomLevel = 14

    # fallBackLocation random for now
    # update to get location on load
    fallBackLat = -33.85
    fallBackLng = 151.20
    @isLoading = false

    # set defaults on load
    usersCurrentLocation =
        lat: fallBackLat
        lng: fallBackLng

    # default reverse string
    $scope.reverseGeoCodeLookupString = fallBackLat + ', ' + fallBackLng

    # set defaults for map load
    # that extend the angular scope
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
                if response is null or undefined
                    console.log 'ReverseGeocodeResource is either null or undefined', response
                    # therefore defualt to the lat and long values passed into the function
                    $scope.reverseGeoCodeLookupString = @lat + ', ' + @lng

                    # then update all the bindings on the scope object
                    $scope.$apply
                    console.log 'no reverseGeoCodeLookupString, so defaulting to empty lat,lng', $scope.reverseGeoCodeLookupString
                else
                    $scope.reverseGeoCodeLookupString = response.address

                    # return the address and bind to reverse geocode scope value
                    $scope.$apply
                    # then update all the bindings on the scope object
                    console.log '@reverseGeoCodeLookupString', $scope.reverseGeoCodeLookupString

            .catch (err) ->
                pg.alert {title: 'Error', msg: 'An error occured'}
                console.log 'err status is', err.status

    # a funcion that deals with the current
    # status of the request
    _requestStatusHandler = (requestStatus) ->

        @matchExists = true

        if requestStatus == 'REQUESTED' or 'PROPOSAL' or 'ACCEPTED' or 'CONFIRMED'
            nav.goto 'pollingMatchCtrl'
            console.log requestStatus

    _updateCurrentUserPoint = (location) ->
        usersCurrentLocation =
            lat: location.latlng.lat
            lng: location.latlng.lng

        console.log 'updating users location', usersCurrentLocation
        # window.findingLocationModal.hide()

    # function that updates the circle and marker on the map when the user updates their location
    _updateMarkerAndCircle = (location, map) ->
        radius = location.accuracy / 2
        console.log 'radius', radius
        L.marker(location.latlng).addTo(map).bindPopup('You are within ' + radius + ' meters from this location').openPopup()
        L.circle(location.latlng, radius).addTo map

    # deletes the marker and circle layers
    _deleteMarkerAndCircle = (map) ->
        console.log 'deleting marker and circle'
        map.removeLayer(L.marker)
        map.removeLayer(L.circle)

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

            # create a circle marker with default values
            L.circleMarker([fallBackLat, fallBackLng],
                color: '#353752'
                fillColor: '#353752'
            ).addTo(map)

            L.Icon.Default.imagePath = ''

            # get the locate object
            # and set some params
            L.control.locate(
                position: 'bottomright' # set the location of the control
                drawCircle: true # controls whether a circle is drawn that shows the uncertainty about the location
                setView: true # automatically sets the map view to the user's location, enabled if `follow` is true
                markerClass: L.circleMarker
                circlePadding: [20, 20] #padding around accuracy circle, value is passed to setBounds
                locateOptions:
                    enableHighAccuracy: true

                onLocationFound = (location) ->

                    # window.findingLocationModal.hide()
                    # console.log 'hiding findingLocationModal'
                    # fetch the user friendly location
                    # and update it
                    _reverseGeoCodeLookup(location)

                    ##
                    # update the user location
                    # in local storage
                    _updateCurrentUserPoint(location)

                    #delete marker and circle objects
                    # so that they don't create new ones
                    # everytime _updateMarkerAndCircle is called
                    _deleteMarkerAndCircle(map)

                    # update the marker and circle object
                    #
                    _updateMarkerAndCircle(location, map)

                map.on('locationfound', onLocationFound)

                # on location error, throw a message
                onLocationError = (err) ->

                    pg.alert {title: 'Error', msg: err.message}

                map.on('locationerror', onLocationError)

                ).addTo(map)


    # super massive hack
    # that needs to be fixed
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
        button = document.querySelector('.leaflet-bar-part')

        if button
            console.log 'button is', button
            button.click()

        else
            console.log 'no button'
        # window.findingLocationModal.show()

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

        # get the flight object from storage
        flightToMatch = storage.get 'flightObj'
        minutesBefore = storage.get 'minutesBefore'

        # package up
        arrivalDateTime = flightToMatch.local_departure_datetime
        momentDateTime = moment(arrivalDateTime, 'DD-MM-YYYY_HH-mm-ss')
        adjustedDateTime = moment(momentDateTime).add(minutesBefore, 'minutes')
        finalDateTime = adjustedDateTime.format('DD-MM-YYYY_HH-mm-ss')

        requestToBeSent =
            pickup_latitude: usersCurrentLocation.lat
            pickup_longitude: usersCurrentLocation.lat
            flight_number: flightToMatch.flight_number
            airport: flightToMatch.departure_airport or 'SYD'
            # TODO (sk) update arrivalDateTime to finalDateTime when bug is fixed
            # for moment.add()
            arrival_datetime: arrivalDateTime

        # confirm with the user the details
        # they've inputted
        nav.goto 'matchConfirmCtrl', {request: requestToBeSent, animation: 'lift'}

    # check if match exists
    _checkIfMatchExists()
    # execute create map
    _createMap()
    # hide all elements on map
    # with timeout to allow map locate
    # object to load
    $(document).ready ->

        console.log 'document ready'
        _hideElementsOnMap()

        return
    # setTimeout (->
    #     _hideElementsOnMap()

    #     return

    # ), 200

    return
