qantasApp = angular.module 'qantasApp'

qantasApp.directive 'shiftsUserList', (duration, nav) ->
    restrict: 'EA'
    replace: true
    templateUrl: 'templates/directives/shiftsUserList.html'
    scope:
        users: '='
        listHeader: '@'
    link: (scope, element, attrs) ->
        scope.nav = nav
        scope.searchEnabled = _.has attrs, 'enableSearch'

        scope.search  = {
            term: undefined
        }

        scope.cancelSearch = ->
            scope.search.term = null
            scope.blur()