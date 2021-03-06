
class Arrow

  constructor: (@x, @y) -> #

  makeLine: ->
    @line = document.createElementNS('http://www.w3.org/2000/svg', 'line')
    attrs = 
      'x1':@x, 'y1':@y, 'x2':@x, 'y2':@y+8,
      'stroke':'black' 
      'stroke-width':'1.5' 
      'marker-start':'url(#triangle)'
    _.map attrs,
      (v,k) => @line.setAttribute(k, v)
    return @line

  setVector: (@angle) ->
    @line.setAttribute "transform", "rotate(#{@angle}, #{@x}, #{@y})"
    
  opacity: (opacity) ->
    @line.setAttribute "opacity", opacity

class Charge
  # x, y, charge, mass

  constructor: (@x, @y, @charge = 1, @mass = 1) ->
    @vx = 0
    @vy = 0
    @circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle')
    # defaults
    attrs = 
      'cx':@x, 'cy':@y,
      'r': 10
      'fill': 'red'
      'stroke': 'none'
    _.map attrs,
      (v,k) => @setAttribute(k, v)

  setAttribute: (k,v) ->
    @circle.setAttribute(k,v)

  setx: (@x) ->
    @circle.setAttribute('cx', @x)

  sety: (@y) ->
    @circle.setAttribute('cy', @y)

  field: (x, y) ->
    deltax = @x-x
    deltay = @y-y
    rsq = deltax*deltax+deltay*deltay
    r = Math.sqrt rsq
    magnitude = @charge/rsq
    return {
      i: deltax/r
      j: deltay/r
      magnitude: magnitude
    }

class EField

  constructor: (options = {}) ->
    @WIDTH = options.width || 730 # because fuck 725 (indeed)
    @HEIGHT = options.height || 600
    @charges = []
    @arrows = []

  render: ($el) ->
    # create bg canvas, non-interactive things go here
    tpl = """
      <svg width=#{@WIDTH} height=#{@HEIGHT} style="position:relative; top:0px; left:0px;">
        <marker id="triangle" viewBox="-10 0 10 10" refX="-5" refY="5"
                    markerUnits="strokeWidth" markerWidth="4" markerHeight="3" orient="auto">
          <path d="M 0 0 L -10 5 L 0 10 z" />
        </marker>
      </svg>
    """
    @bglayer = $(tpl)
    $el.append(@bglayer)

    # create interactive svg layer (any drawn object that is clickable)
    @toplayer = $('<svg style="position:absolute; top:0px; left:0px;" width=' + @WIDTH + ' height=' + @HEIGHT + '></svg>')
    $el.append(@toplayer)
    
  drawArrows: (@gridRes = 20) ->
    m = Math.floor(@WIDTH/@gridRes)
    n = Math.floor(@HEIGHT/@gridRes)
    for i in [1..m]
      for j in [1..n]
        @drawFieldArrow(i*@gridRes, j*@gridRes)
    @_updateArrows()

  drawFieldArrow: (x, y) ->
    arrow = new Arrow x, y
    @bglayer.append arrow.makeLine()
    @arrows.push arrow
    @_updateArrows()

  addCharge: (charge) ->
    @charges.push(charge)
    @toplayer.append(charge.circle)

  # Charge with infinite mass
  addStationaryCharge: (x, y, charge = 1) ->
    charge = new Charge(x, y, charge, Infinity)
    @charges.push(charge)
    @toplayer.append(charge.circle)
    @_updateArrows()

  # Electron (for now)
  addPointCharge: (x, y) ->
    electron = new Charge x, y, -1, 0.1
    @charges.push(electron)
    @toplayer.append(electron.circle)
    _.map { 'r':4, 'fill':'blue' },
      (v,k) -> electron.setAttribute(k, v)

  field: (x, y) ->
    Ex = 0
    Ey = 0
    _.each @charges, (charge) =>
      vector = charge.field x, y
      Ex += vector.i*vector.magnitude
      Ey += vector.j*vector.magnitude
    return {
      x: Ex
      y: Ey
    }


  ####################
  # Animation controls

  play: (speedFactor) ->
    return if @interval
    @interval = setInterval (=> @_tick(speedFactor)), 1000/40 # go for ~ 25 fps

  stop: ->
    clearInterval @interval
    @interval = null


  #################
  # Private methods

  _tick: (speedFactor = 1) ->
    speedFactor = speedFactor*30
    try 
      # a bit of meshing optimization might be needed later (calc e field at each grid point once)
      # also calc each force just once, use second law!
      _.each @charges, (c1, i) =>
        return if c1.mass is Infinity
        Ex = 0
        Ey = 0
        _.each @charges, (c2, j) =>
          return if i is j
          vector = c2.field c1.x, c1.y
          Ex += vector.i*vector.magnitude
          Ey += vector.j*vector.magnitude
        c1.vx += -c1.charge*Ex/c1.mass
        c1.vy += -c1.charge*Ey/c1.mass
        c1.setx(c1.x+c1.vx*40/1000*speedFactor)
        c1.sety(c1.y+c1.vy*40/1000*speedFactor)
    catch error
      @stop()
      throw error
    @_updateArrows()

  _updateArrows: ->
    _.each @arrows, (arrow) =>
      vector = @field arrow.x, arrow.y
      angle = Math.atan(vector.x/-vector.y)*360/(2*Math.PI)
      if vector.y >= 0
       angle += 180
      magnitude = Math.sqrt(vector.x*vector.x+vector.y*vector.y)*300
      arrow.setVector(angle)
      arrow.opacity magnitude

  


# throw things on window for now
window.EField = EField
window.Charge = Charge
