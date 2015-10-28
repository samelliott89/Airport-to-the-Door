qantasApp = angular.module 'qantasApp'

qantasApp.factory 'pg', ($q, $rootScope, $templateCache, $onsen, DialogView, IOSAlertDialogAnimator) ->
    isCordova = window.isCordova
    navi = window.navigator

    camera: navi.camera
    notification: window.plugin?.notification
    isCordova: window.isCordova

    alert: ({msg, title, button}) ->
        dfd = $q.defer()
        _cb = (index) -> dfd.resolve()

        if isCordova
            navi.notification.alert msg, _cb, title, button
        else
            ons.notification.alert {
                message: msg
                title: title
                callback: _cb
            }

        dfd.promise

    confirm: ({msg, title, buttons}) ->
        dfd = $q.defer()
        _cb = (index) ->
            buttonActions[index]()
            dfd.resolve()

        buttonLabels = []
        buttonActions = [ -> ]

        for label, func of buttons
            buttonLabels.push label
            buttonActions.push func

        if isCordova

            if window.isNativeAndroid and msg is undefined
                msg = title
                title = ' '

            navi.notification.confirm msg, _cb, title, buttonLabels
        else
            if title and !msg
                msg = title
                title = undefined

            ons.notification.confirm {
                title: title
                message: msg
                buttonLabels: buttonLabels
                callback: (index) -> _cb(index + 1)
            }

        dfd.promise

    actionSheet: (config) ->

        actions = [null]
        pluginOptions = {title: config.title}

        if config.destructive
            pluginOptions.addDestructiveButtonWithLabel = config.destructive.label
            pluginOptions.androidEnableCancelButton = true
            pluginOptions.winphoneEnableCancelButton = true
            actions.push config.destructive

        if config.actions
            pluginOptions.buttonLabels = []

            for rawAction in config.actions
                pluginOptions.buttonLabels.push rawAction.label
                actions.push rawAction

        if config.cancel
            pluginOptions.addCancelButtonWithLabel = config.cancel.label
            actions.push config.cancel

        if isCordova
            window.plugins.actionsheet.show pluginOptions, (selected) ->
                actions[selected].action()
        else
            dialog = null
            dialogID = Math.random().toString(36).substr(2, 5)
            dialogName = "fakeDialog_#{dialogID}"
            confName = "#{dialogName}_config"
            templateName = "#{dialogName}.html"

            $rootScope[confName] = config

            _cleanup = ->
                $rootScope[dialogName].destroy()
                delete $rootScope[confName]
                delete $rootScope[dialogName]

            config._tapped = (selectedRow) ->
                selectedRow.action()
                dialog.hide()
                window.lastDialog = dialog
                dialog.on 'posthide', -> setTimeout(_cleanup, 0)

            template = """
                <ons-dialog var="#{dialogName}" cancelable animation="iosAlertStyle">

                    <ons-list class="text-center">
                        <ons-list-item modifier="tappable" ng-repeat="row in #{confName}.actions" ng-click="#{confName}._tapped(row)">
                            {{row.label}}
                        </ons-list-item>

                        <ons-list-item modifier="tappable" ng-if="#{confName}.cancel" ng-click="#{confName}._tapped(#{confName}.cancel)">
                            <span class="semi-bold">{{#{confName}.cancel.label}}</span>
                        </ons-list-item>
                    </ons-list>

                </ons-dialog>
            """

            $templateCache.put templateName, template

            ons.createDialog(templateName).then ->
                dialog = window[dialogName]
                dialog.show()

    openActionSheet: (options) ->
        dfd = $q.defer()
        _cb = (index) -> dfd.resolve index
        window.plugins.actionsheet.show options, _cb
        dfd.promise

    openShareSheet: ({msg, subject, image, link}) ->
        window.plugins.socialsharing.share msg, subject, image, link

    getPicture: (options) ->
        dfd = $q.defer()

        _success = (img) -> dfd.resolve img
        _failure = (reason) -> dfd.reject reason

        options.sourceType = navi.camera?.PictureSourceType?[options.sourceType.toUpperCase()]
        options.mediaType = navi.camera?.MediaType?[options.mediaType.toUpperCase()]
        options.cameraDirection = navi.camera?.Direction?[options.cameraDirection.toUpperCase()]

        if isCordova
            navi.camera.getPicture _success, _failure, options
        else
            console.warn 'Warning, can not open camera on non-cordova device'
            _failure 'Camera not present on non-cordova device'

        dfd.promise

    fileTransferUpload: (options) ->
        dfd = $q.defer()
        ftOptions = new FileUploadOptions()
        ft = new FileTransfer()

        fileSourceURI = options.fileSourceURI
        uploadURI = options.uploadURI
        delete options.fileSourceURI
        delete options.uploadURI

        for key, value of options
            ftOptions[key] = value

        _success = (resp) -> dfd.resolve resp
        _failure = (err) -> dfd.reject err

        ft.upload fileSourceURI, encodeURI(uploadURI), _success, _failure, ftOptions
        dfd.promise