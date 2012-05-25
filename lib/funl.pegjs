start
  = value
  / keyword

value
  = number:number _ { return number; }
  / string:string _ { return string; }
  / seq:seq _ { return seq; }

seq
  = "<" values:value* ">" { return values; }

number
  = float
  / integer
  
integer
  = negative:'-'? number:[0-9]+ { return parseInt(negative + number.join("")); }

float
  = negative:'-'? whole:[0-9]+ '.' decimal:[0-9]+
    { return parseFloat(negative + whole.join("") + "." + decimal.join("")); }

string
  = '"' string:string_char* '"' { return string.join(""); }

string_char
  = [^\\"]
  / "\\t" { return "\t"; }
  / "\\r" { return "\r"; }
  / "\\n" { return "\n"; }
  / "\\" char:. { return char; }

keyword
  = special_char
  / first:alpha_char rest:valid_char+ { return first + rest.join(""); }

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