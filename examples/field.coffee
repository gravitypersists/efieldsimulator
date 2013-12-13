
eField = new EField
  width: 400
  height: 300
eField.render($('#field'))
eField.bglayer.css('background-color', 'tan')

# TODO consider attaching coordinate system to EField and having consumer of class only know about that
eField.addCharge new Charge 0.3*400, 0.4*300, 1
eField.addCharge new Charge 0.7*400, 0.6*300, -1

eField.toplayer.click (e) ->
  eField.drawFieldArrow(e.offsetX, e.offsetY)

#eField.play()