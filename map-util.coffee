'use strict';

class MapUtil
  @distanceBetween: (a, b) ->
    Math.ceil Math.sqrt(Math.pow(a[0] - b[0], 2) + Math.pow(a[1] - b[1], 2))
  @eq: (a, b) ->
    a[0] == b[0] and a[1] == b[1]

module.exports = MapUtil