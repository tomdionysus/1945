class App.G1945ShipTurretView extends App.G1945SpriteView
  classHtml: "g1945turret"
  direction: 180

  owner: null
  offset: {x:0,y:0}

  width:20
  height:20

  lastFire: 0
  fireLimit: 3000

  idPrefix: 'turret'

  init: ->
    super
    @health = 50
    @bind 'change:direction', @updateDirection

  updateDirection: =>
    if @element?
      for d in [0,45,90,135,180,225,270,315]
        @element.removeClass("g1945turret#{d}")
      @element.addClass("g1945turret#{@direction}")

  afterRender: => 
    @updateDirection()

  update: =>
    super
    if @owner?
      if @owner.released
        @parent.removeSprite(@)
      else
        # Update turret position to owner
        @pos.x = @owner.pos.x+@offset.x
        @pos.y = @owner.pos.y+@offset.y
        # Turret direction
        ang = @faceAngle(App.g1945Controller.player)
        @set 'direction', ang if @direction!=ang
        # Shooting
        n = @now()
        if @lastFire+@fireLimit < n
          bullet = @layout.createView App.G1945BulletView,
            parent: @parent
            pos: {x: @pos.x,y:@pos.y }
            owner: @
            type: 1
            speed: @speedAtAngle(@angleTo(App.g1945Controller.player),1)
          @parent.addSprite(bullet)
          @lastFire = n
        # Update Position
        @redopos()

  drawHit: =>
    @element.addClass('g1945turrethit')
    _.delay(=>
      @element?.removeClass("g1945turrethit")
    50)

  takeDamage: (amount) =>
    @set 'health', Math.max(@health-amount,0)
    if @health==0
      @parent.explosionAt(@pos)
      @parent.removeSprite(@)
    else
      @drawHit()



