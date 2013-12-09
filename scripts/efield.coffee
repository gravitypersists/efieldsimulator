define [], () ->
  WIDTH = 730
  HEIGHT = 600

  tpl = """
    <svg width=730 height=600 style="position:absolute; top:0px; left:100px;">
      <marker id="triangle" viewBox="0 0 10 10" refX="0" refY="5"
                  markerUnits="strokeWidth" markerWidth="4" markerHeight="3" orient="auto">
        <path d="M 0 0 L 10 5 L 0 10 z" />
      </marker>
    </svg>
  """

  class Arrow

    constructor: (@x, @y) -> #

    makeLine: ->
      @line = document.createElementNS('http://www.w3.org/2000/svg', 'line')
      _.map {'x1':@x, 'y1':@y, 'x2':@x, 'y2':@y+8, 'stroke':'black', 'stroke-width':'1.5', 'marker-end':'url(#triangle)'},
        (v,k) => @line.setAttribute(k, v)
      return @line

    setVector: (@angle, @strength) ->
      @line.setAttribute "transform", "rotate(#{@angle}, #{@x}, #{@y})"
      @line.setAttribute "opacity", @strength

  class Charge

    constructor: (@x, @y) -> #

  class EField

    constructor: (@gridRes = 20) ->
      # create field canvas
      @fieldsvg = $(tpl)
      $('body').append(@fieldsvg)

      # create canvas for drawing charges (interactive layer)
      @chargesvg = $('<svg style="position:absolute; top:0px; left:100px;" width=730 height=600></svg>')
      $('body').append(@chargesvg)
      @chargesvg.click (e) =>
        if e.shiftKey
          @addCharge(e.offsetX, e.offsetY)
        else
          @addPointCharge(e.offsetX, e.offsetY)

      # keep a reference to the charges in this field
      @charges = []

      @arrows = []
      m = Math.floor(WIDTH/@gridRes)
      n = Math.floor(HEIGHT/@gridRes)
      for i in [1..m]
        for j in [1..n]
          arrow = new Arrow(i*@gridRes, j*@gridRes)
          @fieldsvg.append arrow.makeLine()
          @arrows.push arrow
      @render()
      @addCircleOfCharges(20, 200, 365, 300)

    render: ->
      _.each @arrows, (arrow) =>
        Dx = 0
        Dy = 0
        _.each @charges, (charge) =>
          dx = charge.x-arrow.x
          dy = (charge.y-arrow.y)*(-1)
          de = 1/(Math.pow(dx, 2)+Math.pow(dy, 2))
          Dx += de*dx
          Dy += de*dy
        angle = Math.atan(Dx/Dy)*360/(2*Math.PI)
        if Dy >= 0
          angle += 180
        magnitude = Math.sqrt(Math.pow(Dx, 2)+Math.pow(Dy, 2))*30
        arrow.setVector(angle, magnitude)

    addCharge: (x, y) ->
      @charges.push(new Charge(x, y))
      @render()
      circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle')
      _.map {'cx':x, 'cy':y, 'r':10, 'fill':'red', 'stroke':'none'},
        (v,k) -> circle.setAttribute(k, v)
      @chargesvg.append(circle)

    addPointCharge: (x, y) ->
      electron = {x, y, vx:0, vy:0}
      circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle')
      _.map {'cx':electron.x, 'cy':electron.y, 'r':4, 'fill':'blue', 'stroke':'none'},
        (v,k) -> circle.setAttribute(k, v)
      @chargesvg.append(circle)

      electronInterval = setInterval( =>
        Ex = 0
        Ey = 0
        _.each @charges, (charge) =>
          dx = charge.x-electron.x
          dy = (charge.y-electron.y)
          de = 1/(Math.pow(dx, 2)+Math.pow(dy, 2))
          Ex += de*dx
          Ey += de*dy
        magnitude = Math.sqrt(Math.pow(Ex, 2)+Math.pow(Ey, 2))*30
        electron.vx += Ex*magnitude*.01
        electron.vy += Ey*magnitude*.01
        electron.x = electron.x+electron.vx*1000/40
        electron.y = electron.y+electron.vy*1000/40
        circle.setAttribute('cx', electron.x)
        circle.setAttribute('cy', electron.y)
      , 1000/40)

    addCircleOfCharges: (num, r, x, y) ->
      for i in [1..num]
        @addCharge x+Math.sin(i*360/num*Math.PI/180)*r, y+Math.cos(i*360/num*Math.PI/180)*r
        @addCharge x-Math.sin(i*360/num*Math.PI/180)*r, y+Math.cos(i*360/num*Math.PI/180)*r
      @render()

  new EField()
