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

class Type.Function extends Type.Value
  fapply: (arg) ->
    @value(arg)
