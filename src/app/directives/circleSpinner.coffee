qantasApp = angular.module 'qantasApp'

qantasApp.directive 'circleSpinner', ->
    restrict: 'E'
    replace: true
    templateUrl: 'templates/directives/circleSpinner.html'