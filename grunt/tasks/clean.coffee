Q = require 'q'
{run, each_pair} = require './utils'

module.exports = (grunt) ->
  grunt.registerMultiTask 'clean', ->
    done = @async()
    Q.all each_pair @data.files, (k,src) ->
      run("rm -rf #{src}")
      .then ->
        console.log "Removed #{src.magenta}"

    .then -> done()
    .fail (reason) ->
      console.log reason.toString().red
