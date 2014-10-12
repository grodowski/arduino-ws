@RootCtrl = ($scope, $location) ->
  $scope.navHome = ->
    $location.path('/')

  $scope.navSensors = ->
    $location.path('/sensors')
    console.log 'lollol'

  $scope.navSettings = ->
    $location.path('/settings')