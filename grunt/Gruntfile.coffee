clean = require './tasks/clean'
update_bundle = require './tasks/update_bundle'
webify = require './tasks/webify'

module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt);

  grunt.initConfig

    webify:
      web:
        files:
          src: ['../web/assets/*.js']

    clean:
      build:
        files:
          '../build': '../build'
      ship:
        files:
          '../megablast.app': '../megablast.app'

    update_bundle:
      ship:
        files:
          src: ['../src/Info.plist']

    connect:
      options:
        livereload: 35729

      livereload:
        options:
          open: true,
          base: ['../build/']

    #    ##      ##    ###    ########  ######  ##     ##
    #    ##  ##  ##   ## ##      ##    ##    ## ##     ##
    #    ##  ##  ##  ##   ##     ##    ##       ##     ##
    #    ##  ##  ## ##     ##    ##    ##       #########
    #    ##  ##  ## #########    ##    ##       ##     ##
    #    ##  ##  ## ##     ##    ##    ##    ## ##     ##
    #     ###  ###  ##     ##    ##     ######  ##     ##

    watch:
      config:
        files: ['Gruntfile.coffee', 'tasks/*.coffee']
        options:
          reload: true

      package:
        files: ['./package.json']
        tasks: ['npm:install']
        options:
          reload: true

      scripts:
        files: ['../src/assets/{,*/}*.coffee']
        tasks: ['coffeelint', 'coffee']
        options:
          livereload: true

      haml:
        files: ['../src/{,*/}*.haml']
        tasks: ['haml']
        options:
          livereload: true

      images:
        files: ['../src/assets/*.{png,jpg,jpeg,gif,webp,svg,js}', '../src/fixtures/*', '../src/node_modules/{,*/}*']
        tasks: ['copy']
        options:
          livereload: true

      others:
        files: ['../src/package.json']
        tasks: ['copy']
        options:
          livereload: true

      stylesheets:
        files: ['../src/assets/{,*/}*.sass']
        tasks: ['compass']
        options:
          livereload: true
          livereloadOnError: false

      web:
        files: ['../web/{,*/}*.{png,jpg,jpeg,gif,webp,svg,js,html}']
        options:
          livereload: true

      livereload:
        options:
          livereload: '<%= connect.options.livereload %>'
        files: [
          '../build/{,*/}*.html'
          '../build/assets/*'
        ]

      build:
        files: ['../build/{,*/}*']
        tasks: ['web']

    copy:
      build:
        files: [{
          expand: true
          dot: true
          cwd: '../src'
          dest: '../build'
          src: ['{,*/}*.{png,jpg,jpeg,gif,webp,svg,json,js}', 'node_modules/**']
        }]

      web:
        files: [{
          expand: true
          dot: true
          cwd: '../build'
          dest: '../web'
          src: ['**/*']
        }]

      ship:
        options:
          mode: true

        files: [{
          expand: true
          cwd: '../node-webkit.app'
          dest: '../megablast.app'
          src: ['**/*']
        },
        {
          expand: true
          cwd: '../build'
          mode: true
          dest: '../megablast.app/Contents/Resources/app.nw'
          src: ['**/*']
        },
        {
          src: '../src/package.json.ship',
          dest: '../megablast.app/Contents/Resources/app.nw/package.json'
        },
        {
          src: '../src/nw.icns',
          dest: '../megablast.app/Contents/Resources/nw.icns'
        },
        {
          src: '../src/Info.plist',
          dest: '../megablast.app/Contents/Info.plist'
        }]

    coffeelint:
      src: ['../src/assets/{,*/}*.coffee']
      options:
        no_backticks:
          level: 'ignore'
        no_empty_param_list:
          level: 'error'
        max_line_length:
          level: 'ignore'

    coffee:
      options:
        bare: true
        join: true

      build:
        files:
          [{
            expand: true,
            cwd: '../src/'
            src: '{,*/}*.coffee'
            dest: '../build'
            ext: '.js'
          }]

     haml:
      build:
        files: [{
          expand: true,
          cwd: '../src/',
          src: '{,*/}*.haml',
          dest: '../build',
          ext: '.html'
        }]

    compass:
      build:
        options:
          sassDir: '../src/assets/'
          cssDir: '../build/assets/'

  grunt.registerTask('build', [
    'clean:build'
    'compile:build'
    'compass:build'
    'haml:build'
    'copy:build'
  ])

  grunt.registerTask('web', [
    'copy:web'
    'webify:web'
  ])

  grunt.registerTask('ship', [
    'build'
    'clean:ship'
    'update_bundle:ship'
    'copy:ship'
  ])

  grunt.registerTask('compile:build', [
    'coffeelint'
    'coffee:build'
  ])

  clean(grunt)
  update_bundle(grunt)
  webify(grunt)

  grunt.registerTask('compile', ['compile:build'])
  grunt.registerTask('default', ['watch', 'build', 'web', 'connect:livereload'])
