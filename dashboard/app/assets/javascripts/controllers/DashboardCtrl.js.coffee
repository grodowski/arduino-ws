@DashboardCtrl = ($scope, $http, $filter, $timeout, sensor_service) ->
  $scope.get_dashboard = ->
    url = '/dashboard.json'
    $http.get(url).success((data) ->
      $scope.current_user = data.current_user
      $scope.sensors = data.sensors
      _init_realtime_updates()
      _touch_charts()
    )
  
  $scope.is_active = (sensor) -> 
    sensor_service().is_active(sensor)
    
  $scope.sensor_status = (sensor) -> 
    # TODO find a better solution for this problem
    $timeout( ->
      $scope.$apply();
    , 3000)
    if $scope.is_active(sensor)
      'active'
    else
      'last activity ' + $filter('date')(sensor_service().last_activity(sensor), 'dd/MM/yy HH:mm:ss')
    
  # TODO refactor into an angular Service
  _init_realtime_updates = ->
    ws = new WebSocket("ws://localhost:9001/" + $scope.current_user._id.$oid);
    ws.onopen = ->
      console.log "Client WebSocket open"
    ws.onmessage = (evt) ->
      msg_o = JSON.parse(evt.data);
      if msg_o.type == 'data'
        sensor = _.find $scope.sensors, (el) ->
          el.device_uid == msg_o.device_uid
        measurement = _.pick msg_o, 'temp_c', 'created_at', 'updated_at'
        sensor.measurements.shift()
        sensor.measurements.push measurement
        _update_chart_data(sensor)
        $scope.$apply()
        
    ws.onclose = ->
      $scope.show_flash('WebSocket closed')
      # TODO try to reconnect

  _touch_charts = ->
    _.each $scope.sensors, (sensor) ->
      _update_chart_data(sensor)

  _update_chart_data = (sensor) ->
    # sensor.chart_labels = (_.map sensor.measurements, (el) -> $filter('date')(el.created_at, 'hh:mm:ss')).reverse()
    sensor.chart_labels = _.map sensor.measurements, (el) -> '' # empty chart labels
    sensor.chart_data = [(_.map sensor.measurements, (el) -> el.temp_c)]
    

  $scope.get_dashboard()


