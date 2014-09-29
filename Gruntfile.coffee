module.exports = (grunt) ->
  "use strict"

  grunt.initConfig
    srcFiles: ["src/**/*.purs", "bower_components/**/src/**/*.purs", "example/**/*.purs"]

    psc:
      options:
        main: "Demo"
        modules: ["IndexedDB", "Demo"]

      all:
        src: ["<%=srcFiles%>"]
        dest: "dist/demo.js"

    pscMake:
      options:
        modules: ["IndexedDB"]

      all:
        src: ["<%=srcFiles%>"]
        dest: "dist/"

    dotPsci: ["<%=srcFiles%>"]

  grunt.loadNpmTasks "grunt-purescript"
  grunt.registerTask "default", ["psc:all", "dotPsci", "connect"]