class Store

    getUrl: () ->
        window.localStorage.url

    setUrl: (value) ->
        window.localStorage.url = value

    getCurrentPlan: () ->
        window.localStorage.currentPlan

    getTestPlan: () ->
        window.localStorage.testPlan

    saveCurrentPlan: (plan) ->
        window.localStorage.currentPlan = plan.key

    saveTestPlan: (plan) ->
        window.localStorage.testPlan = plan.key

angular.module('Store', []).factory('store', ($window) ->
    new Store
)