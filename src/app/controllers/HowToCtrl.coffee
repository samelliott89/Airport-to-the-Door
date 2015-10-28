qantasApp = angular.module 'qantasApp'

qantasApp.controller 'HowToCtrl', ($scope, auth, launchAddShiftsHelper, nav, pg, prefs) ->

    @cancelOnboarding = ->
        if !prefs.completedOnboarding
            nav.back()
            pg.alert {
                title: 'Did you know?'
                msg: 'You can always find this in Profile > Settings'
            }
        else
            nav.back()

    @completedOnboarding = ->
        _getStarted = ->
            pg.confirm {
                title: 'Ready to get started?'
                buttons: {
                    'Yes please!': launchAddShiftsHelper
                    'Not now': ->
                }
            }

        if !prefs.completedOnboarding
            nav.back()
            _getStarted()
        else
            nav.back()

    return