qantasApp = angular.module 'qantasApp'

qantasApp.controller 'ContactCtrl', ($scope, auth, nav) ->

    @contact = ->
      console.log 'getting in contacts'

    return