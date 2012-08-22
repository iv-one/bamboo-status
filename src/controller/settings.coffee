SettingsController = ($scope, store, bambooService) ->
    reloadApi = () ->
        bambooService.getAllPlans loadPlans, fail if (store.getUrl() != '')

    findPlan = (plans, key) ->
        found = null
        plans.map (plan) ->
            found =  plan if plan.key == key
        found

    loadPlans = (plans) ->
        $scope.plans = plans
        $scope.currentPlan = findPlan(plans, store.getCurrentPlan())
        $scope.testPlan = findPlan(plans, store.getTestPlan())
        $scope.$digest()

    fail = (error) ->
        $scope.error = "Url '#{$scope.url}' is not correct Bamboo API url"
        $scope.$digest()

    $scope.valid = false
    $scope.button = ' disabled'
    $scope.url = store.getUrl()

    $scope.update = () ->
        store.setUrl($scope.url)
        reloadApi()

    $scope.save = () ->
        store.saveCurrentPlan($scope.currentPlan)
        store.saveTestPlan($scope.testPlan)

    if (store.getUrl() != null)
        reloadApi()

SettingsController.$inject = ['$scope', 'store', 'bambooService']