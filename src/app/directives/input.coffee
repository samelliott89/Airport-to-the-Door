qantasApp = angular.module 'qantasApp'

qantasApp.directive 'textInput', ->
    restrict: 'C'
    link: (scope, element) ->
        _do = ({target}) ->
            if target.value.length
                target.classList.add 'ng-has-text'
            else
                target.classList.remove 'ng-has-text'

        element.on 'keyup', _do

        scope.$on '$destroy', ->
            element.off 'keyup', _do