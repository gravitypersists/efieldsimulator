
eField = new EField()
eField.render($('#secondlaw'))

randomBetween = (x1, x2) -> Math.random()*(x2-x1)+x1
oneOrNegative = -> if Math.floor(Math.random()*2) then 1 else -1
# TODO: not a fan of this interface...
eField.addCharge new Charge randomBetween(0.2,0.35)*730,
  randomBetween(0.2,0.4)*600
  oneOrNegative()
eField.addCharge new Charge randomBetween(0.4,0.6)*730,
  randomBetween(0.6,0.8)*600
  oneOrNegative()
eField.addCharge new Charge randomBetween(0.65,0.8)*730,
  randomBetween(0.3,0.5)*600
  oneOrNegative()
