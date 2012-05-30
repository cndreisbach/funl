var FunL = module.exports = {};
var Parser = require("./funl-parser").Parser;
var klass = require('klass');
var _ = require('underscore');

/* Plan of attack:
   - Remember that everything is a function
   - Create objects that can be fapplied to other objects
*/

var Repr = {};

Repr.Abstract = klass(function(value) {
  this.value = value;
}).methods({
  // Print the object
  print: function() {
    return "" + this.value;
  },
  // Return a JavaScript value
  toJS: function() {
    return this.value;
  },
  // Apply a value to this function
  fapply: function(val) {
    return this;
  }
});

Repr.Integer = Repr.Abstract.extend(function(value) {});
Repr.Float = Repr.Abstract.extend(function(value) {});
Repr.String = Repr.Abstract.extend(function(value) {}).methods({
  print: function() {
    return '"' + this.value + '"';
  }
});

var handlers = {
  program: function(ast, env) {
    var retval = null;
    _(ast.value).each(function(element) {
      retval = evalAST(element, env);
    });
    return retval;
  },
  integer: function(ast, env) {
    return new Repr.Integer(ast.value);
  },
  float: function(ast, env) {
    return new Repr.Float(ast.value);
  },
  string: function(ast, env) {
    return new Repr.String(ast.value);
  }
};

var isA = function(type, expr) {
  return typeof expr === type;
};

var evalAST = function(ast, env) {
  if (env == null) {
    env = {};
  }

  if (ast.type != null && isA("function", handlers[ast.type])) {
    return handlers[ast.type](ast, env);
  }
};

var evalFunL = function(code) {
  var ast;
  try {
    ast = Parser.parse(code);
    return evalAST(ast);
  } catch (e) {
    if (e instanceof Parser.SyntaxError) {
      e.message = "Syntax error at line " + e.line + ", column " + e.column + ".";
    }
    throw e;
  }
};

FunL.Parser = Parser;
FunL.evalFunL = evalFunL;
