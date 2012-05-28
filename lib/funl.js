var FunL = module.exports = {};
var Parser = require("./funl-parser").parser;

var evalFunL = function(code) {
  var ast;
  try {
    ast = Parser.parse(code);
    return ast;
  } catch (e) {
    if (e instanceof Parser.SyntaxError) {
      e.message = "Syntax error at line " + e.line + ", column " + e.column + ".";
    }
    throw e;
  }
};

FunL.Parser = Parser;
FunL.evalFunL = evalFunL;
