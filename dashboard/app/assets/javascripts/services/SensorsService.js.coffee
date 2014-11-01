angular.module('Dashboard').factory 'sensor_service', ($http, $rootScope, $timeout) ->
  svc =
    data: []
    user: null 
    ws: null
    timeout: null
    
    fetch: -> 
      url = '/dashboard.json'
      $http.get(url).success((data) =>
        @user = data.current_user
        @data.length = 0
        @data.push.apply @data, data.sensors
        @_init_realtime_updates()
        @_touch_charts()
      )
    
    fetch_details: (sensor_id, offset, limit, success) -> 
      url = '/sensors/' + sensor_id + '.json'
      $http.get(url, {params: {offset: offset, limit: limit}}).success(success)
      
    create: (params, success, error) ->
      $http.post('/sensors.json', params).success( (sensor) =>
        @_ws_send({type: 'subscr', device_uid: sensor.device_uid})
        sensor.measurements = []
        @data.push sensor
        success sensor
      ).error( (data) =>
        error data
      )
      
    destroy: (sensor) -> 
      # TODO add remove feature
      return true
      
    is_active: (sensor) -> 
      if sensor.measurements && sensor.measurements.length > 0
        now = new Date()
        now - @last_activity(sensor) < 5000
    
    last_activity: (sensor) ->
      if sensor.measurements
        last_m =  sensor.measurements[sensor.measurements.length - 1]
        last = new Date(last_m.created_at)
    
    blank_chart_labels_for: (sensor) -> 
      (_.map sensor.measurements, (el) -> '')  
    
    chart_data_for: (sensor) -> 
      [(_.map sensor.measurements, (el) -> el.temp_c)]
    
    # Private Methods
    
    _ws_send: (data) ->
      json = JSON.stringify data
      @ws.send json
    
    _init_realtime_updates: ->
      if @ws
        return
      @ws = new WebSocket("ws://localhost:9001/" + @user._id.$oid);
      @ws.onopen = ->
        console.log "Client WebSocket open"
      @ws.onmessage = (evt) =>
        msg_o = JSON.parse(evt.data);
        if msg_o.type == 'data'
          sensor = _.find @data, (el) ->
            el.device_uid == msg_o.device_uid
          measurement = _.pick msg_o, 'temp_c', 'created_at', 'updated_at'
          if sensor.measurements && sensor.measurements.length > 20
            sensor.measurements.shift()
          sensor.measurements.push measurement
          @_update_chart_data(sensor)
          @_notify_watch()
      @ws.onclose = ->
        console.log('WebSocket closed') # TODO and try to reconnect
        @ws = null
    
    _touch_charts: ->
      _.each @data, (sensor) =>
        @_update_chart_data(sensor)
    
    _notify_watch: -> 
      $rootScope.$apply()
      @timeout = $timeout( -> 
        if @timeout
          @timeout.cancel()
          $rootScope.$apply()
      , 6000)
    
    _update_chart_data: (sensor) ->
      sensor.chart_labels = @blank_chart_labels_for(sensor)
      sensor.chart_data = @chart_data_for(sensor)
  return svc