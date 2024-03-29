qantasApp = angular.module 'qantasApp'

qantasApp.factory 'MatchResource', ($resource, transform) ->
    $resource "#{config.apiBase}/match/request", {},

    # example API calls
    # GET: '/match/request'
    # returns a match if there is one
    #
        requestMatch:
            method: 'post'

        getMatch:
            method: 'get'

        acceptProposedMatch:
            method: 'post'
            url: "#{config.apiBase}/match/request/accept"

        cancelMatch:
            method: 'post'
            url: "#{config.apiBase}/match/cancel"

        rejectProposedMatch:
            method: 'post'
            url: "#{config.apiBase}/match/request/reject"
