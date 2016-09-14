qantasApp = angular.module 'qantasApp'

qantasApp.directive 'bottomProgress', ->
    restrict: 'E'
    scope:
        page: '=page'
    replace: true
    templateUrl: 'templates/directives/bottomProgress.html'

    link: (scope) ->

        value = 0
        page = scope.page
        totalPages = 10
        value = (page / totalPages) * 100

        $(document).ready ->
            $('#progressbar').progressbar value: value

            return