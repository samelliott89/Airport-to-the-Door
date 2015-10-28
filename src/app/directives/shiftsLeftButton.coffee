qantasApp = angular.module 'qantasApp'

qantasApp.directive 'shiftsLeftButton', ($rootScope, $timeout, nav) ->
    restrict: 'AE'
    templateUrl: 'templates/directives/shiftsLeftButton.html'
    link: (scope) ->
        scope.pendingConnections = $rootScope.pendingConnections
        $rootScope.$on 'shifts.pendingConnections.refreshed', (ev, pendingConnections) ->
            scope.pendingConnections = $rootScope.pendingConnections

        _do = ->
            $timeout ->
                scope.showMenuButton = nav.isFirstPage()
                scope.showBackButton = !nav.isFirstPage()
            , 1

        scope.appNavigator.on 'prepush', _do
        scope.appNavigator.on 'prepop', _do

        _do()