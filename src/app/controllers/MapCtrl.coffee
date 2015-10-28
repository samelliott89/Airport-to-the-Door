qantasApp = angular.module 'qantasApp'

qantasApp.controller 'MapCtrl', ($scope, auth, nav) ->

    # @zoom = 8 # Default zoom on load

    # mapPrefs = [
    #   {
    #     featureType: 'administrative'
    #     elementType: 'labels'
    #     stylers: [ { visibility: 'off' } ]
    #   },
    #   {
    #     featureType: 'poi'
    #     elementType: 'labels'
    #     stylers: [ { visibility: 'off' } ]
    #   },
    #   {
    #     featureType: 'water'
    #     elementType: 'labels'
    #     stylers: [ { visibility: 'off' } ]
    #   },
    #   {
    #     featureType: 'road'
    #     elementType: 'labels'
    #     stylers: [ { visibility: 'off' } ]
    #   }
    # ]

    # $scope.mapOptions =
    #     center: (-34.397, 150.644)
    #     zoom: 8
    #     mapTypeId: 'mapPrefs'

    @updateCurrentLocation = ->
        console.log 'update location'

    @proceed = ->
      console.log 'proceed being called'
      nav.goto 'contactCtrl'

    return