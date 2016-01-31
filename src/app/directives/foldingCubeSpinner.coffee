qantasApp = angular.module 'qantasApp'

qantasApp.directive 'foldingCubeSpinner', ->
    restrict: 'E'
    replace: true
    templateUrl: 'templates/directives/foldingCubeSpinner.html'