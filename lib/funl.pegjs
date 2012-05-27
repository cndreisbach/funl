// Initialization code

{
  var ASTNode = function(type, value, line, column) {
    this.type = type;
    this.value = value;
    this.line = line;
    this.column = column;
  };

  ASTNode.prototype.toObj = function() {
    return { type: this.type, value: this.value };
  };
}

start
  = _ expression:expression { return expression; }

expression
  = left:function ":" _ right:expression _ { return new ASTNode("application", [left, right], line, column); }
  / function
  
function
  = value
  / keyword
  / "(" _ expression:expression _ ")" _ { return expression; }

value
  = number:number _ { return number; }
  / string:string _ { return string; }
  / boolean:boolean _ { return boolean; }
  / seq:seq _ { return seq; }
  / map:map _ { return map; }

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

keyword
  = char:special_char { return new ASTNode("keyword", char, line, column); }
  / first:alpha_char rest:valid_char+ {
    return new ASTNode("keyword", first + rest.join(""), line, column);
  }
  
string_char
  = [^\\"]
  / "\\t" { return "\t"; }
  / "\\r" { return "\r"; }
  / "\\n" { return "\n"; }
  / "\\" char:. { return char; }
  
alpha_char
  = [A-Za-z]

special_char
  = [+\-*/><]
  
valid_char
  = alpha_char / special_char / [0-9_?!=@#$%^&]
  
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
