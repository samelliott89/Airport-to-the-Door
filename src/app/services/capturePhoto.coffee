qantasApp = angular.module 'qantasApp'

qantasApp.factory 'capturePhoto', ($q, pg) -> (options, onceSelectedFn = -> ) ->

    pg.getPicture options
        .then (img) ->
            console.log 'pre onceSelectedFn'
            onceSelectedFn()
            console.log 'post onceSelectedFn'

            fileUploadOptions = {
                fileKey: 'file'
                fileSourceURI: img
                uploadURI: 'https://upload.uploadcare.com/base/'
                params: {
                    'UPLOADCARE_PUB_KEY': config.uploadcarePublicKey
                    'UPLOADCARE_STORE': 1
                }
            }

            pg.fileTransferUpload fileUploadOptions
        .then (resp) ->
            $q.when JSON.parse(resp.response)