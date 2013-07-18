_ = require('underscore')
{Player} = require './universe_player'
{Sprite} = require './universe_sprite'
{Prop} = require './universe_prop'
{QuadTree} = require './qtree'

exports.Server = class UniverseServer
  sizex: 800*4
  sizey: 600*4

  constructor: (@io) ->

    @universe = new QuadTree({l:0,b:0,r:@sizex,t:@sizey},40)
    @players = {}
    @sprites = {}
    @disconnected = {}
    @stop = false
    @toDestroy = []
    @lastDestroy = 0

    @totalProps = 50
    @props = {}
    
    @io.sockets.on 'connection', @onConnection

    # Islands
    for y in [0..200]
      x = new Sprite(@, {x:Math.round(Math.random()*@sizex), y:Math.round(Math.random()*@sizey)}, {x:0,y:0}, "isl"+Math.round(Math.random()*2) )
      #x = new Sprite(@, {x:Math.round(Math.random()*sizex), y:Math.round(Math.random()*sizey)}, {x:Math.round(Math.random()*20)-10, y:Math.round(Math.random()*20)-10}, "isl"+Math.round(Math.random()*2) )
      x.collides = false
      x.moves = false
      x.bearing = Math.round(Math.random()*360)
      @addSprite x

    _.delay(@gameTick,50)

    console.log @universe.maxDepth()

  onConnection: (socket) =>
    # Connection
    console.log("#{socket.id}: connect")
    # Watch Disconnect
    socket.on 'disconnect', (data) => @onDisconnect(socket,data)
    # Watch State
    socket.on 'command', (data) => @onCommand(socket,data)

    # Reconnect?
    if @disconnected[socket.id]
      delete @disconnected[socket.id]
      console.log("#{socket.id}: reconnected within timeout")
      return

    # Create Player
    @players[socket.id] ?= new Player(socket, @)
    player = @players[socket.id]
    player.lastPush = @getTime()

    # Reset
    socket.emit 'st', [{t:'rt'}]
    
    # Send What they can see
    @pushState(player)

  onDisconnect: (socket) =>
    console.log("#{socket.id}: onDisconnect")
    @disconnected[socket.id] = @players[socket.id]

    _.delay(=> 
      @reconnectTimeout(socket.id)
    , 5000)

  reconnectTimeout: (socketId) =>
    if @disconnected[socketId]?
      console.log("#{socketId}: reconnectTimeout")
      @players[socketId].destroy()
      delete @players[socketId]

  onCommand: (socket, data) =>
    switch data.t
      when 'r'
        @pushState(@players[socket.id],true)
      when 'tl'
        @players[socket.id].turnLeft()
      when 'tr'
        @players[socket.id].turnRight()
      when 'gf'
        @players[socket.id].speedUp()
      when 'gs'
        @players[socket.id].slowDown()
      when 'fi'
        @players[socket.id].fire()
      when 'st'
        #@players[socket.id].socket.emit 'st', [{t:'rt'}]
        @players[socket.id].name = data.name
        @players[socket.id].start()
      else
        console.log("onState - Unknown packet type '#{data.t}'")

  gameTick: =>
    # Get Time
    t = @getTime()

    # Update Props
    while (_.keys(@props).length<@totalProps)
      @newProp()

    # Update Players
    for id, player of @players when !@disconnected[id]
      player.update() 

    # Sprite Updates
    for id, sprite of @sprites
      # Update takes the current time and all possible sprites that may collide
      sprite.update(t, @getSpritesInBounds(sprite.getBoundary()))

    # Do Player Push Updates
    for id, player of @players when player.lastPush<t-50
      @pushState(player)
      player.lastPush = t 

    # Destroy old sprites every second
    if @lastDestroy<t-1000
      while @toDestroy.length>0
        sprite = @toDestroy.pop()
        sprite.removeFromUniverse()
        delete @sprites[sprite.id]
        @lastDestroy = t

    # Next Loop in 10ms
    _.delay(@gameTick,10) unless @stop

  pushState: (player) =>
    state = []

    # All other Players
    #state.push(p.getState()) for id,p of @players when id!=player.id

    # Sprites in player Viewport
    sb = @getSpritesInBounds(player.getScreenBounds())
    for id,sprite of sb when (!player.sprite? or id!=player.sprite.id)
      state.push(sprite.getState()) 

    # This Player
    state.push(player.getState())

    # Game State 
    state.push({t:'gs',sc:_.keys(@sprites).length,pc:_.keys(@players).length},tm:@getTime())
    player.socket.emit 'st', state

  getTime: =>
    (new Date().getTime())

  getSpritesInBounds: (bounds) =>
    pts = @universe.findRange(bounds)
    spr = {}
    spr[o.v.id] ?= o.v for o in pts
    spr

  destroySprite: (sprite) =>
    @toDestroy.push(sprite)

  addSprite: (sprite) =>
    #console.log("Sprite #{sprite.id} added")
    return if @sprites[sprite.id]?
    sprite.addToUniverse()
    @sprites[sprite.id] = sprite

  removeSprite: (sprite) =>
    sprite.removeFromUniverse()
    delete @sprites[sprite.id]

  explosionAt: (pos, speed, cls, owner) =>
    t = new Date().getTime()
    if cls == 'expl'
      pos.x -= 16
      pos.y -= 16
    x = new Sprite(@, pos, speed, cls)
    x.bearing = 0
    x.expiry = t+4000
    x.owner = owner
    x.collides = false
    @addSprite(x)

  newProp: =>
    switch Math.round(Math.random()*3)
      when 0
        type = 3
        cls = "hlt"
      when 1
        type = 4
        cls = "spd"
      when 2
        type = Math.round(Math.random()*2)
        cls = "pow"+type

    prop = new Prop(@, {x:Math.round(Math.random()*@sizex), y:Math.round(Math.random()*@sizey)}, {x:Math.round(Math.random()*10)-5,y:Math.round(Math.random()*10)-5}, cls, type )
    prop.bearing = 0
    @props[prop.id] = prop
    @addSprite(prop)

  removeProp: (prop) =>
    delete @props[prop.id]
    @destroySprite(prop)




