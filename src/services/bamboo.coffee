class BambooService
    constructor: (@store) ->

    load: (task, callback, fail) ->
        $('.loading').show();

        decorate = (func) ->
            (data) ->
                $('.loading').hide()
                func?(data)

        url = @store.getUrl() + '/rest/api/latest/' + task
        $.ajax(
            url     : url
            success : decorate(callback)
            error   : decorate(fail)
        )

    getPlanResult: (plan, success, fail) ->
        if plan == null
            return fail()

        @load('result/' + plan.key + '/?expand=results.result', (data)->
            success?(new Result($(data).find("result").first()))
        , fail)

    getAllPlans: (success, fail) ->
        self = @
        store = @store
        projects = {}
        plans = []

        loadPlans = (data) ->
            $(data).find("plan").each () ->
                plan = new Plan @
                plans.push plan
                projects[plan.projectKey()]?.addPlan plan

            success?(plans)

        loadProjects = (data) ->
            $(data).find("project").each () ->
                project = new Project @
                projects[project.key] = project

            self.load 'plan', loadPlans, fail

        @load 'project', loadProjects, fail

angular.module('BambooService', ['Store']).factory('bambooService', (store) ->
    new BambooService(store)
)
