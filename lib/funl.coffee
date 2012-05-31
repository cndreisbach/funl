FunL = module.exports = {}
Parser = require("./funl-parser").Parser
_ = require("underscore")

Type = {}

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
  plus: (other) -> @promote(other, @value + other.value)
  minus: (other) -> @promote(other, @value - other.value)
  product: (other) -> @promote(other, @value * other.value)

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

primitives =
  id: new Type.Function (arg) ->
    arg

  "+": new Type.Function (arr) ->
    left = arr.get(0)
    right = arr.get(1)
    left.plus(right)

  "-": new Type.Function (arr) ->
    left = arr.get(0)
    right = arr.get(1)
    left.minus(right)

  "*": new Type.Function (arr) ->
    left = arr.get(0)
    right = arr.get(1)
    left.product(right)

handlers =
  program: (ast, env) ->
    for element in ast.value
      retval = evalAST(element, env)
    retval

  boolean: (ast, env) ->
    new Type.Boolean(ast.value)

  integer: (ast, env) ->
    new Type.Integer(ast.value)

  float: (ast, env) ->
    new Type.Float(ast.value)

  string: (ast, env) ->
    new Type.String(ast.value)

  seq: (ast, env) ->
    elements = (evalAST(element, env) for element in ast.value)
    new Type.Seq(elements)

  keyword: (ast, env) ->
    env[ast.value] ? throw new Error("Undefined keyword #{ast.value}")

  composition: (ast, env) ->
    [left, right] = (evalAST(element, env) for element in ast.value)
    new Type.Function (arg) ->
      right.fapply(left.fapply(arg))

  construction: (ast, env) ->
    elements = (evalAST(element, env) for element in ast.value)
    new Type.Function (arg) ->
      results = (element.fapply(arg) for element in elements)
      new Type.Seq(results)

  application: (ast, env) ->
    [left, right] = (evalAST(element, env) for element in ast.value)
    left.fapply(right)

  constant: (ast, env) ->
    new Type.Function (arg) -> evalAST(ast.value, env)

  conditional: (ast, env) ->
    pred = evalAST(ast.value[0], env)
    if pred.true()
      evalAST(ast.value[1], env)
    else
      evalAST(ast.value[2], env)

  definition: (ast, env) ->
    env[ast.value[0].value] = evalAST(ast.value[1], env)

isA = (type, expr) ->
  typeof expr is type

evalAST = (ast, env) ->
  env = _.clone(primitives) unless env?
  try
    if ast.type? and isA("function", handlers[ast.type])
      handlers[ast.type] ast, env
    else
      throw new Error("Not implemented yet")
  catch e
    e.message += "\n at line #{ast.line}, column #{ast.column}"
    throw e

evalFunL = (code) ->
  try
    ast = Parser.parse(code)
  catch e
    e.message = "Syntax error at line #{e.line}, column #{e.column}"
    throw e
  evalAST(ast)

FunL.Parser = Parser
FunL.evalFunL = evalFunL
FunL.Type = Type
