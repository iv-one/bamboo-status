class Alert
    constructor: () ->
        @name = '.alerts'
        @index = 0

    error: (message) ->
        @show 'Error!', message, 'error'

    success: (message) ->
        @show 'Success!', message, 'success'

    show: (title, message, type) ->
        @index++

        template = @getTemplate title, message, type, @index
        $(@name).append(template)

        alert = ".alert-#{@index}"
        close = ".close-#{@index}"

        $(alert).fadeIn()
        $(close).click(() ->
            $(alert).fadeOut()
        )

    getTemplate: (title, message, type, index) ->
        "<div class='alert alert-#{index} alert-#{type} fade in hide'><button class='close close-#{index}'>×</button><strong>#{title}</strong> #{message}</div>"

angular.module('Alert', []).factory('alert', ($window) ->
    new Alert
)
