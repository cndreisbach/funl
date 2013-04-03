_ = require("underscore")

FunL = module.exports = {}
Parser = require("./funl-parser").Parser
Type = require("./funl/type")

primitives =
  id: new Type.Function (arg) ->
    arg

  fold: new Type.Function (fn) ->
    new Type.Function (seq) ->
      tmpfn = (total, list) ->
        if list.length > 0
          tmpfn(fn.fapply(new Type.Seq([total, list[0]])), list.slice(1))
        else
          total
      tmpfn(seq.get(0), seq.value.slice(1))

  map: new Type.Function (fn) ->
    new Type.Function (seq) ->
      newList = (fn.fapply(element) for element in seq.value)
      new Type.Seq(newList)

  "+": new Type.Function (arr) ->
    left = arr.get(0)
    right = arr.get(1)
    left.sum(right)

  "-": new Type.Function (arr) ->
    left = arr.get(0)
    right = arr.get(1)
    left.difference(right)

  "*": new Type.Function (arr) ->
    left = arr.get(0)
    right = arr.get(1)
    left.product(right)

  "/": new Type.Function (arr) ->
    left = arr.get(0)
    right = arr.get(1)
    left.divide(right)

  "print": new Type.Function (arg) ->
    console.log(arg.toJS())
    arg

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

  map: (ast, env) ->
    elements = (evalAST(element, env) for element in ast.value)
    new Type.Map(elements)

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
    val = evalAST(ast.value, env)
    new Type.Function (arg) -> val

  conditional: (ast, env) ->
    pred = evalAST(ast.value[0], env)
    if pred.true()
      evalAST(ast.value[1], env)
    else
      evalAST(ast.value[2], env)

  definition: (ast, env) ->
    # TODO stop redefinition
    env[ast.value[0].value] = evalAST(ast.value[1], env)

isA = (type, expr) ->
  typeof expr is type

freshEnv = ->
  _.clone(primitives)

evalAST = (ast, env) ->
  env = freshEnv() unless env?
  try
    if ast.type? and isA("function", handlers[ast.type])
      handlers[ast.type] ast, env
    else
      throw new Error("Not implemented yet")
  catch e
    e.message += "\n in #{ast.type} at line #{ast.line}, column #{ast.column}"
    throw e

evalFunL = (code, env) ->
  try
    ast = Parser.parse(code)
  catch e
    e.message = "Syntax error at line #{e.line}, column #{e.column}"
    throw e
  env = freshEnv() unless env?
  evalAST(ast, env)

FunL.Parser = Parser
FunL.evalFunL = evalFunL
FunL.Type = Type
FunL.freshEnv = freshEnv
