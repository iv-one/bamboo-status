var BadgeController, BambooService, Plan, Project, Result, SettingsController, Store, dependencies;

dependencies = ['Store', 'BambooService'];

angular.module('application', dependencies).config(function() {
  return true;
});

dependencies = ['Store', 'BambooService'];

angular.module('badge', dependencies).run(function(store, bambooService) {
  console.log(store);
  console.log(bambooService);
  window.badge = new BadgeController(store, bambooService);
  return window.badge.run();
});

BadgeController = (function() {

  function BadgeController(store, bambooService) {
    this.store = store;
    this.bambooService = bambooService;
    store = this.store;
    chrome.browserAction.onClicked.addListener(function(tab) {
      return window.open(store.getUrl() + 'allPlans.action', '_newtab');
    });
  }

  BadgeController.prototype.run = function() {
    var self;
    self = this;
    return this.bambooService.getAllPlans(function(plans) {
      return self.loadPlans(plans);
    }, this.fail);
  };

  BadgeController.prototype.findPlan = function(plans, key) {
    var found;
    found = null;
    plans.map(function(plan) {
      if (plan.key === key) return found = plan;
    });
    return found;
  };

  BadgeController.prototype.loadPlans = function(plans) {
    this.currentPlan = this.findPlan(plans, this.store.getCurrentPlan());
    this.testPlan = this.findPlan(plans, this.store.getTestPlan());
    return this.loadPlansStatus();
  };

  BadgeController.prototype.loadPlansStatus = function() {
    var bambooService, fail, self;
    self = this;
    fail = this.fail;
    bambooService = this.bambooService;
    return bambooService.getPlanResult(self.currentPlan, function(currentResult) {
      return bambooService.getPlanResult(self.testPlan, function(testResult) {
        var success;
        success = currentResult.isSuccessful() && testResult.isSuccessful();
        self.updateBrowserAction(success, currentResult, testResult);
        return setTimeout(function() {
          return self.run();
        }, 10000);
      }, fail);
    }, fail);
  };

  BadgeController.prototype.updateBrowserAction = function(success, currentResult, testResult) {
    var color;
    color = success ? [0, 200, 0, 200] : [200, 0, 0, 200];
    chrome.browserAction.setBadgeBackgroundColor({
      color: color
    });
    chrome.browserAction.setBadgeText({
      text: currentResult.nextNumber()
    });
    return chrome.browserAction.setTitle({
      title: 'Current build 2.6.' + currentResult.nextNumber() + " / " + testResult.tests + " tests " + testResult.state.toLowerCase()
    });
  };

  BadgeController.prototype.fail = function(error) {
    return console.log(error);
  };

  return BadgeController;

})();

SettingsController = function($scope, store, bambooService) {
  var fail, findPlan, loadPlans, reloadApi;
  reloadApi = function() {
    if (store.getUrl() !== '') return bambooService.getAllPlans(loadPlans, fail);
  };
  findPlan = function(plans, key) {
    var found;
    found = null;
    plans.map(function(plan) {
      if (plan.key === key) return found = plan;
    });
    return found;
  };
  loadPlans = function(plans) {
    $scope.plans = plans;
    $scope.currentPlan = findPlan(plans, store.getCurrentPlan());
    $scope.testPlan = findPlan(plans, store.getTestPlan());
    return $scope.$digest();
  };
  fail = function(error) {
    $scope.error = "Url '" + $scope.url + "' is not correct Bamboo API url";
    return $scope.$digest();
  };
  $scope.valid = false;
  $scope.button = ' disabled';
  $scope.url = store.getUrl();
  $scope.update = function() {
    store.setUrl($scope.url);
    return reloadApi();
  };
  $scope.save = function() {
    store.saveCurrentPlan($scope.currentPlan);
    return store.saveTestPlan($scope.testPlan);
  };
  if (store.getUrl() !== null) return reloadApi();
};

SettingsController.$inject = ['$scope', 'store', 'bambooService'];

Plan = (function() {

  function Plan(data) {
    this.enabled = $(data).attr('enabled');
    this.shortKey = $(data).attr('shortKey');
    this.shortName = $(data).attr('shortName');
    this.name = $(data).attr('name');
    this.key = $(data).attr('key');
    this.projectName = '';
  }

  Plan.prototype.projectKey = function() {
    return this.key.split("-")[0];
  };

  return Plan;

})();

Project = (function() {

  function Project(data) {
    this.plans = [];
    this.name = $(data).attr('name');
    this.key = $(data).attr('key');
  }

  Project.prototype.addPlan = function(plan) {
    this.plans.push(plan);
    return plan.projectName = this.name;
  };

  return Project;

})();

Result = (function() {

  function Result(data) {
    this.state = $(data).attr('state');
    this.number = parseInt($(data).attr('number'));
    this.tests = $(data).find('successfulTestCount').text();
  }

  Result.prototype.isSuccessful = function() {
    return this.state === "Successful";
  };

  Result.prototype.nextNumber = function() {
    return (this.number + 1).toString();
  };

  return Result;

})();

BambooService = (function() {

  function BambooService(store) {
    this.store = store;
  }

  BambooService.prototype.load = function(task, callback, fail) {
    var decorate, url;
    $('.loading').show();
    decorate = function(func) {
      return function(data) {
        $('.loading').hide();
        return typeof func === "function" ? func(data) : void 0;
      };
    };
    url = this.store.getUrl() + 'latest/' + task;
    return $.ajax({
      url: url,
      success: decorate(callback),
      error: decorate(fail)
    });
  };

  BambooService.prototype.getPlanResult = function(plan, success, fail) {
    return this.load('result/' + plan.key + '/?expand=results.result', function(data) {
      return typeof success === "function" ? success(new Result($(data).find("result").first())) : void 0;
    }, fail);
  };

  BambooService.prototype.getAllPlans = function(success, fail) {
    var loadPlans, loadProjects, plans, projects, self, store;
    self = this;
    store = this.store;
    projects = {};
    plans = [];
    loadPlans = function(data) {
      $(data).find("plan").each(function() {
        var plan, _ref;
        plan = new Plan(this);
        plans.push(plan);
        return (_ref = projects[plan.projectKey()]) != null ? _ref.addPlan(plan) : void 0;
      });
      return typeof success === "function" ? success(plans) : void 0;
    };
    loadProjects = function(data) {
      $(data).find("project").each(function() {
        var project;
        project = new Project(this);
        return projects[project.key] = project;
      });
      return self.load('plan', loadPlans, fail);
    };
    return this.load('project', loadProjects, fail);
  };

  return BambooService;

})();

angular.module('BambooService', ['Store']).factory('bambooService', function(store) {
  return new BambooService(store);
});

Store = (function() {

  function Store() {}

  Store.prototype.getUrl = function() {
    return window.localStorage.url;
  };

  Store.prototype.setUrl = function(value) {
    return window.localStorage.url = value;
  };

  Store.prototype.getCurrentPlan = function() {
    return window.localStorage.currentPlan;
  };

  Store.prototype.getTestPlan = function() {
    return window.localStorage.testPlan;
  };

  Store.prototype.saveCurrentPlan = function(plan) {
    return window.localStorage.currentPlan = plan.key;
  };

  Store.prototype.saveTestPlan = function(plan) {
    return window.localStorage.testPlan = plan.key;
  };

  return Store;

})();

angular.module('Store', []).factory('store', function($window) {
  return new Store;
});
