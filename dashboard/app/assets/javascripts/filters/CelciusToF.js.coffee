angular.module('Dashboard').filter 'celcius_to_fahrenheit', ->
  return (val_c) ->
    Number(val_c * 1.8 + 32).toFixed(2)