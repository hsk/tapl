module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    watch: {
      all: {
        files: ["**/**.ml*","**/**.f", "**/**.php"],
        tasks: ["exec"]
      }
    },
    exec: {
      make: {
        command: "make test || osascript -e 'display notification \"test error\" with title \"Make test\"'"
      }
    }
  });
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-exec');
  grunt.registerTask('default', ['exec', 'watch']);
};
