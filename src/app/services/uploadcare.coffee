qantasApp = angular.module 'qantasApp'
qantasApp.factory 'uploadcare', ($upload) ->
    upload: (file) ->
        $upload
            .upload({
                url: 'https://upload.uploadcare.com/base/'
                fields: {
                    'UPLOADCARE_PUB_KEY': config.uploadcarePublicKey
                    'UPLOADCARE_STORE': '1',
                }
                file: file
            })
            .then ({data}) -> return data