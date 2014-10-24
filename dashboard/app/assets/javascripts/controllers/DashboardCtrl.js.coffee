@DashboardCtrl = ($scope, $http, $filter) ->
  $scope.get_dashboard = ->
    url = '/dashboard.json'
    $http.get(url).success((data) ->
      $scope.current_user = data.current_user
      $scope.sensors = data.sensors
      _init_realtime_updates()
      _touch_charts()
    )
    
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
      console.log("Connection is closed...");

  _touch_charts = ->
    _.each $scope.sensors, (sensor) ->
      _update_chart_data(sensor)

  _update_chart_data = (sensor) ->
    # sensor.chart_labels = (_.map sensor.measurements, (el) -> $filter('date')(el.created_at, 'hh:mm:ss')).reverse()
    sensor.chart_labels = _.map sensor.measurements, (el) -> '' # empty chart labels
    sensor.chart_data = [(_.map sensor.measurements, (el) -> el.temp_c)]
    

  $scope.get_dashboard()


