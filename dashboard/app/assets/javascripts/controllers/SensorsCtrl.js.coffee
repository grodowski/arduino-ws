@SensorsCtrl = ($scope, $http, sensor_service) ->  
  $scope.add_sensor = -> 
    $scope.errors = null
    params = 
      authenticity_token: $scope.get_authenticity_token()
      device_uid: $scope.new_sensor_uid
      device_name: $scope.new_sensor_name
    success = (sensor) ->
      $scope.new_sensor_name = ''
      $scope.new_sensor_uid = ''
    error = (data) ->
      $scope.errors = data.errors  
    sensor_service.create params, success, error