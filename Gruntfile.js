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
      build_swf: {
        cmd: 'mxmlc <%= source %>/Player.as -o <%= temp %>/divine-player.swf -use-network=false -static-link-runtime-shared-libraries=true'
      }
    },

    copy: {
      swf: {
        files: [{expand: true, cwd: '<%= temp %>', src: '*', dest: '<%= release %>', filter: 'isFile'}]
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
};
