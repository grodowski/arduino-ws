angular.module('Dashboard').filter 'reverse', ->
  return (items) ->
    items.slice().reverse();