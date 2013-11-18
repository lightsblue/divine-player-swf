module.exports = function(grunt) {

  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    source: 'src',
    release: 'release',
    test: 'test',
    temp: '.tmp',

    bump: {
      options: {
        files: ['package.json', 'bower.json'],
        commit: true,
        commitMessage: 'Release v%VERSION%',
        commitFiles: ['-a'], // '-a' for all files
        createTag: true,
        tagName: 'v%VERSION%',
        tagMessage: 'Version %VERSION%',
        push: true,
        pushTo: 'origin',
        gitDescribeOptions: '--tags --always --abbrev=1 --dirty=-d' // options to use with '$ git describe'
      }
    },

    clean: {
      swf: '<%= release %>',
      temp: '<%= temp %>'
    },

    exec: {
      check_for_mxmlc: {
        cmd: 'mxmlc --version',
        callback: function(error) {
          if (error) {
            grunt.log.writeln("Couldn't find Flex SDK on your path!");
            grunt.log.writeln('You can download it here: http://sourceforge.net/adobe/flexsdk/wiki/Flex%20SDK/');
          }
        }
      },

      /**
       * mxmlc produces a different SWF, even when the source has not changed.
       * This is because the binary includes the compilation timestamp. Unfortunately
       * there's nothing that can be done to prevent it.
       */
      build_swf: {
        cmd: [
          'mxmlc',
          '<%= source %>/Player.as',
          '-output <%= temp %>/divine-player.swf',
          '-load-config=flex-config.xml'
        ].join(' ')
      },

      build_tests: {
        cmd: [
          'mxmlc',
          '<%= test %>/unit/Runner.as',
          '-output <%= temp %>/divine-player-tests.swf',
          '-source-path+=<%= source %>',
          '-source-path+=lib/as3/src',
          '-load-config=flex-config.xml'
        ].join(' ')
      }
    },

    copy: {
      swf: {
        files: [{expand: true, cwd: '<%= temp %>', src: '*', dest: '<%= release %>', filter: 'isFile'}]
      }
    },

    connect: {
      options: {
        hostname: "*",
        port: 9001,
        keepalive: true,
        open: "http://localhost:<%= connect.options.port %>"
      },
      tests: {
        options: {
          base: [
            "<%= test %>/integration",
            "<%= release %>"
          ]
        }
      }
    }

  });

  grunt.registerTask('default', ['build']);

  grunt.registerTask('build', [
    'exec:check_for_mxmlc',
    'clean:swf',
    'exec:build_swf',
    'copy:swf',
    'clean:temp'
  ]);

  grunt.registerTask('test', [
    'exec:check_for_mxmlc',
    'clean:temp',
    'exec:build_tests',
    'copy:swf',
    'clean:temp',
    'connect:tests'
  ]);
};
