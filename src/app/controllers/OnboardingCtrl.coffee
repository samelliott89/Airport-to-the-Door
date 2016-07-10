qantasApp = angular.module 'qantasApp'

qantasApp.controller 'OnboardingCtrl', (nav) ->

    @start = ->
        nav.setRootPage 'navigator'

    return
