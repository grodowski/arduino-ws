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
    
    is_active: (sensor) -> 
      if sensor.measurements.length > 0
        now = new Date()
        now - @last_activity(sensor) < 3000
    
    last_activity: (sensor) ->
      last_m =  sensor.measurements[sensor.measurements.length - 1]
      last = new Date(last_m.created_at)
    
    # Private Methods
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
      sensor.chart_labels = _.map sensor.measurements, (el) -> '' # empty chart labels
      sensor.chart_data = [(_.map sensor.measurements, (el) -> el.temp_c)]
  return svc