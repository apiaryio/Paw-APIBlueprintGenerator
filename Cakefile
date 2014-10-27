{exec} = require "child_process"

task 'build', ->
  exec 'coffee --compile APIBlueprintGenerator.coffee'
  console.log "APIBlueprintGenerator.js has been built."

task 'watch', ->
  exec 'coffee --watch --compile APIBlueprintGenerator.coffee'

