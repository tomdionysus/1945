class App.G1945SpriteView extends Mozart.View
  skipTemplate: true
  
  init: =>
    super
    @styleHtml = @getHtmlStyleValue()
    @pos ?= {x:-128, y:-128}
  
    @width ?= 32
    @height ?= 32

    @bind 'change:name', @redoname

  afterRender: =>
    @redopos()
    @redoname()

  moveTo: (pos) =>
    @pos = pos
    @redopos()

  moveBy: (dx,dy) =>
    @pos.x += dx
    @pos.y -= dy
    @redopos()

  redopos: =>
    @element?.attr('style',@getHtmlStyleValue())

  redoname: =>
    @nameEle = $("<div>").addClass('g1945-playername').html(@name)
    @element?.append(@nameEle)

  getHtmlStyleValue: =>
    "left:#{Math.round(@pos.x)}px;top:#{Math.round(@pos.y)}px;-webkit-transform:rotate("+@bearing+"deg);"

  # Update the sprite
  update: =>
    # if @pos.y<-128 or @pos.y > @parent.height+128 or @pos.x< -128 or @pos.x > @parent.width+128
    #   @parent.removeSprite(@)
    #   return

    t = @now()
    # Move
    if @lastUpdate?
      dt = t - @lastUpdate

      if dt>0
        dx = if @speed.x!=0 then @speed.x*(dt/1000) else 0
        dy = if @speed.y!=0 then @speed.y*(dt/1000) else 0
        @moveBy(dx,dy)

    # Set last update
    @lastUpdate = t

  now: ->
    (new Date().getTime())

  calcAngle: (pos1,pos2) ->
    calcAngle = Math.atan2(pos1.x - pos2.x, pos1.y - pos2.y) * (180 / Math.PI)
    if calcAngle < 0
      calcAngle = Math.abs(calcAngle)
    else
      calcAngle = 360 - calcAngle
    calcAngle

  revAngle: (ang) ->
    {0:180,45:225,90:270,135:315,180:0,225:45,270:90,315:135}[ang]

  faceAngle: (sprite) =>
    ang = @calcAngle(@centrePoint(),sprite.centrePoint())
    dir = Math.round(ang/45)*45
    dir = 0 if dir == 360
    dir

  angleTo: (sprite) ->
    @calcAngle(@centrePoint(),sprite.centrePoint())

  speedAtAngle: (angle, speed) ->
    # Avoid div/0 errors
    # return {x:speed,y:0} if angle == 90
    # return {x:0,y:-speed} if angle == 0
    # return {x:0,y:speed} if angle == 180
    # return {x:-speed,y:0} if angle == 270
    # SOHCAHTOA :)
    angle = angle * (Math.PI / 180)
    return { x: (speed*Math.sin(angle)), y: 0-(speed*Math.cos(angle)) }

  centrePoint: =>
    {x:@pos.x+(@width/2), y:@pos.y+(@height/2)}

  scaleBy: (object, scale) =>
    object[k] = object[k]*scale for k,v of object
    object


