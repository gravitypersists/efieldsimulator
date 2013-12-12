
# instantiate and render into div
eField = new EField()
eField.render($('#gauss'))

# set view method
eField.drawArrows()

# add a circle of charges
x = 365 # x, y for center of circle 
y = 300
radius = 200
num = 20
for i in [1..num]
  xi = Math.sin(i*360/num*Math.PI/180)*radius
  yi = Math.cos(i*360/num*Math.PI/180)*radius
  eField.addStationaryCharge x+xi, y+yi
  eField.addStationaryCharge x-xi, y+yi

# add event listener to top interactive layer
eField.toplayer.click (e) ->
  eField.play()
  if e.shiftKey
    eField.addStationaryCharge(e.offsetX, e.offsetY)
  else
    eField.addPointCharge(e.offsetX, e.offsetY)