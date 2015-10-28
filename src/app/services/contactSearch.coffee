qantasApp = angular.module 'qantasApp'

qantasApp.factory 'contactSearch', ($q, $rootScope, prefs, $http, nav) ->

    userContacts = navigator?.contacts
    platformIsSupported = userContacts?
    factory = {}

    factory.contactOptions = new ContactFindOptions() or {}
    factory.contactOptions.multiple = true
    factory.contactOptions.filter = ''
    factory.desiredFields = userContacts.fieldType.id
    factory.fields = [
        userContacts.fieldType.emails
        userContacts.fieldType.name
    ]

    _noSupport = ->
        console.warn 'Contact search is not supported on this platform'

    factory.queryContacts = ->

        dfd = $q.defer()
        onSuccess = (contacts) ->
            contactsEmails = []
            for contact in contacts
                if contact.emails? and contact.emails.length > 0
                    contactsEmails.push contact.emails[0].value

            dfd.resolve contactsEmails

        onError = (err) ->
            dfd.reject err

        if deviceIsIOS
            userContacts.find factory.fields, onSuccess, onError, factory.contactOptions

        if deviceIsAndroid
            userContacts.find factory.fields, onSuccess, onError, factory.contactOptions

        dfd.promise

    # Wrap each function to check if platform is supported

    # _.each factory, (func, funcName) ->
    #     factory[funcName] = ->
    #        return _noSupport() unless platformIsSupported
    #        func arguments...

    return factory