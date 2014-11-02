@SensorDetailCtrl = ($scope, $http, $routeParams, sensor_service) ->         
  $scope.status =
    offset: -5000
    limit: 5000
        
  $scope.fetch_sensor = -> 
    $scope.status.loading = true
    offset = $scope.status.offset
    limit = $scope.status.limit
    sensor_service.fetch_details $routeParams.sensor_id, offset, limit, (data) ->
      $scope.sensor = data.sensor
      $scope.sensor.measurements_count = data.measurements_count
      $scope.chart_options = if $scope.sensor.measurements_count > 100 then _dense_chart_options else _sparse_chart_options 
      _init_chart()
      _update_status()
      
  $scope.move_left = ->
    $scope.status.offset = $scope.status.offset - $scope.status.limit
    $scope.fetch_sensor()
  
  $scope.move_right = -> 
    $scope.status.offset = $scope.status.offset + $scope.status.limit
    if $scope.status.offset > -$scope.status.limit 
      $scope.status.offset = -$scope.status.limit 
    $scope.fetch_sensor()
  
  # Private Methods
  _update_status = -> 
    $scope.status.end_time = $scope.sensor.measurements[$scope.sensor.measurements.length-1].created_at
    $scope.status.start_time = $scope.sensor.measurements[0].created_at
    $scope.status.loading = false
  
  _init_chart = ->
    $scope.chart_data = sensor_service.chart_data_for($scope.sensor)
    $scope.chart_labels = sensor_service.blank_chart_labels_for($scope.sensor)

  _sparse_chart_options = 
    showTooltips: true
    animate: true
    pointDot: true
    pointDotRadius: 4
    pointDotStrokeWidth: 1
    pointHitDetectionRadius: 1
  
  _dense_chart_options =
    showTooltips: false
    scaleShowGridLines: false
    animate: true
    pointDot: false
    pointDotRadius: 0
    pointDotStrokeWidth: 0
    pointHitDetectionRadius: 0.2
    datasetStroke: false
    datasetStrokeWidth: 0
    
  $scope.fetch_sensor()