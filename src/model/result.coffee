class Result
    constructor: (data) ->
        @state     = $(data).attr 'state'
        @number    = parseInt($(data).attr 'number')
        @tests     = $(data).find('successfulTestCount').text()

    isSuccessful: () ->
        @state == "Successful"

    nextNumber: () ->
        (@number + 1).toString()
