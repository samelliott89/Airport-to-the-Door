qantasApp = angular.module 'qantasApp'

# Formats a string with colons every n characters.
#   e.g. '1234' => '12:34'
segment = (time, insertEvery = 2) ->
    # Reverse the string
    time = time.split('').reverse().join('')
    index = time.length - 1
    newTime = ''

    while index >= 0
        newTime += time[index]
        if index % insertEvery is 0
            newTime += ':'
        index -= 1

    # Remove the last character, which is always an extra colon
    return newTime[...-1]

formatWithHTML = (time, before, after) ->
    before ?= '<span class="text-muted">'
    after ?= '</span>'
    time = time.split('')
    newTime = []
    keepWrapping = true

    for i in [0...time.length]
        char = time.shift()
        if char in ['0', ':'] and keepWrapping
            newTime.push "#{before}#{char}#{after}"
        else
            newTime.push char
            keepWrapping = false

    return newTime.join('')

qantasApp.directive 'addTime', ($sce) ->
    restrict: 'A'
    replace: true
    templateUrl: 'templates/directives/addTime.html'
    scope:
        time: '=addTime'
    link: (scope) ->
        targetLength = 4
        _onTimeChange = (day = {keys: []}) ->
            remaining = Math.max(targetLength - day.keys.length, 0)
            padding = (new Array(remaining + 1)).join('0')
            value = day.keys.join('')
            displayValue = segment(padding + value)
            scope.displayHtml = $sce.trustAsHtml(formatWithHTML(displayValue))

        scope.$watch 'time', _onTimeChange, true