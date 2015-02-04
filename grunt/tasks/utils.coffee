{exec, spawn} = require 'child_process'
{print} = require 'util'
Q = require 'q'

module.exports =
  run: (command, options={}) ->
    defer = Q.defer()

    exec command, options, (err, stdout, stderr) ->
      if err?
        print stderr
        defer.reject(err)
      else
        print stdout
        defer.resolve()

    defer.promise

  execute: (command, options) ->
    defer = Q.defer()
    [command, args...] = command.split(/\s+/g)
    exe = spawn command, args, options
    exe.stdout.on 'data', (data) -> print data
    exe.stderr.on 'data', (data) -> print data
    exe.on 'exit', (status) ->
      if status is 0 then defer.resolve(status) else defer.reject(status)
    defer.promise

  each_pair: (o, block) -> block(k,v) for k,v of o
  merge: (a,b) ->
    o = {}
    o[k] = v for k,v of a
    o[k] = v for k,v of b
    o
