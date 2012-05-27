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
 * - constant
 * - application
 * - composition
 * - construction
 * - conditional
 */

start
  = _ expression:expression { return expression; }

expression
  = conditional

conditional
  = predicate:construction "?" _ left:conditional ";" _ right:conditional {
    return new ASTNode("conditional", [predicate, left, right], line, column);
  }
  / construction

construction
  = "<" _ expressions:construction* ">" _ {
    return new ASTNode("construction", expressions, line, column);
  }
  / composition

composition
  = left:application _ "|" _ right:composition {
    return new ASTNode("composition", [left, right], line, column);
  }
  / application
  
application
  = left:constant ":" _ right:application {
    return new ASTNode("application", [left, right], line, column);
  }
  / constant

constant
  = "~" constant:function {
    return new ASTNode("constant", constant, line, column);
  }
  / function
  
function
  = (value / keyword)
  / "(" _ expression:expression ")" _ { return expression; }

value
  = number:number _ { return number; }
  / string:string _ { return string; }
  / boolean:boolean _ { return boolean; }
  / seq:seq _ { return seq; }
  / map:map _ { return map; }

keyword
  = char:special_char _ { return new ASTNode("keyword", char, line, column); }
  / first:alpha_char rest:keyword_char* _ {
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
    return new ASTNode("int",
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
  ";;" (!newline .)*

_ =
  (whitespace / comment)*
