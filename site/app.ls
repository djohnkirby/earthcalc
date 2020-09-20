# set global log fn
# note we can't just set window.log = console.log becuase we'll get
# 'illegal invocation' errors, since console.log expects 'this' to be console.
window.log = -> console.log ...&

const FEET-PER-METRE  = 3.2808
const MILES-PER-KM    = 0.621371192237
const EARTH-RADIUS-KM = 6371km

# 'factor' is used to convert to/from metric units for the calculation
# 'switch' is used to flip between metric and imperial.
const UNITS =
  imperial:
    minor:
      name  : \feet
      factor: 1 / FEET-PER-METRE
      switch: FEET-PER-METRE
    major:
      name  : \miles
      factor: 1 / MILES-PER-KM
      switch: MILES-PER-KM
  metric:
    minor:
      name  : \metres
      factor: 1
      switch: 1 / FEET-PER-METRE
    major:
      name  : \km
      factor: 1
      switch: 1 / MILES-PER-KM

var unit-id # currently selected

initialise!
calculate!
$ \input .on \keypress -> calculate! if (it.key or it.keyIdentifier) is \Enter
$ \#btnCalculate .on \click calculate
$ '#metric,#imperial' .on \click -> switch-unit it.target.value

# the validator works on the submit button but we don't want to
# submit the form, otherwise the query string gets overwritten
$ \form .on \submit -> it.preventDefault!

## helpers
function calculate
  h1    = get-val \h1
  h2    = get-val \h2
  unit  = UNITS[unit-id]
  h1_km = h1 * unit.minor.factor * 0.001km_per_m
  h2_km = h2 * unit.minor.factor * 0.001km_per_m
  d1_km = get-horizon-distance_km h1_km
  d2_km = get-horizon-distance_km h2_km
  d1    = d1_km / unit.major.factor
  d     = (d1_km + d2_km) / unit.major.factor

  $ \#d1 .text d1.toFixed 2
  $ \#d  .text d.toFixed 2

  qs = queryString.stringify h1:h1, h2:h2, unit:unit-id
  history.replaceState void "" "?#qs"

function get-horizon-distance_km h0_km
  Math.sqrt(h0_km^2 + 2*EARTH-RADIUS-KM*h0_km)

function get-target-hidden-height_km d2_km
  return 0 if d2_km < 0
  Math.sqrt(d2_km^2 + EARTH-RADIUS-KM^2) - EARTH-RADIUS-KM

function get-val
  parseFloat($ "##it" .val!)

function initialise
  qs = queryString.parse location.search
  $ \#h1 .val(if (parseFloat h1 = qs.h1) then h1 else \1.75)
  $ \#h2 .val(if (parseFloat h2 = qs.h2) then h2 else \10)
  initialise-unit(if UNITS[u = qs.unit] then u else \metric)

function initialise-unit
  $ "input##it" .prop \checked true
  show-unit unit-id := it

function show-unit
  $ '.unit-minor .unit' .text UNITS[it].minor.name
  $ '.unit-major .unit' .text UNITS[it].major.name

function switch-unit
  show-unit unit-id := it
  unit = UNITS[unit-id]
  $ \#h1 .val(unit.minor.switch * get-val \h1)
  $ \#h2 .val(unit.minor.switch * get-val \h2)
  calculate!
