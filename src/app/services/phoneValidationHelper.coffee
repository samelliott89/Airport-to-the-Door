qantasApp = angular.module 'qantasApp'

qantasApp.factory 'phoneValidationHelper', (prefs) ->
    _FALLBACK_PHONE_LOCALE = 'au'

    factory = {}

    getLocale = ->
        return prefs.countryISO || _FALLBACK_PHONE_LOCALE

    factory.formatPhoneNumber = (number) ->
        return formatE164 getLocale(), number

    factory.isNumberValid = (number) ->
        return isValidNumber(number, getLocale())

    return factory
