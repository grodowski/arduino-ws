@SensorsCtrl = ($scope) ->

  $scope.sensors = [
    {device_name: 'Storage', device_uid: 'sensor1'},
    {device_name: 'Main Hall', device_uid: 'sensor2'}
  ]

  $scope.editSensor = (sensor) ->
