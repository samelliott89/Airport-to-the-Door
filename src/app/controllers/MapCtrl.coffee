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
        # markers:
        #     m1:
        #         lat: 52.52
        #         lng: 13.40
        layers:
            baselayers:
                googleRoadmap:
                    name: 'Google Streets'
                    layerType: 'ROADMAP'
                    type: 'google'
        defaults:
            scrollWheelZoom: false

    _checkIfMatchExists = ->
        MatchResource.getMatch()
            .$promise.then (match) ->
                # temporary state
                # for returned match
                # can't test locally
                matchExists = true
                if matchExists = true
                    @matchExists = true
                else
                    @matchExists = false
                @isLoading = true
                console.log 'match exists', @matchExists
                console.log 'got match', match
                console.log 'isLoading', @isLoading
            .catch (err) ->
                console.log 'err is', err
                pg.alert {title: 'Error', msg: 'An error occured'}

     # create the map
     # with the following params
    _createMap = ->
        # fetch the map object
        leafletData.getMap().then (map) ->

            # create a marker
            L.circle([51.508, -0.11], 500, {
                color: 'red',
                fillColor: '#f03',
                fillOpacity: 0.5
            }).addTo(map)

            # get the locate object
            # and set some params
            L.control.locate(
                position: 'bottomright' # set the location of the control
                follow: true
                drawCircle: true # controls whether a circle is drawn that shows the uncertainty about the location
                setView: true # automatically sets the map view to the user's location, enabled if `follow` is true

                # on location error, throw a message
                #
                onLocationError: (err) ->

                    pg.alert {title: 'Error', msg: err.message}

                    return

                locateOptions:
                    enableHighAccuracy: true

                ).addTo(map)

    # cancel request function
    @cancelRequest = ->
        MatchResource.rejectProposedMatch()
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
                nav.goto 'pollingMatchCtrl',
                console.log 'match is', match
            .catch (err) ->
                console.log 'err is', err.message
                pg.alert {title: 'Error', msg: err.message }

    # execute create map
    _createMap()
    # check if match exists
    _checkIfMatchExists()

    console.log 'final isLoading', @isLoading

    return