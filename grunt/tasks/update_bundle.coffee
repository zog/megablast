Q = require 'q'
{run, each_pair} = require './utils'

module.exports = (grunt) ->
  grunt.registerMultiTask 'update_bundle', ->
    done = @async()
    version = arguments[0]
    Q.all each_pair @data.files, (k,src) ->
      r = if version
        run(__dirname + "/scripts/update_bundle.rb #{src} #{version}")
      else
        run(__dirname + "/scripts/update_bundle.rb #{src}")

      r.fail (reason) ->
        console.log reason.toString().red
      .then -> done()
