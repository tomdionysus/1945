exports.CompGeo = class CompGeo
  
  @fixBearing: (bearing) ->
    if bearing<0 then bearing = 360 + bearing
    if bearing>360 then bearing = bearing - 360
    bearing

  @speedAtBearing: (bearing, speed) ->
    bearing = bearing * (Math.PI / 180)
    { x: (speed*Math.sin(bearing)), y: 0-(speed*Math.cos(bearing)) }

  @addVector: (v1,v2) ->
    { x: v1.x+v2.x, y: v1.y+v2.y }

