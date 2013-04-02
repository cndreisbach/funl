module.exports = Type = {}

class Type.Value
  constructor: (@value) ->
  print: -> "" + @value
  toJS: -> @value
  fapply: (arg) -> this
  true: -> true

class Type.Boolean extends Type.Value
  fapply: (arg) ->
    # if this is true, then return the applied value
    # else return false
    if @value then arg else @value
  true: ->
    @value

class Type.Number extends Type.Value
  # TODO prevent non-numbers from being used
  promote: (other, value) -> new other.constructor(value)
  sum: (other) -> @promote(other, @value + other.value)
  difference: (other) -> @promote(other, @value - other.value)
  product: (other) -> @promote(other, @value * other.value)
  quotient: (other) -> @promote(other, @value / other.value)

class Type.Integer extends Type.Number
class Type.Float extends Type.Number
  promote: (other, value) -> new Type.Float(value)

class Type.String extends Type.Value
  print: -> "\"#{@value}\""

class Type.Seq extends Type.Value
  print: ->
    "[" + (element.print() for element in @value).join(" ") + "]"

  get: (n) -> @value[n]

  toJS: -> (element.toJS() for element in @value)

  fapply: (arg) ->
    @get(arg.toJS())

class Type.Map extends Type.Value
  constructor: (elements) ->
    @value = ([el, elements[i+1]] for el, i in elements by 2)

  print: ->
    "{" + ("#{el[0].print()} #{el[1].print()}" for el in @value).join(" ") + "}"

  get: (key) ->
    (el[1] for el in @value when el[0].toJS() is key)[0]

  toJS: ->
    ([el[0].toJS(), el[1].toJS()] for el in @value).reduce((obj, v) ->
      obj[v[0]] = v[1]
      obj
    , {})

  fapply: (arg) ->
    @get(arg.toJS())

class Type.Function extends Type.Value
  fapply: (arg) ->
    @value(arg)

