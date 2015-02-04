Q = require 'q'
{run, each_pair} = require './utils'

module.exports = (grunt) ->
  grunt.registerMultiTask 'webify', ->
    done = @async()
    @files.forEach (file) ->
      file.src.forEach (src) ->
        run("mv #{src} #{src}.bak; ../node_modules/browserify/bin/cmd.js #{src}.bak > #{src}; rm #{src}.bak")
