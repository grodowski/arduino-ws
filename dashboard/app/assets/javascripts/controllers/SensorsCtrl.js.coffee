@SensorsCtrl = ($scope, $http) ->  
  $scope.add_sensor = -> 
    $scope.errors = null
    params = 
      authenticity_token: $scope.get_authenticity_token()
      device_uid: $scope.new_sensor_uid
      device_name: $scope.new_sensor_name
    $http.post('/sensors.json', params).success( (sensor) ->
      $scope.sensors.push sensor
      $scope.new_sensor_name = ''
      $scope.new_sensor_uid = ''
    ).error( (data) ->
      $scope.errors = data.errors
    )