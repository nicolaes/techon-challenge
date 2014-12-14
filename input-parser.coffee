'use strict';

MapUtil = require './map-util.coffee'

class InputParser
  constructor: (inputFile) ->
    fs = require 'fs'
    data = fs.readFileSync inputFile, 'utf8'

    inputAreas = data.split("\n\n")
    @inputObj = {}
    @inputObj.stats = @parseStats inputAreas[0]
    @inputObj.bugs = @parseBugs inputAreas[1]
    @inputObj.map = @parseMap inputAreas[2]

  parseStats: (statsStr) ->
    statsLst = statsStr.trim().split('\n')
    if (statsLst.length != 5) then return {}

    statsObj =
      starting_life: null,
      starting_money: null,
      tower_range: null,
      tower_cost: null,
      reward_per_bug: null,
      colors: []
    for stat in statsLst
      [key, value] = stat.split('=')
      statsObj[key] = if (isNaN value) then value else parseInt(value)
    statsObj

  parseBugs: (bugsStr) ->
    bugLst = bugsStr.trim().split('\n')
    bugObj = []
    for bugStr, bugIndex in bugLst
      bug = {}
      bugStats = bugStr.split ' '

      # Get name and frame
      bug.name = bugStats.shift()
      bug.frame = parseInt(bugStats.pop().split('=')[1])

      # Get HP
      bug.hp = []
      for hpColorStr in bugStats
        [color, hp] = hpColorStr.split '='
        if bugIndex == 0 then @inputObj.stats.colors.push color
        bug.hp.push parseInt(hp)

      bugObj.push bug
    bugObj

  parseMap: (mapStr) ->
    mapObj = {path: []}
    mapCells = []
    mapLines = mapStr.trim().split('\n')
    for mapLine, y in mapLines
      lineCells = mapLine.trim().split(' ')
      for lineCell, x in lineCells
        if lineCell == '1' then mapCells.push [x, y]
        if lineCell == 'E' then mapStart = [x, y]
        if lineCell == 'X' then mapObj.pathEnd = [x, y]

    # Map itinerary
    mapObj.path.push mapStart
    lastPoint = mapStart
    maxIterations = 100
    while mapCells.length > 0 && maxIterations > 0
      maxIterations--
      for cell, cellIndex in mapCells
        if MapUtil.distanceBetween(cell, lastPoint) == 1
          thisCell = [cell[0], cell[1]]
          lastPoint = thisCell
          mapObj.path.push thisCell
          mapCells.splice cellIndex, 1
          break

    mapObj.size = mapLines.length
    mapObj

  getContents: -> @inputObj

module.exports = InputParser