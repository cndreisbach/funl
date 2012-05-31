FunL = module.exports = {}
Parser = require("./funl-parser").Parser
_ = require("underscore")

Repr = {}

class Repr.Value
  constructor: (@value) ->

  print: ->
    "" + @value

  toJS: -> @value

  fapply: (value) -> this

class Repr.Number extends Repr.Value
  plus: (other) ->
    new other.constructor(@value + other.value)

class Repr.Integer extends Repr.Number

class Repr.Float extends Repr.Number

class Repr.String extends Repr.Value
  print: ->
    return "\"#{@value}\""

class Repr.Seq extends Repr.Value
  print: ->
    "[" + (element.print() for element in @value).join(" ") + "]"

  get: (n) ->
    @value[n]

  toJS: ->
    (element.toJS() for element in @value)

primitives =
  "+": (arr) ->
    left = arr.get(0)
    right = arr.get(1)
    left.plus right

handlers =
  program: (ast, env) ->
    for element in ast.value
      retval = evalAST(element, env)
    retval

  integer: (ast, env) ->
    new Repr.Integer(ast.value)

  float: (ast, env) ->
    new Repr.Float(ast.value)

  string: (ast, env) ->
    new Repr.String(ast.value)

  seq: (ast, env) ->
    elements = (evalAST(element, env) for element in ast.value)
    new Repr.Seq(elements)

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
FunL.Repr = Repr
