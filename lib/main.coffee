_ = require 'lodash'
logger = require 'torch'
async = require 'async'

module.exports =
  services:
    runtime:
      required: ['moduleName', 'serviceName', 'config', 'args', 'axiom']
      service: ({moduleName, serviceName, config, args, axiom}, finished) ->

        #{moduleName, serviceName, config, axiom} = @

        return done new Error "Invalid config - stages is required." unless config.stages

        # a helper to run the pipeline in series
        runPipeline = (args, steps, done) ->
          runStage = (stageName, next) ->
            #logger.yellow 'delegating:', "#{moduleName}.#{serviceName}/#{stageName}"
            axiom.delegate "#{moduleName}.#{serviceName}/#{stageName}", args, next
          async.forEachSeries steps, runStage, done

        # set up responders for each signal
        for signal, pipeline of config.stages when signal isnt 'start'
          #logger.yellow 'responding to signal:', "#{moduleName}.#{serviceName}/#{signal}"
          axiom.respond "#{moduleName}.#{serviceName}/#{signal}", (args, done) ->
            #logger.yellow "running #{signal} pipeline:", pipeline
            runPipeline args, pipeline, done

        axiom.link 'system.kill', "#{moduleName}.#{serviceName}/stop"

        # run the start signal
        #logger.yellow 'running pipeline:', config.stages.start
        runPipeline args, config.stages.start, finished
