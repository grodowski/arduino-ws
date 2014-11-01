angular.module('Dashboard').filter 'reverse', ->
  return (items) ->
    if items
      items.slice().reverse();