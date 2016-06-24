qantasApp = angular.module 'qantasApp'

qantasApp.factory 'requestStatusCheck', ($q, MatchResource) ->

    factory = {}

    factory.getRequest = ->
        request = {}
        dfd = $q.defer()

        MatchResource.getMatch()
            .$promise.then (match) ->
                # set the requests status to the status key
                # in the request object
                request.status = match.status
                # logic if the status REQUESTED
                if (request.status == 'REQUESTED')
                    request.title = 'Finding match...'
                    request.subTitle = 'We are looking for someone to match you with. We will let you know when we find someone!'

                # wrap this in an else so that
                # we can get the posposed object which is in the PROPOSAL, ACCEPTED and CONFIRMED states
                else
                    # logic if the status PROPOSAL
                    if (request.status == 'PROPOSED')
                        request.title = 'Waiting...'
                        request.subTitle = match.proposal.given_name + ' would like to share a ride with you. Click Accept to proceed'
                        console.log 'request status check returned', request.status

                    else if (request.status == 'ACCEPTED')
                        request.title = 'Match accepted'
                        request.subTitle = 'We are waiting for reply from your .'
                        console.log 'request status check returned', request.status

                    else if (request.status == 'CONFIRMED')
                        request.title = 'Congratulations'
                        request.subTitle = 'You will be travelling with ' + match.request.given_name + '.'
                        console.log 'request status check returned', request.status

                    # the proposed user as part of request
                    # only available for PROPOSAL, ACCEPTED OR CONFIRMED
                    request.proposedFlight = match.proposal

                    # the proposed request
                    # only available for PROPOSAL, ACCEPTED OR CONFIRMED
                    request.proposedUser = match.request

                dfd.resolve request

            .catch (err) ->
                if err.status == 404
                    request.status = 'NO_MATCH_FOUND'
                    request.title = 'Submit request'
                    request.subTitle = 'Get started by creating a match request.'
                    console.log 'request status check returned', request.status
                    dfd.resolve request
                else
                    console.log 'err status is', err.status, err
                    dfd.reject

        return dfd.promise

    return factory