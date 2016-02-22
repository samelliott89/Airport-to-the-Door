qantasApp = angular.module 'qantasApp'

qantasApp.controller 'PollingMatchCtrl', ($http, MatchResource, nav) ->

    @goBack = ->
        nav.setRootPage 'navigator'

    @rejectProposedMatch = ->
        MatchResource.rejectProposedMatch()
            .$promise.then (res) ->
                console.log 'res is', res
            .catch (err) ->
                console.log 'err is', err
            .finally ->
                nav.setRootPage 'navigator'

    setup = ->
        MatchResource.getMatch()
            .$promise.then (match) ->
                console.log 'got match', match
            .catch (err) ->
                console.log 'err is', err

    setup()

    return