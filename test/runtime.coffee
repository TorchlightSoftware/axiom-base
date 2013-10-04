should = require 'should'
{focus} = require 'qi'

axiom = require 'axiom'
axiom.config = {timeout: 20}

logger = require 'torch'
#axiom.bus.addWireTap logger.yellow


identity = (args, done) -> done()

mods =
  base: require '..'

  server:
    config:
      run:
        base: 'runtime'
        stages:
          start: ['prepare', 'boot', 'connect']
          capture: ['diagnostics']
          stop: ['disconnect', 'shutdown', 'release']

  implementation:
    config:
      run:
        extends: 'server'
    services:
      "run/prepare": identity
      "run/boot": identity
      "run/connect": identity

loadMod = (name) ->
  axiom.load name, mods[name]

describe 'runtime', ->

  beforeEach ->
    axiom.reset()
    loadMod 'base'

  it 'should complete if no stages are implemented', (done) ->
    loadMod "server"
    axiom.request "server.run", {}, (err, status) ->
      should.not.exist err
      done()

  it 'should complete if all stages are implemented', (done) ->
    loadMod "server"
    loadMod "implementation"
    axiom.request "server.run", {}, (err, status) ->
      should.not.exist err
      done()

  it 'should call all stages', (done) ->
    loadMod "server"
    loadMod "implementation"

    # complete when all subtasks have been called
    cb = focus -> done()

    axiom.listen "server.run/prepare", cb()
    axiom.listen "server.run/boot", cb()
    axiom.listen "server.run/connect", cb()

    axiom.send "server.run", {}
