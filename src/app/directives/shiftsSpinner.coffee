qantasApp = angular.module 'qantasApp'

qantasApp.directive 'shiftsSpinner', ->
    restrict: 'E'
    replace: true
    transclude: true
    templateUrl: 'templates/directives/shiftsSpinner.html'