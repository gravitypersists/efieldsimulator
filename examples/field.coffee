
eField = new EField()
eField.render($('#gauss'))

# TODO consider attaching coordinate system to EField and having consumer of class only know about that
eField.addCharge new Charge 0.3*730, 0.4*600, 1
eField.addCharge new Charge 0.7*730, 0.6*600, -1

eField.toplayer.click (e) ->
  eField.drawAFieldArrow(e.offsetX, e.offsetY)