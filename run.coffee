'use strict';

deepcopy = require 'deepcopy'

class Run
  constructor: (actions, @challenge) ->
    @run = []

    # [{tower: Tower, colors: [DMG0, DMG1]}]
    @builds = actions.builds
    # [{tower: towerIndex, bug: bugName, count: C}]
    @shots = actions.shots

  parseBuilds: (towerBuilds) ->
    if (towerBuilds.length * @challenge.stats.tower_cost) > @challenge.stats.starting_money
      throw 'Can not build that many towers'

    builds = []
    for build, i in towerBuilds
      builds.push

      @run.push
        action: 'new_tower'
        frame: 0
        name: 'tower_' + i
        position: build.tower.xy()
        colors: build.tower.colors

  getOutcome: () ->
    outcome =
      money: @challenge.stats.starting_money
      life: @challenge.stats.starting_life

    if (@challenge.bugs.length == 0)
      throw 'No bugs to damage - you win! :)'

    # Substract tower costs
    outcome.money -= @builds.length * @challenge.stats.tower_cost

    frame = 0
    waitingBugs = deepcopy @challenge.bugs
    liveBugs = []

    while waitingBugs.length > 0 or liveBugs.length > 0
      @moveBugs frame, waitingBugs, liveBugs, outcome
      @shootBugs frame, liveBugs, outcome
      frame++

    return outcome

  moveBugs: (frame, waitingBugs, liveBugs, outcome) ->
    bugDamage = 0

    liveBugsToDelete = []
    for liveBug, i in liveBugs
      liveBug.pathIndex++
      if liveBug.pathIndex >= @challenge.map.path.length
        liveBugsToDelete.push i

    # Remove all bugs at the end from the map + compute the damage
    # (delete from the last to the first to avoid index change)
    liveBugsToDelete.sort (a, b) -> b - a
    for liveBugToDelete in liveBugsToDelete
      [bug] = liveBugs.splice liveBugToDelete, 1
      bugDamage += bug.hp.reduce (a, b) -> a + b

    while waitingBugs.length > 0 && waitingBugs[0].frame <= frame
      newBug = waitingBugs.shift()
      newBug.pathIndex = 0
      liveBugs.push newBug

    outcome.life -= bugDamage

  shootBugs: (frame, liveBugs, outcome) ->
    collateralDamage = 0
    bugReward = 0

    for liveBug in liveBugs
      bugLocation = @challenge.map.path[liveBug.pathIndex]
      for shot in @filterShots(liveBug)
        collateralDamage += @applyDamageToBug liveBug.hp, @builds[shot.tower].colors
        shot.count--

    outcome.life -= collateralDamage
    outcome.money += bugReward

  filterShots: (liveBug) ->
    # this = {name: 'B1', frame: 0, hp: [ 57, 39 ], pathIndex: 0}
    # shot = {tower: Tower, bug: bugName, count: C}
    shots = []
    for shot in @shots
      if liveBug.name == shot.bug and shot.count > 0 and
          @builds[shot.tower].tower.canShootAt(@challenge.map.path[liveBug.pathIndex])
        shots.push shot
    shots

  applyDamageToBug: (bugHp, towerDmg) ->
    damage = 0
    for bugColorHp, bugColorIndex in bugHp
      if (bugColorHp >= towerDmg[bugColorIndex])
        # No collateral damage
        bugHp[bugColorIndex] = bugColorHp - towerDmg[bugColorIndex]
      else
        # Collateral damage
        bugHp[bugColorIndex] = 0
        damage += towerDmg[bugColorIndex] - bugColorHp
    damage


module.exports = Run