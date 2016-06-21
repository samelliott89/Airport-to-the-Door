qantasApp = angular.module 'qantasApp'

qantasApp.factory 'requestStatusCheck', (MatchResource) ->

    factory = {}

    factory.getRequest = ->
        request = {}
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
                    if (request.status == 'PROPOSAL')
                        request.title = 'Waiting...'
                        request.subTitle = 'We have found someone, we are just waiting for a reply.'

                    else if (request.status == 'ACCEPTED')
                        request.title = 'Match accepted'
                        request.subTitle = 'Your match has accepted your proposal.'

                    else if (request.status == 'CONFIRMED')
                        request.title = 'Waiting...'
                        request.subTitle = 'We have found someone, we are just waiting for a reply.'

                    # the proposed user as part of request
                    # only available for PROPOSAL, ACCEPTED OR CONFIRMED
                    request.proposedFlight = match.proposal

                    # the proposed request
                    # only available for PROPOSAL, ACCEPTED OR CONFIRMED
                    request.proposedUser = match.request

            .catch (err) ->
                if err.status == 404
                    request.status = 'NO_MATCH_FOUND'
                    request.title = 'Submit request'
                    request.subTitle = 'Get started by creating a match request.'
                else
                    console.log 'err status is', err.status, err

            return request

    return factory