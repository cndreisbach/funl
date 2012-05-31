FunL = module.exports = {}
Parser = require("./funl-parser").Parser
_ = require("underscore")

Type = {}

class Type.Value
  constructor: (@value) ->
  print: -> "" + @value
  toJS: -> @value
  fapply: (value) -> this

class Type.Boolean extends Type.Value
  fapply: (value) ->
    # if this is true, then return the applied value
    # else return false
    if @value then value else @value

class Type.Number extends Type.Value
  # TODO prevent non-numbers from being used
  promote: (other, value) -> new other.constructor(value)
  plus: (other) -> @promote(other, @value + other.value)
  minus: (other) -> @promote(other, @value - other.value)

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

primitives =
  "+": (arr) ->
    left = arr.get(0)
    right = arr.get(1)
    left.plus(right)

  "-": (arr) ->
    left = arr.get(0)
    right = arr.get(1)
    left.minus(right)

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

  application: (ast, env) ->
    [left, right] = (evalAST(element, env) for element in ast.value)
    left.call(left, right)

  constant: (ast, env) ->
    -> evalAST(ast.value, env)

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
    e.message += " at line #{ast.line}, column #{ast.column}"
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
