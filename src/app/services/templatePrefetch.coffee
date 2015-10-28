qantasApp = angular.module 'qantasApp'

qantasApp.factory 'templatePrefetch', ($rootScope, $templateCache, $http, $q) ->

    run: ->
        promise = $q.when()

        window.config.prefetchAngularTemplates.forEach (templatePath) ->

            if $templateCache.get templatePath
                return

            promise = promise
                .then ->          $http.get(templatePath)
                .then ({body}) -> $templateCache.put templatePath, body

        promise.catch (err) ->
            console.log 'Error occcured while prefetching templates'
            console.log err

        promise.then ->
            $rootScope.$broadcast 'shifts.templates.prefetchFinished'




