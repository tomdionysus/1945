class App.G1945PlayerView extends App.G1945SpriteView
  skipTemplate: true
  classHtml: 'g1945-plr2'
  fireLimit: 200
  lastFire: 0
  idPrefix: "player"
  bearing: 0

  width:64
  height:64

  init: =>
    super
    App.g1945Controller.player = @
    @set 'score', 0
    @set 'health', 100
    @set 'pos', {x:368,y:268}

  getHtmlStyleValue: =>
    "left:#{Math.round(@pos.x)}px;top:#{Math.round(@pos.y)}px;-webkit-transform:rotate("+@bearing+"deg);"