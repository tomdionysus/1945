class App.G1945GameView extends Mozart.View
  skipTemplate: true
  classHtml: 'g1945screen'
  width:800
  height:600

  keysDown: {}

  stop: false
  maxowner: 0

  init: ->
    super
    window.addEventListener 'keydown', @checkKeyDown
    window.addEventListener 'keyup', @checkKeyUp
    window.addEventListener 'blur', @clearKeys

    App.socketIoController.connect()
    App.socketIoController.bind('gameEvent', @gameEvent)

    @player = {pos:{x:0,y:0},speed:{x:0,y:0}}
    @releaseQueue = []

    @l1945 = $('<div>').addClass('g1945-logo')
    @spacetoplay = $('<div>').addClass('g1945-spacetoplay')
    @gameover = $('<div>').addClass('g1945-gameover')

    @health = $('<div>').addClass('g1945-healthBar')

    @state = 0

  release: ->
    App.socketIoController.unbind('gameEvent', @gameEvent)
    App.socketIoController.disconnect()

  logo: (ele,disp) ->
    if disp
      @element.append(ele)
    else
      ele.detach()

  newState: =>
    switch @state 
      when 0
        # Died, remove sprite etc.
        if App.g1945Controller.player?
          @removeSprite(App.g1945Controller.player)
          delete App.g1945Controller['player']
          @logo(@gameover,true)

        @logo(@l1945, true)
        @logo(@spacetoplay, true)
        @logo(@health, false)

      when 1
        @logo(@l1945, false)
        @logo(@spacetoplay, false)
        @logo(@gameover, false)
        @logo(@health, true)

        if App.g1945Controller.player?
          App.g1945Controller.player.unbind('change:health', @redoHealth)

        # Now Playing
        App.g1945Controller.player = @layout.createView App.G1945PlayerView,
          parent: @
          pos: {x:368,y:268}
          speed: {x:0,y:0}
        App.g1945Controller.player.bind('change:health', @redoHealth)
        @addSprite(App.g1945Controller.player)

        App.g1945Controller.player.set 'score', 0
        App.g1945Controller.player.set 'health', 100

        @redoHealth()

  redoHealth: =>
    @health.attr('style','width:'+App.g1945Controller.player.health+"px")

  gameEvent: (packets) =>
    spritesdrawn = {}
    for packet in packets
      switch packet.t
        when 'ps'
          # Player State
          if packet.st? and @state != packet.st
            @state = packet.st
            @newState()
            break

          else if @state == 1
            @player = {pos:packet.pos,speed:packet.sp,bearing:packet.br}
            App.g1945Controller.player.set 'bearing', packet.br
            App.g1945Controller.player.set 'health', packet.hl
            @screenPos = @addVector(packet.pos,{x:368,y:268},{x:-1,y:-1})
            App.g1945Controller.player.element.attr 'class',"g1945-"+packet.cs
          else

        when 'ss'
          # Sprite State
          @updateSprite(packet)
          spritesdrawn[packet.id] = packet

        when 'gs'
          true
          # Game State
    
    spritesdrawn[App.g1945Controller.player.id] = 1 if App.g1945Controller.player?

    deadsprites = _.difference(_.keys(@childViews), _.keys(spritesdrawn))
    for i in deadsprites
      @removeSprite(@childViews[i])

  updateSprite: (packet) =>
    unless @childViews[packet.id]?
      #console.log("new sprite",packet.id,@addVector(packet.ps,@screenPos,-1),@addVector(packet.sp,@player.speed,-1))
      sprite = @layout.createView App.G1945SpriteView,
        id: packet.id
        parent: @
        pos: @getScreenPos(packet.ps)
        speed: @getScreenSpeed(packet.sp)
        worldSpeed: packet.sp
        bearing: @_flipYAngle(packet.br)
        classHtml: "g1945-#{packet.cs}"
        name: packet.nm
        #idPrefix: "spr-#{packet.cs}"
      @addSprite(sprite)
    
    @childViews[packet.id].worldSpeed = packet.sp
    @childViews[packet.id].moveTo(@getScreenPos(packet.ps))
    @childViews[packet.id].speed = @getScreenSpeed(packet.sp)
    @childViews[packet.id].bearing = @_flipYAngle(packet.br)
    @childViews[packet.id].element?.attr('class',"g1945-#{packet.cs}")

  destroySprite: (packet) =>
    if @childViews[packet.id]?
      @removeSprite(@childViews[packet.id])

  getScreenPos: (ps) =>
    @addVector(@addVector(ps,@screenPos,{x:-1,y:-1}))

  getScreenSpeed: (sp) =>
    if @state == 1
      @addVector(@mulVector(sp,{x:1,y:-1}),@player.speed,{x:-1,y:1})
    else
      {x:0,y:0}

  afterRender: ->
    @newState()
    @runLoop()

  intro: ->

  checkKeyDown: (evt) =>
    @keysDown[evt.keyCode]=1
    #evt.preventDefault()
    true

  checkKeyUp: (evt) =>
    delete @keysDown[evt.keyCode]
    #evt.preventDefault()
    false

  clearKeys: (evt) =>
    @keysDown = {}

  runLoop: =>
    return if @released

    t = @getTime()

    while @releaseQueue.length>0
      view = @releaseQueue.pop()
      @removeView(view)
      view.release()

    recur = false
    for code,nv of @keysDown
      recur = true
      if @state == 1
        switch code
          when "39"
            App.socketIoController.command({t:'tr'})
          when "37"
            App.socketIoController.command({t:'tl'})
          when "38"
            App.socketIoController.command({t:'gf'})
          when "40"
            App.socketIoController.command({t:'gs'})
          when "83"
            App.socketIoController.command({t:'fi'})
          when "80"
            @stop = true
          else
            #console.log(code)
      else if @state == 0
        switch code
          when "32"
            App.socketIoController.command({t:'st',name:@name})

    for id, player of @players
      players.update(t)

    for id, sprite of @childViews
      sprite.update(t)

    _.delay(@runLoop,5) unless @released or @stop

  addSprite: (view) ->
    @addView(view)
    @element.append(view.createElement())
    view.redraw()

  removeSprite: (view) =>
    view.element?.detach()
    @releaseQueue.push(view)

  newSwooper: (pos,speed) ->
    swooper = @layout.createView App.G1945SwooperView,
      parent: @
      pos: pos
      speed: speed
    @addSprite(swooper)

  newShip: ->
    ship = @layout.createView App.G1945ShipView,
      parent: @
      pos: {x: Math.random()*@width, y: -128 }
    @addSprite(ship)

    turret = @layout.createView App.G1945ShipTurretView,
      parent: @
      owner: ship
      offset: {x:11,y:36}
    @addSprite(turret)

  explosionAt: (pos,options = {}) ->
    _.extend(options, {
      parent: @
      pos: pos
    })
    @addSprite(@layout.createView(App.G1945ExplosionView, options))

  addVector: (v1,v2,mag={x:1,y:1}) ->
    o = {}
    o[k] = v for k,v of v1
    o[k] += v*mag[k] for k,v of v2
    o

  mulVector: (v1,mag) ->
    o = {}
    o[k] = v*mag[k] for k,v of v1
    o

  getTime: ->
    (new Date().getTime())

  _flipYAngle: (x) ->
    return x
    return 180-x if x>=0 and x<90
    return 90-(x-90) if x>=90 and x<180
    return 360-(x-180) if x>=180 and x<270
    return 180+(x-270) if x>=270 and x<360
    console.log("bad angle #{x}")
