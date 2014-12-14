'use strict';

InputParser = require './input-parser.coffee'
Tower = require './tower.coffee'
Challenge = require './challenge.coffee'

challengeInput = new InputParser('input/c1').getContents()


challenge = new Challenge(challengeInput)
console.log challenge

# Test
console.log challenge.bugs
