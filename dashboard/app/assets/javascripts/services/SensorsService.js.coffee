angular.module('Dashboard').factory 'sensor_service', ->
  svc = 
    is_active: (sensor) -> 
      if sensor.measurements.length > 0
        now = new Date()
        now - @last_activity(sensor) < 3000
    last_activity: (sensor) ->
      last_m =  sensor.measurements[sensor.measurements.length - 1]
      last = new Date(last_m.created_at)
  return -> 
    svc