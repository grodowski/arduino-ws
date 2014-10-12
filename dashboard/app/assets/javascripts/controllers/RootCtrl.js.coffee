@RootCtrl = ($scope, $location) ->
  $scope.navHome = ->
    $location.path('/')

  $scope.navSensors = ->
    $location.path('/sensors')

  $scope.navSettings = ->
    $location.path('/settings')