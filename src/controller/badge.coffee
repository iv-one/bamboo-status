class BadgeController
    constructor: (@store, @bambooService) ->
        store = @store

        if (store.isFirstRunning())
            chrome.tabs.create({url: "options.html"});

        chrome.browserAction.onClicked.addListener (tab) ->
            if (store.isCorrectUrl())
                window.open(store.getUrl() + '/allPlans.action', '_newtab')
            else
                chrome.tabs.create({url: "options.html"});

    run: () ->
        self = @
        fail = (error) -> self.fail(error)

        @bambooService.getAllPlans (plans) ->
            self.loadPlans(plans)
        , fail

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
        fail = (error) -> self.fail(error)

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
        @updateBrowserActionInfo success,
                                 currentResult.nextNumber(),
                                 'Current build 2.6.' + currentResult.nextNumber() + " / " + testResult.tests + " tests " + testResult.state.toLowerCase()

    updateBrowserActionInfo: (success, text, info) ->
        color = if success then [0, 200, 0, 200] else [200, 0, 0, 200]
        chrome.browserAction.setBadgeBackgroundColor color:color
        chrome.browserAction.setBadgeText text: text
        chrome.browserAction.setTitle title: info

    fail: (error) ->
        self = @
        @updateBrowserActionInfo false, '!', 'Can\'t connect to Bamboo'
        setTimeout(() ->
            self.run()
        , 2000)