SettingsController = ($scope, store, bambooService, alert) ->
    reloadApi = () ->
        bambooService.getAllPlans loadPlans, fail if (store.getUrl() != '')

    findPlan = (plans, key) ->
        found = null
        plans.map (plan) ->
            found =  plan if plan.key == key
        found

    loadPlans = (plans) ->
        alert.success "All plans was loaded"
        $scope.plans = plans
        $scope.currentPlan = findPlan(plans, store.getCurrentPlan())
        $scope.testPlan = findPlan(plans, store.getTestPlan())
        $scope.$digest()

    fail = (error) ->
        alert.error "Url '#{$scope.url}' is not correct Bamboo url"

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

SettingsController.$inject = ['$scope', 'store', 'bambooService', 'alert']