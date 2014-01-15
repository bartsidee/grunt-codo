'use strict'

require 'coffee-script'

Codo = require 'codo/lib/codo'
Command = require 'codo/lib/command'
Table = require 'cli-table'

module.exports = (grunt) ->
  
  class GruntCommand extends Command
    constructor: ->
      @theme = @lookupTheme(@options.theme)
      @generate()
      
    generate: ->
      environment = Codo.parseProject(@options.basedir, @options)
      sections    = @collectStats(environment)
  
      @theme.compile(environment)
  
      if @options.undocumented
        for section, data of sections when data.undocumented.length != 0
          table = new Table
            head: [section, 'Path']
  
          table.push(entry) for entry in data.undocumented
          grunt.log.writeln table.toString()
          grunt.log.writeln ''
      else
        overall      = 0
        undocumented = 0
  
        for section, data of sections
          overall      += data.total
          undocumented += data.undocumented.length
  
        table = new Table
          head: ['', 'Total', 'Undocumented']
  
        table.push(
          ['Files', environment.allFiles().length, ''],
          ['Extras', environment.allExtras().length, ''],
          ['Classes', sections['Classes'].total, sections['Classes'].undocumented.length],
          ['Mixins', sections['Mixins'].total, sections['Mixins'].undocumented.length],
          ['Methods', sections['Methods'].total, sections['Methods'].undocumented.length]
        )
  
        grunt.log.writeln table.toString()
        grunt.log.writeln ''
        grunt.log.writeln "  Totally documented: #{(100 - 100/overall*undocumented).toFixed(2)}%"
        grunt.log.writeln ''
  

  grunt.registerTask "codo", "Generates Codo documentation", ->
      GruntCommand::options = @options({
        inputs: ["./src"],
        output: "./doc",
        theme: "default",
        basedir: process.cwd(),
        quiet: false,
        verbose: false,
        undocumented: false,
        closure: false,
        debug: true,
        "private": false,
        analytics: false,
        title: "Codo Documentation"
      })
      GruntCommand.run()
    