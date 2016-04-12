qantasApp = angular.module 'qantasApp'

qantasApp.controller 'MapCtrl', ($scope, $element, auth, nav, MatchResource, pg, leafletData) ->

    intialZoomLevel = 14
    # fallBackLocation random for now
    fallBackLat = -33.85
    fallBackLng = 151.20
    @isLoading = false

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
            L.circle([fallBackLat, fallBackLng], 500, {
                color: 'red',
                fillColor: '#FFFFFF',
                fillOpacity: 0.6
            }).addTo(map)

            # get the locate object
            # and set some params
            L.control.locate(
                position: 'bottomright' # set the location of the control
                follow: true
                drawCircle: true # controls whether a circle is drawn that shows the uncertainty about the location
                setView: true # automatically sets the map view to the user's location, enabled if `follow` is true
                markerClass: L.circleMarker
                circlePadding: [20, 20] #padding around accuracy circle, value is passed to setBounds

                onLocationFound: (location) ->

                    console.log 'latlng are', location.latlng

                # on location error, throw a message
                onLocationError: (err) ->

                    pg.alert {title: 'Error', msg: err.message}

                locateOptions:
                    enableHighAccuracy: true

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
        # not loading on first load
        if mapIconToHide != null
            for icon in iconsToHide
                icon.style.visibility = 'hidden'

    @updateCurrentLocation = ->
        document.querySelector('.leaflet-bar-part').click()

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
        mockRequest =
            pickup_latitude: -33.8650,
            pickup_longitude: 151.2094,
            flight_number: 'QFA1',
            airport: 'SYD',
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