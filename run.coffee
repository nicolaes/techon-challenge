'use strict';

class Run
  constructor: (actions, @challenge) ->
    @run = []

    @builds = actions.builds
    @shots = actions.shots

  parseBuilds: (towerBuilds) ->
    if (towerBuilds.length * @challenge.stats.tower_cost) > @challenge.stats.starting_money
      throw 'Can not build that many towers'

    builds = []
    for build, i in towerBuilds
      #build = {tower: Tower, colors: [DMG0, DMG1]}
      builds.push

      @run.push
        action: 'new_tower'
        frame: 0
        name: 'tower_' + i
        position: build.tower.xy()
        colors: build.tower.colors

  getOutcome: () ->
    if (@builds.length * @challenge.stats.tower_cost) > @challenge.stats.starting_money
      throw 'Can not build that many towers'

    outcome =
      money: @challenge.stats.starting_money
      life: @challenge.stats.starting_life

    for build in @builds
