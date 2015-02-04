$   = require("jquery")

class window.MegablastServerPlayer
  constructor: (@idx)->
    @name = ""
    @clientIndex = null
    @state = "preparing"

  data: =>
    {@name, @clientIndex, @idx}

class window.MegablastServer
  constructor: (@container)->
    @load()
    @gameIndexToClientIndex ||= {}
    @clientIndexToGameIndex ||= {}
    @players ||= {}
    @playersCount ||= 0
    @step ||= 0

  startGame: =>
    @playersCount = 0
    @initDeck()
    @serverGameId = parseInt(Math.random() * 10000)
    @resumeGame()

  resumeGame: =>
    @container.find("[data-server-action]").each (i, item) =>
      item = $(item)
      item.click =>
        @[item.data("server-action")]?()

    @connectToServer()
    @client = new MegablastClient @container
    @client.resumeGame()
    @showNextStep()

  showNextStep: =>
    $('.next-step').hide()
    $(".step-#{@step}").show()

  endGame: =>
    @sendToPlayers "endGame"
    for att in @persistedAttributes()
      @[att] = null
    @save()

  running: =>
    parseInt(@serverGameId) > 0

  persistedAttributes: =>
    ["players", "remainingCards", "remainingShips", "step", "serverGameId", "players", "clientIndexToGameIndex", "gameIndexToClientIndex", "playersCount"]

  load: =>
    for att in @persistedAttributes()
      raw = Store.get(att)
      @[att] = if raw? then JSON.parse(raw) else null

  save: =>
    for att in @persistedAttributes()
      if @[att]?
        Store.set att, JSON.stringify(@[att])
      else
        Store.expire att

  connectToServer: =>
    @connection = new WebSocket 'ws://localhost:8001'
    @connection.onopen = =>
      @connection.send("connectMeAsServer")
    @connection.onmessage = (message) =>
      [kind, meth, args...] = message.data.split("|")
      return unless kind == "server"
      params = []
      for item in args
        params.push JSON.parse item
      @[meth]?(params...)

  sendToPlayer: (idx, message, args...)=>
    params = []
    args ||= []
    for item in args
      params.push JSON.stringify item
    txt = "player|#{message}|#{@gameIndexToClientIndex[idx]}|#{params.join('|')}"
    @connection.send(txt)

  sendToPlayers: (message, args...)=>
    params = []
    args ||= []
    for item in args
      params.push JSON.stringify item
    txt = "players|#{message}|#{params.join('|')}"
    @connection.send(txt)

  playersList: =>
    out = []
    for k, v of @players
      out.push v
    out

  clientConnection: (id) =>
    playerIdx = @clientIndexToGameIndex[id]
    if playerIdx?
      player = @players[playerIdx]
    else
      @playersCount += 1
      playerIdx = @playersCount
      @clientIndexToGameIndex[id] = playerIdx
      @gameIndexToClientIndex[playerIdx] = id
      player = new MegablastServerPlayer(playerIdx)
      player.clientIndex = id
      @players[playerIdx] = player
      @save()


    @sendToPlayer playerIdx, 'hereIsYourIndex', playerIdx, @serverGameId, player.state
    @sendToPlayers 'setPlayers', @playersList()...

  imReady: (id, name)=>
    player = @players[id]
    player.name = name
    player.state = "ready"
    @save()
    @sendToPlayers 'updatePlayer', player

  initDeck: =>
    $.get './fixtures/cards.json', (res) =>
      @remainingCards = []
      for e in res
        @remainingCards.push e for [0..10]
      @save()

    $.get './fixtures/ships.json', (res) =>
      @remainingShips = []
      for e in res
        @remainingShips.push e for [0..10]
      @save()

  sendShips: =>
    for clientId, gameId of @clientIndexToGameIndex
      for i in [0..5]
        index = parseInt(Math.random() * @remainingShips.length)
        ship = @remainingShips[index]
        @remainingShips.splice(index, 1)
        @sendToPlayer gameId, "newShip", ship
    @step += 1
    @showNextStep()
    @save()

