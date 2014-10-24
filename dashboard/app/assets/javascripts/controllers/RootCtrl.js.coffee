@RootCtrl = ($scope, $location) ->
  $scope.add_panel_open = false
    
  $scope.navHome = ->
    $location.path('/')

  $scope.navAddSensor = ->
    $scope.open_panel()

  $scope.navSettings = ->
    $location.path('/settings')

  $scope.open_panel = -> 
    $scope.add_panel_open = ! $scope.add_panel_open
  
  $scope.close_panel = -> 
    $scope.add_panel_open = false
    