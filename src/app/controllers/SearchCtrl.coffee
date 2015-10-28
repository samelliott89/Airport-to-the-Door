qantasApp = angular.module 'qantasApp'

qantasApp.controller 'SearchCtrl', ($http, auth, nav, focus, $timeout, SearchResource, pg, contactSearch, ContactFindResource) ->

    profileId = nav.getParams 'profileId'
    @focus = focus
    @hasSearched = false

    $timeout (-> focus 'searchInput'), 50

    @searchUser = ->
        @isSearching = true
        @hasSearched = false
        @results = []
        SearchResource.searchUsers {q: @searchTerm}
            .$promise.then (results) =>
                @results = results
                @isSearching = false
                @hasSearched = true

    @cancelSearch = ->
        @searchTerm = null
        @results = []
        blur()

    @launchContactPicker = ->
        pg.confirm {
            title: 'Contact search'
            msg: 'Want to find people on Atum using your contact list?'
            buttons: {
                'Yes': _actuallylaunchContactPicker
                'Cancel': ->
            }
        }

    _actuallylaunchContactPicker = ->
        window.findContactsModal.show()
        contactSearch.queryContacts()
            .then (contactsEmails) ->
                $http.post "#{config.apiBase}/v1/contacts/find", JSON.stringify { emails: contactsEmails }
                    .success (data, status, headers, config) ->
                        window.findContactsModal.hide()
                        nav.goto 'listContactsCtrl', { contacts: data.users }

                    .error (data, status, headers, config) ->
            .then (resp) ->

    @launchContacts = ->
        nav.goto 'connectContactsCtrl'

    @inviteFriends = ->

        if window.isNativeAndroid
            msg = auth.currentUser.displayName + ' invited you to join Atum. Download the app from the Play Store.'
            link = config.androidStoreURL
        else
            msg = auth.currentUser.displayName + ' invited you to join Atum. Download the app from the App Store.'
            link = config.appleStoreURL

        pg.openShareSheet {
            msg: msg
            link: link
        }

    return