angular.module('Dashboard').filter('sensor_status', ['dateFilter', 'sensor_service', (date_filter, sensor_service) ->
  return (sensor) -> 
    if sensor_service.is_active(sensor)
      'active'
    else
      'last activity ' + date_filter(sensor_service.last_activity(sensor), 'dd/MM/yy HH:mm:ss')
])
angular.module('Dashboard').filter('latest_sensor_value', ->
  return (sensor) ->
    if sensor.measurements && sensor.measurements.length > 0
      sensor.measurements[sensor.measurements.length - 1].temp_c
    else
      ''
)
    