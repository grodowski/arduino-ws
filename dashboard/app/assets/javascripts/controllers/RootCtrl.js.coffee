@RootCtrl = ($scope, $location) ->
  $scope.navHome = ->
    $location.path('/')

  $scope.navSettings = ->
    $location.path('/settings')
    
  $scope.show_flash = (msg) -> 
    alert(msg)
  
  $scope.get_authenticity_token = ->
    $('meta[name=csrf-token]').attr('content')