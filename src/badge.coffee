dependencies = ['Store', 'BambooService']

angular.module('badge', dependencies).run((store, bambooService) ->
    window.badge = new BadgeController(store, bambooService)
    window.badge.run()
)
