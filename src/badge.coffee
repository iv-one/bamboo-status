dependencies = ['Store',
                'BambooService']

angular.module('badge', dependencies).run((store, bambooService) ->
    console.log store
    console.log bambooService
    window.badge = new BadgeController(store, bambooService)
    window.badge.run()
)
