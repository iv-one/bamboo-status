class Project
    constructor: (data) ->
        @plans = []
        @name  = $(data).attr 'name'
        @key   = $(data).attr 'key'

    addPlan: (plan) ->
        @plans.push plan
        plan.projectName = @name