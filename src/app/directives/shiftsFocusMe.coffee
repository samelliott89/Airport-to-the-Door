qantasApp = angular.module 'qantasApp'

qantasApp.directive 'shiftsFocusOn', ->
    link: (scope, ele, attr) ->
        scope.$on 'focusOn', (e, name) ->
            if name is attr.shiftsFocusOn
                ele[0].focus()

qantasApp.factory 'focus', ($rootScope, $timeout) -> (name) ->
    $timeout ->
        $rootScope.$broadcast 'focusOn', name