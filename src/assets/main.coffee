gui = require("nw.gui")
$ = require("jquery")

win = gui.Window.get()
nativeMenuBar = new gui.Menu(type: "menubar")
try
  nativeMenuBar.createMacBuiltin "EasyPLV"
  win.menu = nativeMenuBar
catch ex
  console.log ex.message

window.logged = false

win.showDevTools() if window.gui.App.manifest.debug

process.on "uncaughtException", (e) ->
  console.log(e)
