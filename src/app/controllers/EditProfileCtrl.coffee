qantasApp = angular.module 'qantasApp'

qantasApp.controller 'EditProfileCtrl', ($rootScope, $scope, auth, nav, UserResource, prefs, phoneValidationHelper) ->

    profileId = nav.getParams 'profileId'
    displayNameHasChanged = false
    @user = UserResource.get(id: profileId)
    @isValidNumber = false

    window.editProfile = this

    $scope.$watch 'eprf.user.displayName', (newValue, oldValue) ->

        if (newValue and oldValue) and (newValue isnt oldValue)
            displayNameHasChanged = true

    @checkNumber = ->
        @isValidNumber = phoneValidationHelper.isNumberValid @user.phone
        @user.phone = phoneValidationHelper.formatPhoneNumber @user.phone

    @submitUser = ->
        window.editProfileModal.show()
        if @user.defaultDisplayNameSet and displayNameHasChanged
            auth.currentUser.defaultDisplayNameSet = false
            @user.defaultDisplayNameSet = false
            @user.changedDisplayName = true

        @user.$update {id: profileId}
            .then ->
                nav.back()
            .catch ->
                alert 'An error has occured'
            .finally ->
                window.editProfileModal.hide()

    return
