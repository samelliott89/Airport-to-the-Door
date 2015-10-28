qantasApp = angular.module 'qantasApp'

qantasApp.factory 'rosterCapture', ($q, $timeout, $http, auth, pg, storage, capturePhoto, RosterCaptureResource, geolocation, uploadcare) ->

    self = {}

    showErrorMessage = (err) ->
        window.uploadRosterCapture.hide()

        console.error 'Error creating capture:'
        console.error err

        errMsg = 'There was an error uploading your schedule capture. Please try again later.'

        if typeof err is 'string'
            err = err.toLowerCase()

            if err is 'no camera available'
                errMsg = 'This device doese not have a camera!'

            else if err is 'no image selected'
                # No need to show an error message in this instance
                return


        pg.alert {
            title: 'Oops'
            msg: errMsg
        }

    showSuccessMessage = ->
        window.uploadRosterCapture.hide()
        pg.alert {
            title: 'Awesome'
            msg: 'We\'ll email you when your shifts have been added.'
        }

    promptForGeo = ->
        approvedGeoAccess = storage.get 'approvedGeoAccess'

        if approvedGeoAccess
            return $q.when()

        pg.alert({
            title: 'Allow Geolocation'
            msg: 'Atum requires access to your location so we can accurately determine which time zone you\'re in'
            button: 'Continue'
        }).then ->
            storage.set 'approvedGeoAccess', true
            return $q.when()


    self.getTimezoneName = ->
        geolocation.getLocation()
            .then ({coords}) ->
                url = """https://maps.googleapis.com/maps/api/timezone/json?\
                    key=#{config.googleTimeZoneApiKey}&\
                    location=#{coords.latitude},#{coords.longitude}&\
                    timestamp=#{Date.now() / 1000}"""

                $http.get url
            .then ({data}) ->
                $q.when data.timeZoneId

    self.saveCapture = (ucImageID, tzName) ->
        cap = new RosterCaptureResource {
            ucImageID, tzName
            userId: auth.currentUser.id
        }
        cap.$save()

    self.captureNatively = (sourceType) ->
        cameraOptions = {
            allowEdit: true
            mediaType: 'PICTURE',
            cameraDirection: 'BACK',
            targetWidth: 1500
            targetHeight: 3000
            sourceType: sourceType or 'CAMERA'
        }

        promptForGeo()
            .then ->
                uploadPromise = capturePhoto cameraOptions, ->
                    _fn = -> window.uploadRosterCapture.show()
                    $timeout _fn, 10

                tzPromise = self.getTimezoneName()
                $q.all [uploadPromise, tzPromise]
            .then ([{file}, tzName]) ->
                console.log 'All promises returned', arguments[0]
                console.log 'Got tzName', tzName + '. Now saving.'
                self.saveCapture file, tzName
            .then       showSuccessMessage
            .catch      showErrorMessage


    self.captureFromHtml = (files) ->
        [file] = files
        return unless file

        uploadPromise = uploadcare.upload file

        promptForGeo()
            .then ->
                window.uploadRosterCapture.show()
                tzPromise = self.getTimezoneName()
                $q.all [uploadPromise, tzPromise]
            .then ([uploadResult, tzName]) ->
                self.saveCapture uploadResult.file, tzName
            .then    showSuccessMessage
            .catch   showErrorMessage

    return self
