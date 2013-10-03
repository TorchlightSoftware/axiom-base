# Axiom-Base

This module contains base scripts for the Axiom environment.  These scripts implement general lifecycles which can be used to control your build, test, and runtime processes, amongst others.  For usage, see the [Axiom](https://github.com/torchlightsoftware/axiom) project.

# Standard Base Scripts

## Runtime

### Purpose

Use this base to define the stages in a running process.

### Sample Input

Assume we have an NPM module installed called 'axiom-server', and it has a config entry for 'run'.  Our base script might get something like this:

```coffee-script
moduleName: 'server'
serviceName: 'run'
config:
  base: 'runtime'
  stages:
    start: ['prepare', 'boot', 'connect']
    capture: ['diagnostics']
    stop: ['disconnect', 'shutdown', 'release']
```

### Interpretation

When the process starts (usually triggered by a CLI command), run the 'start' pipeline in series.  This will call the services ["server.start/prepare", "server.start/boot", "server.start/connect"].  This will affect services defined directly at that location (i.e. within the "axiom-server" module), as well as any services which extend "server".

Multiple services may be aliased to the names at each stage.  Those services will be executed in parallel, but the base script will wait until all services for a stage have completed or timed out before continuing to the next stage.

When the start pipeline has completed, the process will remain running, but no further work will be performed by Axiom.

When a kill signal is received, execute the 'stop' pipeline.  In addition, arbitrary signals/pipelines can be defined by the config.  In this case 'capture' is an example.  This can be triggered by any process calling "server.capture", and as a result axiom will execute the corresponding pipeline.

For most purposes arbitrary pipelines are probably not necessary, and the start/stop signals should be sufficient to organize the process runtime.

# Writing Your Own

Axiom-Base can be extended, just like any other Axiom module.  This is useful if you want to create your own base scripts.  We've tried to provide a set of scripts that cover most use cases, but if none of them works for you feel free to build your own.  We'd love to hear about new base scripts that you feel useful, and will consider adding these to Axiom-Base if they solve a general problem.

## Contract for a Base Script

Every base script can:

* Interpret a configuration file
* Use the Axiom-Core API to send messages/distribute work

Here is an example base script:

```coffee-script
myModule =
  config:
    stateMachine:
      extends: 'base'
  services:
    stateMachine: ({config, args, core}, done) ->
      # 1) interpret config
      # 2) implement state machine
      # 3) call core.delegate(serviceName, message, done) to distribute work
      # 4) subservices will respond if present
      # 5) call done() when all the work is done
```

## LICENSE

(MIT License)

Copyright (c) 2013 Torchlight Software <info@torchlightsoftware.com>

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
