_ = require 'underscore'

exports.Sprite = class Sprite
  constructor: (@server, @pos, @speed, @cls) ->
    @id = Sprite._getId()
    
    @pos ?= {x:0,y:0}
    @speed ?= {x:0,y:0}
    
    @size = {w:32,h:32}
    @collisionLines = []
    @collisions = {}
    @collides = true
    @moves = true
    @lastUpdate = null
    @expiry = null

    @events = []

    @addToUniverse()

  # Return a serializable state representation
  getState: =>
    t:'ss', 
    id:@id 
    ps:@pos
    sp:@speed
    br:@bearing
    lu:@lastUpdate
    cs:@cls
    nm:@name

  moveBy: (dx,dy) =>
    @removeFromUniverse()
    @pos.x += dx
    @pos.y += dy
    @addToUniverse()

  moveTo: (pt) =>
    @removeFromUniverse()
    @pos = pt
    @addToUniverse()

  # Update the sprite
  update: (t, possibleCollisionSprites) =>
    # Expiry
    if @expiry? and @expiry<t
      @destroy()
      return

    # Move
    if @moves and @lastUpdate?
      dt = t-@lastUpdate
      if dt>0
        dx = if @speed.x!=0 then @speed.x*(dt/1000) else 0
        dy = if @speed.y!=0 then @speed.y*(dt/1000) else 0
        @moveBy(dx,dy)
        #@bearing = Math.atan2(dy,dx) * 180 / Math.PI

      @moveTo({x:@server.sizex,y:@pos.y}) if @pos.x<0
      @moveTo({x:@pos.x,y:@server.sizey}) if @pos.y<0
      @moveTo({x:0,y:@pos.y}) if @pos.x>@server.sizex
      @moveTo({x:@pos.x,y:0}) if @pos.y>@server.sizey

    # Collide
    if @collides
      # Check current Collisions
      for id, sprite of @collisions
        if !@testCollisionWith(sprite) or !sprite.collides
          #console.log("collision out", @id,"->",sprite.id)
          @collisionOut?(sprite)
          delete @collisions[id]

      # Check for new collisions 
      for id, sprite of possibleCollisionSprites
        @testCollisionWith(sprite) if sprite.collides

    # Set last update
    @lastUpdate = t

  # Return the outer boundary of the sprite
  getBoundary: =>
    {t:@pos.y+@size.h,b:@pos.y,l:@pos.x,r:@pos.x+@size.w}

  # Test for a collision with sprite and return true or false. 
  # - Call collisionIn if collision is new.
  testCollisionWith: (sprite) =>
    return false unless @collides

    x = @isColliding(sprite)
    if x and !(@collisions[sprite.id])?
      @collisions[sprite.id] = sprite
      #console.log("collision in", @id,"->",sprite.id)
      @collisionIn?(sprite)
    x

  collisionIn: (sprite) =>
    #@destroy() if @cls=='blt0'

  collisionOut: (sprite) =>
    #console.log("#{@id} stopped colliding with #{sprite.id}")

  # Test for a collision with sprite and return true or false
  isColliding: (sprite) =>
    return false unless @collides
    return false if sprite == @

    poly1 = @getCurrentPolygon()
    poly2 = sprite.getCurrentPolygon()

    bound1 = @getBoundary()
    bound2 = sprite.getBoundary()

    # Any Points Inside
    for l in poly2
      return true if Sprite._isPointInPoly(poly1,bound1,l.a)

    for l in poly1
      return true if Sprite._isPointInPoly(poly2,bound2,l.a)

    # Line Intersections
    for l1 in poly1
      for l2 in poly2
        return true if Sprite._lineIntersects(l1.a,l1.b,l2.a,l2.b)

    false

  # Get the current collision polygon
  getCurrentPolygon: =>
    out = []
    if @collisionLines.length>0
      # Has an actual collision polygon
      for l in @collisionLines
        out.push({a:{x:@pos.x+l.a.x,y:@pos.y+l.a.y}, b:{x:@pos.x+l.b.x,y:@pos.y+l.b.y}})
    else
      # Assume box polygon
      out.push({a:{x:@pos.x,y:@pos.y}, b:{x:@pos.x+@size.w,y:@pos.y}})
      out.push({a:{x:@pos.x+@size.w,y:@pos.y}, b:{x:@pos.x+@size.w,y:@pos.y+@size.h}})
      out.push({a:{x:@pos.x+@size.w,y:@pos.y+@size.h}, b:{x:@pos.x,y:@pos.y+@size.h}})
      out.push({a:{x:@pos.x,y:@pos.y+@size.h}, b:{x:@pos.x,y:@pos.y}})
    out

  # Add us to the universe
  addToUniverse: =>
    if @server? and @server.universe?
      @server.universe.add({x:@pos.x,y:@pos.y,v:@})
      @server.universe.add({x:@pos.x+@size.w,y:@pos.y,v:@})
      @server.universe.add({x:@pos.x,y:@pos.y+@size.h,v:@})
      @server.universe.add({x:@pos.x+@size.w,y:@pos.y+@size.h,v:@})

  # Remove us from the universe
  removeFromUniverse: =>
    if @server? and @server.universe?
      @server.universe.remove({x:@pos.x,y:@pos.y,v:@})
      @server.universe.remove({x:@pos.x+@size.w,y:@pos.y,v:@})
      @server.universe.remove({x:@pos.x,y:@pos.y+@size.h,v:@})
      @server.universe.remove({x:@pos.x+@size.w,y:@pos.y+@size.h,v:@})

  getCentrePoint: =>
    {x: @pos.x+(@size.w/2), y: @pos.y+(@size.h/2)}

  destroy: =>
    @server.destroySprite(@)

  # Return true if v is between r1 and r2 regardless of r1>r2 or r1<r2.
  @_within: (v,r1,r2) ->
    if r1>r2
      return true if v<=r1 and v>=r2
    else
      return true if v>=r1 and v<=r2
    false

  # Return true if line (a1,a2) crosses (b1,b2)
  @_lineIntersects: (a1, a2, b1, b2) ->
    result = undefined
    ua_t = (b2.x - b1.x) * (a1.y - b1.y) - (b2.y - b1.y) * (a1.x - b1.x)
    ub_t = (a2.x - a1.x) * (a1.y - b1.y) - (a2.y - a1.y) * (a1.x - b1.x)
    u_b = (b2.y - b1.y) * (a2.x - a1.x) - (b2.x - b1.x) * (a2.y - a1.y)
    unless u_b is 0
      ua = ua_t / u_b
      ub = ub_t / u_b
      if 0 <= ua and ua <= 1 and 0 <= ub and ub <= 1
        #return {x:(a1.x + ua * (a2.x - a1.x),y: a1.y + ua * (a2.y - a1.y))}
        return true
      else
        return false
    ua_t is 0 or ub_t is 0

  @_isPointInPoly: (lines, bounds, pt) ->
    leftc = 0
    rightc = 0
    # Essential range detection
    return false if (pt.x>bounds.r or pt.x<bounds.l) and (pt.y>bounds.t or pt.y<bounds.b)

    # Generate left/right line to boundary
    rl = {a:pt, b:{x:bounds.r,y:pt.y}}
    rc = 0
    ll = {a:{x:bounds.l,y:pt.y},b: pt}
    lc = 0

    for l in lines
      return true if (pt.x == l.a.x and pt.y==l.a.y) or (pt.x == l.b.x and pt.y==l.b.y)
      return true if Sprite._isPointOnLine(l, pt)
      rc++ if Sprite._lineIntersects(rl.a,rl.b,l.a,l.b)
      lc++ if Sprite._lineIntersects(ll.a,ll.b,l.a,l.b)

    # rc & lc == ODD, inside
    # rc & lc == EVEN, outside
    ((rc % 2) != 0 and (lc % 2) != 0)

  @_isPointOnLine: (line, pt) ->
    return false unless Sprite._within(pt.x,line.a.x,line.b.x)
    return false unless Sprite._within(pt.y,line.a.y,line.b.y)
    return true if pt.x == 0 and line.a.x == 0 and line.b.x ==0
    return true if pt.y == 0 and line.a.y == 0 and line.b.y ==0
    return (pt.x / pt.y) == (line.b.x - line.a.x ) / (line.b.y - line.a.y)

  # Return a random 8 number id string
  @_getId: ->
    Math.random().toString(36).substr(2, 10)


