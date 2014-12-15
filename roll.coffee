'use strict';

InputParser = require './input-parser.coffee'
Tower = require './tower.coffee'
Challenge = require './challenge.coffee'
Run = require './run.coffee'
brain = require 'brain'

challengeInput = new InputParser('input/c1').getContents()

challenge = new Challenge(challengeInput)
#console.log challenge

# Test
rand = (x, y) ->
  Math.round(Math.random() * (y - x + 1) + x)


towerCount = 2

# start randoming
trainings = []
life = -1000
bestRunParams = []
bestRunInputs = []
for iteration in [1..10]
  train =
    input: []
    output: []
  runParams =
    builds: []
    shots: []
  for i in [0..towerCount-1]
    towerDmg = []
    for color, colorIndex in challenge.stats.colors
      minHp = 100000
      for bug in challenge.bugs
        train.input.push bug.hp[colorIndex] # IN
        if bug.hp[colorIndex] < minHp then minHp = bug.hp[colorIndex]
      towerDmg[colorIndex] = rand(0, minHp/4)
      train.input.push towerDmg[colorIndex] # IN

    runParams.builds.push
      tower: challenge.getMostEfficientTowers()[i]
      colors: towerDmg
    for bug in challenge.bugs
      shots = rand(0, challenge.getMostEfficientTowers()[i].getPathPointsInRange().length)
      train.output.push shots # OUT
      if (shots > 0)
        runParams.shots.push
          tower: i
          bug: bug.name
          count: shots

  # calculate output
  run = new Run(runParams, challenge)
  runOutcome = run.getOutcome()

  # add life to inputs
  train.input.push runOutcome.life # IN
  trainings.push train

  # max life
  if life < runOutcome.life
    life = runOutcome.life
    bestRunParams = runParams
    bestRunInputs = train.input

# BRAIN - neural network training
console.log 'Training on ' + trainings.length + ' samples'
net = new brain.NeuralNetwork();
net.train(trainings);

console.log 'Best training life: ' + life
console.log '==================================='

# BRAIN - test for next 10 lifes
for i in [1..10]
  # Require a better life
  bestRunInputs[bestRunInputs.length - 1] = life + i

  # Run network
  generatedOutput = net.run(bestRunInputs)
  generatedOutput = generatedOutput.map Math.round

  # Use the output to update the input and check out the REAL life
  bestRunParams.shots = []
  for towerIdx in [0..towerCount-1]
    for bug in challenge.bugs
      shots = generatedOutput.shift()
      if (shots > 0)
        bestRunParams.shots.push
          tower: towerIdx
          bug: bug.name
          count: shots

  # calculate real-life output
  run = new Run(runParams, challenge)
  runOutcome = run.getOutcome()

  # Print results
  console.log 'Input expected life: '+life
  console.log 'RN-generated solution life: '+runOutcome.life


#console.log runParams, runParams.builds, train
