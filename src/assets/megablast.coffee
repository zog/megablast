ws  = require("ws")
$   = require("jquery")

hideMenu = =>
  $('.menu').hide()

$(document).ready ->
  window.blast = new MegablastServer $("body")
  if window.blast.running()
    hideMenu()
    window.blast.resumeGame()
  else
    window.blast = new MegablastClient $("body")
    if window.blast.running()
      hideMenu()
      window.blast.resumeGame()
    else
      $(".server").click =>
        hideMenu()
        window.blast = new MegablastServer $("body")
        window.blast.startGame()
      $(".client").click =>
        hideMenu()
        window.blast = new MegablastClient $("body")
        window.blast.startGame()

  $(".kill").click =>
    console.log "kill"
    window.blast.endGame()

  $(".reload").click =>
    console.log "reload"
    location.reload()
