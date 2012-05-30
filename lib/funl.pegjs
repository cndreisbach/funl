// Initialization code

{
  var ASTNode = function(type, value, line, column) {
    this.type = type;
    this.value = value;
    this.line = line;
    this.column = column;
  };
}

/* Order of operations:
 * - tightapplication (function[arg])
 * - constant (~arg)
 * - application (function: arg)
 * - composition (fn1 | fn2)
 * - construction (<fn1, fn2>)
 * - conditional (pred ? true ; false)
 */

start
  = program

program
  = _ expressions:expression+ {
    return new ASTNode("program", expressions, line, column);
  }

expression
  = definition
  / conditional

definition
  = left:keyword _ "=" _ right:conditional _ {
    return new ASTNode("definition", [left, right], line, column);
  }    

conditional
  = predicate:construction "?" _ left:conditional ";" _ right:conditional _ {
    return new ASTNode("conditional", [predicate, left, right], line, column);
  }
  / construction

construction
  = "<" _ expressions:construction* ">" _ {
    return new ASTNode("construction", expressions, line, column);
  }
  / composition

composition
  = left:application _ "|" _ right:composition _ {
    return new ASTNode("composition", [left, right], line, column);
  }
  / application
  
application
  = left:constant ":" _ right:application _ {
    return new ASTNode("application", [left, right], line, column);
  }
  / constant:constant _ { return constant; }

constant
  = "~" constant:function {
    return new ASTNode("constant", constant, line, column);
  }
  / tightapplication

tightapplication  
  = left:function "[" _ right:tightapplication _ "]" _ {
    return new ASTNode("application", [left, right], line, column);
  }
  / function  
  
function
  = thing:(value / keyword) { return thing; }
  / "(" _ expression:expression ")" { return expression; }

value
  = number:number { return number; }
  / string:string { return string; }
  / boolean:boolean { return boolean; }
  / seq:seq { return seq; }
  / map:map { return map; }

keyword
  = char:special_char { return new ASTNode("keyword", char, line, column); }
  / first:alpha_char rest:keyword_char* {
    return new ASTNode("keyword", first + rest.join(""), line, column);
  }  

seq
  = "[" _ values:expression* "]" { return new ASTNode("seq", values, line, column); }

map
  = "{" _ values:expression* "}" { return new ASTNode("map", values, line, column); }      

number
  = float
  / integer
  
integer
  = negative:'-'? number:[0-9]+ {
    return new ASTNode("integer",
                       parseInt(negative + number.join("")),
                       line, column);
  }

float
  = negative:'-'? whole:[0-9]+ '.' decimal:[0-9]+ {
    return new ASTNode("float",
                       parseFloat(negative + whole.join("") + "." + decimal.join("")),
                       line, column); }

string
  = '"' string:string_char* '"' { return new ASTNode("string", string.join(""), line, column); }

boolean
  = "#" tOrF:[tf] { return new ASTNode("boolean", (tOrF === "t"), line, column); }

string_char
  = [^\\"]
  / "\\t" { return "\t"; }
  / "\\r" { return "\r"; }
  / "\\n" { return "\n"; }
  / "\\" char:. { return char; }
  
alpha_char
  = [A-Za-z]

special_char
  = [+\-*/]
  
keyword_char
  = alpha_char / [0-9!?] / special_char
  
newline
  = [\r\n]

space
  = [\t ]

whitespace
  = newline
  / space
  / ","

comment =
  "//" (!newline .)*

_ =
  (whitespace / comment)*
