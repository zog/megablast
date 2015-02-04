$   = require("jquery")

class window.MegablastPlayer
  constructor: (@data) ->
    @healthPoints = 8
    @index = @data.idx

  name: =>
    @data.name || "Player #{@index}"

  state: =>
    @data.state || "preparing"

  health: =>
    "#{@data.healthPoints || 8} PV"

  ownPlayer: =>
    "#{@blast.idx}" == "#{@index}"

  drawShips: =>
    return unless @ownPlayer()
    ships = @container.find(".ships")
    shipTemplate = ships.find(".template")
    ships.find('.ship:not(.template)').remove()
    for ship in @blast.ships
      div = shipTemplate.clone()
      div.removeClass 'template'
      div.find("[data-attribute]").each (i, item) =>
        item = $(item)
        item.html ship[item.data("attribute")]
      div.appendTo ships

  draw: (@blast)=>
    div = @blast.container.find(".player-#{@index}")
    unless div.length > 0
      @template = @blast.container.find('.player-template')
      div = @template.clone()
      div.removeClass 'player-template'
      div.addClass 'me' if @ownPlayer()
      div.addClass "player-#{@index}"

    div.find("[data-attribute]").each (i, item) =>
      item = $(item)
      val = @[item.data("attribute")]?()
      item.html val
      if item.attr("data-sameclass")?
        item.removeClass item.attr "data-sameclass"
        item.addClass val
        item.attr "data-sameclass", val

    div.appendTo @blast.container
    @container = div
    @drawShips()

class window.MegablastClient
  constructor: (@container)->
    @players = {}
    @load()
    unless @clientIdx
      @clientIdx = parseInt(Math.random() * 10000)
      @save()
    @ships ||= []
    @cards ||= []
    @name  ||= ""
    @state ||= "preparing"

  startGame: =>
    @connectToServer()

  resumeGame: =>
    @startGame()

  startOrResumeGame: =>
    if @running() then @resumeGame() else @startGame()

  endGame: =>
    for att in @persistedAttributes()
      continue if att == "clientIdx"
      continue if att == "name"
      @[att] = null
    @save()
    location.reload()

  running: =>
    parseInt(@gameId) > 0

  connectToServer: =>
    @connection = new WebSocket 'ws://localhost:8001'
    @connection.onopen = =>
      @sendToServer 'clientConnection', @clientIdx

    @connection.onmessage = (message) =>
      Logger.log message.data

      [kind, meth, args...] = message.data.split("|")
      return if kind == "server"
      if kind == "player"
        [clientIdx, args...] = args
        return unless "#{clientIdx}" == "#{@clientIdx}"
      params = []
      args ||= []
      for item in args
        continue unless item.length > 0
        params.push JSON.parse item
      @[meth]?(params...)

  sendToServer: (message, args...)=>
    params = []
    for item in args
      params.push JSON.stringify item
    txt = "server|#{message}|#{params.join('|')}"
    @connection.send(txt)

  hereIsYourIndex: (idx, gameId, state)=>
    @idx = parseInt idx
    @gameId = gameId
    @state = state
    @save()
    unless @state == "ready"
      @container.find('.name-form').show()
      @container.find('.name-form input[name=name]').val @name
      @container.find('.name-form a.imready').click =>
        @container.find('.name-form').hide()
        @name = @container.find('.name-form input[name=name]').val()
        @sendToServer "imReady", @idx, @name
        @state = "ready"
        @save()

  setPlayers: (players...)=>
    for player in players
      @addPlayer(player) unless @players[player.idx]?

  addPlayer: (data)=>
    newPlayer = new MegablastPlayer(data)
    @players[data.idx] = newPlayer
    newPlayer.draw(@)

  updatePlayer: (playerData)=>

    player = @players[playerData.idx]
    player.data = playerData
    player.draw(@)

  ownPlayer: =>
    @players[@idx]

  persistedAttributes: =>
    ["gameId", "clientIdx", "ships", "cards", "name", "state"]

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

  newShip: (ship)=>
    @ships ||= []
    @ships.push ship
    @save()
    @ownPlayer().drawShips()
