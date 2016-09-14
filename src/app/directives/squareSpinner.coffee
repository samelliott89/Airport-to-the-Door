qantasApp = angular.module 'qantasApp'

qantasApp.directive 'squareSpinner', ->
    restrict: 'E'
    replace: true
    templateUrl: 'templates/directives/squareSpinner.html'