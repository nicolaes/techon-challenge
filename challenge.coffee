'use strict';

MapUtil = require './map-util.coffee'
Tower = require './tower.coffee'

class Challenge
  constructor: (inputObj) ->
    @stats = inputObj.stats
    @bugs = inputObj.bugs
    @map = inputObj.map

    # Other instance variables
    @mostEfficientTowers = []
    @allPossibleTowersByXY = []
    @allPossibleTowers = []

  getMaxNumberOfTowers: () ->
    Math.floor((@stats.starting_money + @bugs.length * @stats.reward_per_bug) / @stats.tower_cost)

  getMostEfficientTowers: (limit = @getMaxNumberOfTowers() - 1) ->
    if @mostEfficientTowers.length
      return @mostEfficientTowers.slice(0, limit)

    sortTowersByEfficiency = (towerA, towerB) ->
      towerB.getPathPointsInRange().length - towerA.getPathPointsInRange().length

    @mostEfficientTowers = @getAllPossibleTowers().slice().sort(sortTowersByEfficiency)
    @getMostEfficientTowers(limit)

  getAllPossibleTowers: () ->
    if @allPossibleTowers.length
      return @allPossibleTowers

    for x in [0..(@map.size - 1)]
      @allPossibleTowersByXY[x] = []
      for y in [0..(@map.size - 1)]
        if @canPlaceTowerAt([x, y])
          tower = new Tower(x, y, @)
          @allPossibleTowersByXY[x][y] = tower
          @allPossibleTowers.push tower
        else
          @allPossibleTowersByXY[x][y] = null

    @getAllPossibleTowers()

  canPlaceTowerAt: (towerXY) ->
    if MapUtil.eq(towerXY, @map.pathEnd) then return false

    # Tower needs to be off the path, but in range of it
    minDistance = (@map.size - 1) * 2 # maximum possible distance on this map
    for pathPoint in @map.path
      if MapUtil.eq(towerXY, pathPoint) then return false
      distance = MapUtil.distanceBetween(towerXY, pathPoint)
      if distance < minDistance then minDistance = distance

    return minDistance <= @stats.tower_range

module.exports = Challenge