class App.G1945ShipView extends App.G1945SpriteView
  idPrefix: "ship"
  lastDirTime: 0
  classHtml: 'g1945ship'

  width: 41
  height: 197

  collides: false

  afterRender:=>
    @redopos()

  redopos: =>
    super
      
    n = @now()
    if n > @lastDirTime+500
      @lastDirTime = n

  update: =>
    super
    @pos.y += 0.2

    if @pos.y > @parent.height+128
      if @parent?
        @parent.maxShip = 0
        @parent.removeSprite(@)
    else
      @redopos()

