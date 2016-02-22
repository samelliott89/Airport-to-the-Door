qantasApp = angular.module 'qantasApp'

qantasApp.factory 'MatchResource', ($resource, transform) ->
    $resource "#{config.apiBase}/match/request", {},

    # example API calls
    # GET: '/match/request'
    # returns a match if there is one
    #
        requestMatch:
            method: 'post'
            transformResponse: transform.response 'match'

        getMatch:
            method: 'get'
            transformResponse: transform.response 'match'

        acceptProposedMatch:
            method: 'post'
            url: "#{config.apiBase}/match/match/request/accept"
            transformResponse: transform.response 'match'

        cancelMatch:
            method: 'post'
            url: "#{config.apiBase}/match/match/request/cancel"
            transformResponse: transform.response 'null'

        rejectProposedMatch:
            method: 'post'
            url: "#{config.apiBase}/match/match/request/reject"
            transformResponse: transform.response 'match'