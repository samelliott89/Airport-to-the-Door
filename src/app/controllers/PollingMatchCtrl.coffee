qantasApp = angular.module 'qantasApp'

qantasApp.controller 'PollingMatchCtrl', ($http, MatchResource, nav) ->

    @isLoading = false

    @goBack = ->
        nav.setRootPage 'navigator'

    @rejectProposedMatch = ->
        MatchResource.cancelMatch()
            .$promise.then (res) ->
                console.log 'res is', res
            .catch (err) ->
                console.log 'err is', err
            .finally ->
                nav.setRootPage 'navigator'

    setupView = ->
        MatchResource.getMatch()
            .$promise.then (match) ->
                @requestStatus = match.status
                if @requestStatus == 'REQUESTED'
                    console.log '@requestStatus', @requestStatus
                    @requestStatus = @requestStatus
                else if @requestStatus == 'PROPOSAL'
                    console.log '@requestStatus', @requestStatus
                else if @requestStatus == 'ACCEPTED'
                    console.log '@requestStatus', @requestStatus
                else if @requestStatus == 'CONFIRMED'
                    console.log '@requestStatus', @requestStatus
                @isLoading = true
            .catch (err) ->
                console.log 'err status is', err.status, err.message
                pg.alert {title: 'Error', msg: 'An error occured'}

    setupView()

    return