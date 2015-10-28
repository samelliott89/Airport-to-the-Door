qantasApp = angular.module 'qantasApp'

qantasApp.directive 'shiftsUserAction', (duration, nav) ->
    restrict: 'EA'
    replace: true
    templateUrl: 'templates/directives/shiftsUserAction.html'
    scope:
        users: '='
        listHeader: '@'
        acceptFunc: '&'
        declineFunc: '&'
    link: (scope) ->
        scope.nav = nav

        scope.accept = (user) -> scope.acceptFunc {friend: user}
        scope.decline = (user) -> scope.declineFunc {friend: user}
