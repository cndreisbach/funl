/*global module:false*/
module.exports = function(grunt) {
  var fs = require('fs');
  var file = grunt.file;
  var log = grunt.log;
  
  grunt.loadNpmTasks('grunt-exec');
  grunt.loadNpmTasks('grunt-contrib');
  
  // Project configuration.
  grunt.initConfig({
    exec: {
      mocha: {
        command: "mocha --no-colors",
        stdout: true,
        stderr: true
      }
    },
    lint: {
      files: ['grunt.js']
    },
    watch: {
      files: ['lib/**/*.js',
              '<config:lint.files>',
              'lib/funl.pegjs'],
      tasks: 'default'
    },
    jshint: {
      options: {
        curly: true,
        eqeqeq: true,
        immed: false,
        latedef: false,
        newcap: true,
        noarg: true,
        sub: true,
        undef: true,
        boss: true,
        eqnull: true,
        node: true,
        shadow: true
      },
      globals: {}
    }
  });

  grunt.registerTask('build-parser', 'Build our parser from its PEG file', function() {
    var PEG = require('pegjs');

    var data = file.read(__dirname + '/lib/funl.pegjs');
    var parser = PEG.buildParser(data, {trackLineAndColumn: true});

    file.write(__dirname + '/lib/funl-parser.js', "var FunL = module.exports = {};\n" +
                     "FunL.Parser = " + parser.toSource().replace("this.SyntaxError", "FunL.Parser.SyntaxError") + ";\n");
  });

  grunt.registerTask('test', 'build-parser lint exec:mocha');

  // Default task.
  grunt.registerTask('default', 'test');
};
