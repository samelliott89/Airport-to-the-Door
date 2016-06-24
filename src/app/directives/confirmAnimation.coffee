qantasApp = angular.module 'qantasApp'

qantasApp.directive 'confirmAnimation', ->
    restrict: 'E'
    replace: true
    templateUrl: 'templates/directives/confirmAnimation.html'