@RootCtrl = ($scope, $location) ->
  $scope.navHome = ->
    $location.path('/')

  $scope.navAbout = ->
    $location.path('/about')
    
  $scope.show_flash = (msg) -> 
    alert(msg)
  
  $scope.get_authenticity_token = ->
    $('meta[name=csrf-token]').attr('content')