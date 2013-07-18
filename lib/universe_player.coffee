_ = require 'underscore'
{Sprite} = require "../lib/universe_sprite"
{Bullet} = require "../lib/universe_bullet"
{CompGeo} = require "../lib/universe_compgeo"

exports.Player = class Player
  constructor: (@socket, @server) ->
    @img = 0

    @screenSize = {w:800, h:600}
    @score = 0
    @health = 100
    @bearing = 180
    @speed = 50
    @lastFire = 0
    @fireLimit = 300
    @lastBounds = {b:0,t:@screenSize.h,l:0,r:@screenSize.w}
    @name="plrrr"

    @state = 0

  start: =>
    if @state == 0
      @state = 1
      @sprite = new Sprite(@server,{x:Math.round(Math.random()*@server.sizex), y:Math.round(Math.random()*@server.sizey)},{x:0,y:0},"plr0")
      @sprite.name = @name
      @sprite.player = @
      @sprite.shootable = true

      @sprite.collisionIn = (sprite) =>
        @hit() if sprite.bullet and sprite.owner != @sprite.id

      @health = 100
      @fireMode = 0

      @lowerSpeedLimit = 40
      @upperSpeedLimit = 200

      @sprite.bearing = @bearing
      @server.addSprite(@sprite)

  die: =>
    console.log("player died")
    p = @sprite.getCentrePoint()
    s = {x:@sprite.speed.x, y:@sprite.speed.y}
    r = [100,200,300,400,500]
    for y in r
      _.delay( =>
        ps = {x:p.x-16+Math.round(Math.random()*32),y:p.y-16+Math.round(Math.random()*32)}
        @server.explosionAt(ps, s ,'expl', @sprite)
      ,y)
    _.delay( =>
        @sprite.destroy()
        @state = 0
        @lastBounds = @getScreenBounds()
    ,300)

  getState: =>
    x =
      t:'ps'
      id:@socket.id
      sc:@score
      hl:@health
      st:@state

    if @sprite?
      x.pos = @sprite.pos
      x.sp = @sprite.speed
      x.br = @bearing
      x.cs = @sprite.cls
    x

  getScreenBounds: =>
    if @sprite?
      w2 = (@screenSize.w/2)*1.1
      h2 = (@screenSize.h/2)*1.1
      {b:@sprite.pos.y-h2,t:@sprite.pos.y+h2,l:@sprite.pos.x-w2,r:@sprite.pos.x+w2}
    else
      @lastBounds

  update: (t) =>
    if @sprite?
      @sprite.speed = CompGeo.speedAtBearing(@bearing, @speed)

  hit: =>
    s = @sprite
    s.cls = "plr0-hit"
    _.delay(-> 
      s.cls = "plr0" if s?
    ,200)
    @server.explosionAt(@sprite.getCentrePoint(), {x:@sprite.speed.x/2,y:@sprite.speed.y/2} ,'exps', null)
    @health = Math.max(@health-10,0)
    @die() if @health == 0

  turnLeft: =>
    if @sprite?
      @sprite.bearing = @bearing = CompGeo.fixBearing(@bearing-2)

  turnRight: =>
    if @sprite?
      @sprite.bearing = @bearing = CompGeo.fixBearing(@bearing+2)

  slowDown: =>
    @speed = Math.max(@speed-2,@lowerSpeedLimit)

  speedUp: =>
    @speed = Math.min(@speed+2,@upperSpeedLimit)

  destroy: =>
    if @sprite?
      @sprite.destroy()
      delete @['sprite']

  fire: =>
    t = new Date().getTime()
    return if @lastFire? and @lastFire > t-@fireLimit
    
    x = new Bullet(@server, @sprite.getCentrePoint(), CompGeo.speedAtBearing(@bearing,@speed+300), "blt0" )
    x.bearing = @bearing
    x.expiry = t+3000
    x.owner = @sprite.id
    @server.addSprite(x)

    if @fireMode >0
      s1 = CompGeo.addVector(CompGeo.speedAtBearing(@bearing-90,@speed+300), @sprite.speed)
      s2 = CompGeo.addVector(CompGeo.speedAtBearing(@bearing+90,@speed+300), @sprite.speed)
      x = new Bullet(@server, @sprite.getCentrePoint(), s1, "blt1" )
      x.bearing = @bearing-90
      x.expiry = t+3000
      x.owner = @sprite.id
      @server.addSprite(x)
      x = new Bullet(@server, @sprite.getCentrePoint(), s2, "blt1" )
      x.bearing = @bearing+90
      x.expiry = t+3000
      x.owner = @sprite.id
      @server.addSprite(x)

    if @fireMode >1
      s1 = CompGeo.addVector(CompGeo.speedAtBearing(@bearing-180,@speed+300), @sprite.speed)
      x = new Bullet(@server, @sprite.getCentrePoint(), s1, "blt1" )
      x.bearing = @bearing-180
      x.expiry = t+3000
      x.owner = @sprite.id
      @server.addSprite(x)

    if @fireMode >2
      s1 = CompGeo.addVector(CompGeo.speedAtBearing(@bearing-45,@speed+300), @sprite.speed)
      s2 = CompGeo.addVector(CompGeo.speedAtBearing(@bearing+45,@speed+300), @sprite.speed)
      x = new Bullet(@server, @sprite.getCentrePoint(), s1, "blt0" )
      x.bearing = @bearing-45
      x.expiry = t+3000
      x.owner = @sprite.id
      @server.addSprite(x)
      x = new Bullet(@server, @sprite.getCentrePoint(), s2, "blt0" )
      x.bearing = @bearing+45
      x.expiry = t+3000
      x.owner = @sprite.id
      @server.addSprite(x)

    @lastFire = t

  copyVector: (v) ->
    {x:v.x,y:v.y}
      

