SettingsController = ($scope, store, bambooService, alert) ->
    reloadApi = () ->
        bambooService.getAllPlans loadPlans, fail if (store.getUrl() != '')

    findPlan = (plans, key) ->
        found = null
        plans.map (plan) ->
            found =  plan if plan.key == key
        found

    loadPlans = (plans) ->
        store.setUrlCorrectness true
        alert.success "All plans was loaded"

        $scope.valid = true
        $scope.plans = plans
        $scope.currentPlan = findPlan(plans, store.getCurrentPlan())
        $scope.testPlan = findPlan(plans, store.getTestPlan())
        $scope.$digest()

    fail = (error) ->
        store.setUrlCorrectness false
        alert.error "Url '#{$scope.url}' is not correct Bamboo url"

        $scope.valid = false
        $scope.$digest()

    $scope.valid = false
    $scope.button = ' disabled'
    $scope.url = store.getUrl()

    $scope.update = () ->
        store.setUrl($scope.url.replace(/\/*$/g, ''))
        reloadApi()

    $scope.save = () ->
        $scope.button = ' disabled'
        store.saveCurrentPlan($scope.currentPlan)
        store.saveTestPlan($scope.testPlan)

        alert.success "Plans successfully saved"

    $scope.change = () ->
        $scope.button = '-primary'

    if (store.getUrl() != null && store.getUrl() != '')
        reloadApi()
    else
        alert.info "Please input your Bamboo URL"

SettingsController.$inject = ['$scope', 'store', 'bambooService', 'alert']