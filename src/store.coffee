class Store

    getUrl: () ->
        window.localStorage.url

    setUrl: (value) ->
        window.localStorage.url = value

    setUrlCorrectness: (value) ->
        window.localStorage.correctUrl = value

    getUrlCorrectness: () ->
        window.localStorage.correctUrl

    getCurrentPlan: () ->
        window.localStorage.currentPlan

    getTestPlan: () ->
        window.localStorage.testPlan

    saveCurrentPlan: (plan) ->
        window.localStorage.currentPlan = plan.key

    saveTestPlan: (plan) ->
        window.localStorage.testPlan = plan.key

    isCorrectUrl: () ->
        url = window.localStorage.url
        url != null && url != '' && window.localStorage.correctUrl

    isFirstRunning: () ->
        ok = !window.localStorage.installed
        window.localStorage.installed = true
        ok

angular.module('Store', []).factory('store', ($window) ->
    new Store
)