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
    return new other.constructor(@value + other.value)

class Repr.Integer extends Repr.Number

class Repr.Float extends Repr.Number

class Repr.String extends Repr.Value
  print: ->
    return "\"#{@value}\""

primitives = "+": (arr) ->
  left = arr[0]
  right = arr[1]
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

isA = (type, expr) ->
  typeof expr is type

evalAST = (ast, env) ->
  env = {} unless env?
  handlers[ast.type] ast, env  if ast.type? and isA("function", handlers[ast.type])

evalFunL = (code) ->
  try
    ast = Parser.parse(code)
    return evalAST(ast)
  catch e
    e.message = "Syntax error at line #{e.line} column #{e.column}." if e instanceof Parser.SyntaxError
    throw e

FunL.Parser = Parser
FunL.evalFunL = evalFunL
FunL.Repr = Repr
