class BadgeController
    constructor: (@store, @bambooService) ->
        store = @store
        chrome.browserAction.onClicked.addListener (tab) ->
            window.open(store.getUrl() + 'allPlans.action', '_newtab')

    run: () ->
        self = @
        @bambooService.getAllPlans (plans) ->
            self.loadPlans(plans)
        , @fail

    findPlan: (plans, key) ->
        found = null
        plans.map (plan) ->
            found =  plan if plan.key == key
        found

    loadPlans:  (plans) ->
        @currentPlan = @findPlan(plans, @store.getCurrentPlan())
        @testPlan = @findPlan(plans, @store.getTestPlan())
        @loadPlansStatus()

    loadPlansStatus: () ->
        self = @
        fail = @fail
        bambooService = @bambooService
        bambooService.getPlanResult self.currentPlan, (currentResult) ->
            bambooService.getPlanResult self.testPlan, (testResult) ->
                success = currentResult.isSuccessful() && testResult.isSuccessful();
                self.updateBrowserAction success, currentResult, testResult
                setTimeout(() ->
                           self.run()
                , 10000)
            , fail
        , fail

    updateBrowserAction: (success, currentResult, testResult) ->
        color = if success then [0, 200, 0, 200] else [200, 0, 0, 200]
        chrome.browserAction.setBadgeBackgroundColor color:color
        chrome.browserAction.setBadgeText text:currentResult.nextNumber()
        chrome.browserAction.setTitle title:'Current build 2.6.' + currentResult.nextNumber() + " / " + testResult.tests + " tests " + testResult.state.toLowerCase()

    fail: (error) ->
        console.log error
