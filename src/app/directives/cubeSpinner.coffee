qantasApp = angular.module 'qantasApp'

qantasApp.directive 'cubeSpinner', ->
    restrict: 'E'
    replace: true
    templateUrl: 'templates/directives/cubeSpinner.html'