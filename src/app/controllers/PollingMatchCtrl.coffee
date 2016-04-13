qantasApp = angular.module 'qantasApp'

qantasApp.controller 'PollingMatchCtrl', ($http, MatchResource, nav) ->

    @isLoading = true

    MatchResource.getMatch()
        .$promise.then (match) ->
            # no need for a handler as logic
            # will be held in template
            @requestStatus = match.status
            console.log 'match status on polling view', @requestStatus
            @isLoading = false
        .catch (err) ->
            console.log 'err status is', err.status, err.message
            pg.alert {title: 'Error', msg: 'An error occured'}

    @goBack = ->
        nav.setRootPage 'navigator'

    @rejectProposedMatch = ->
        MatchResource.cancelMatch()
            .$promise.then (res) ->
                console.log 'canceled match is', res
            .catch (err) ->
                console.log 'err is', err
            .finally ->
                nav.setRootPage 'navigator'

    return