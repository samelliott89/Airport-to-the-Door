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

        acceptProposedMatch:
            method: 'post'
            url: "#{config.apiBase}/match/request/accept"
            transformResponse: transform.response 'acceptedMatch'

        cancelMatch:
            method: 'post'
            url: "#{config.apiBase}/match/cancel"
            transformResponse: transform.response null

        rejectProposedMatch:
            method: 'post'
            url: "#{config.apiBase}/match/request/reject"
            transformResponse: transform.response null