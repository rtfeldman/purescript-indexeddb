module.exports = (grunt) ->
  "use strict"

  grunt.initConfig
    srcFiles: ["src/**/*.purs", "bower_components/**/src/**/*.purs", "example/**/*.purs"]

    clean: ["dist"]

    copy:
      demo:
        src: "example/demo.html"
        dest: "dist/index.html"

    watch:
      html:
        files: ["example/*.html"]
        tasks: ["copy:demo"]

      purs:
        files: ["<%=srcFiles%>"]
        tasks: ["psc:all"]

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

    connect:
      static:
       options:
         port: 1337,
         base: 'dist'

  ["grunt-purescript", "grunt-contrib-connect", "grunt-contrib-clean", "grunt-contrib-copy", "grunt-contrib-watch"
  ].forEach (module) -> grunt.loadNpmTasks module
  grunt.registerTask "default", ["clean", "psc:all", "dotPsci", "copy", "connect", "watch"]