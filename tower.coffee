'use strict';

MapUtil = require './map-util.coffee'

class Tower
  constructor: (@x, @y, challenge) ->
    @coordinates = [x, y]
    @path = challenge.map.path
    @range = challenge.stats.tower_range
    @pathPointsInRange = null

  xy: () -> @coordinates
  canShootAt: (point) ->
    if point.length? != 2 then false
    MapUtil.distanceBetween(@coordinates, point) <= @range


  getPathPointsInRange: () ->
    if @pathPointsInRange?
      return @pathPointsInRange

    @pathPointsInRange = []
    for point in @path
      if @canShootAt point then @pathPointsInRange.push point

    @getPathPointsInRange()

module.exports = Tower