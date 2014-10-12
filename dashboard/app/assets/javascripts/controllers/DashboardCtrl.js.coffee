@DashboardCtrl = ($scope, $http) ->
  $scope.get_dashboard = ->
    url = '/dashboard.json'
    $http.get(url).success((data) ->
      $scope.sensors = data.sensors
      $scope.init_realtime_updates()
    )


  # TODO refactor into an angular Service
  $scope.init_realtime_updates = ->
    ws = new WebSocket("ws://localhost:9001");
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
        $scope.$apply()
    ws.onclose = ->
      console.log("Connection is closed...");

  $scope.get_dashboard()


