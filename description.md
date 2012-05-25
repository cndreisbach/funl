# The FunL Programming Language

## A short description

FunL is a function-level language as defined by John Backus in his
1977 ACM Turing Award lecture,
"[Can Programming Be Liberated From the von Neumann Style?][turing-lecture]"
Function-level languages are intended to "make programming
sufficiently cheaper or more reliable to justify the cost of producing
and learning to use them."  (Backus 1977)

FunL can be best described by what it lacks:

* Variables
* Multiple scopes
* State

Because of this, it is very easy to take part of a FunL program and
insert it into another FunL program without worry. FunL has an algebra
of functions that allows for direct substitution of function
definitions into function application, as well as comparing the
equality of two functions.

All values in FunL are also functions, allowing the composition of any
combination of values and functions in the language.

[turing-lecture]: http://www.stanford.edu/class/cs242/readings/backus.pdf

## Values

There are four types of values in FunL: numbers, strings, sequences, and maps.

### Numbers

Numbers are integer or float values. They are constrained by their
host language, JavaScript, and have the same properties as JavaScript
numbers.

### Strings

Strings are what you think they are: lists of characters. Strings are
specified in FunL with double-quotes and can extend over multiple
lines.

### Sequences

Sequences are heterogenous lists of other values. No guarantee is made
as to their implementation currently, so they may be linked lists or
based on JavaScript arrays.

Sequences are denoted by parentheses, like so:

    (1, 2, 3, "four", (5, 6))

### Maps

Maps are open, not predefined, structures that map a set of values to
corresponding values. Usually, the former value (called the key) is a
string, but it can be any type of value.

Maps are denoted by curly braces, like so:

    {"hello" "world", "name" "Clinton", "count" 12}

## Functions

### Definition

A function can be defined and assigned to a keyword like so:

    length = map[1] | fold[+]
    
While the right side of this definition may not yet make sense, the
left side should. "length" is the keyword that we are assigning the
function to.

### Application

Functions are applied to one and only one argument (a value or
function) at a time and return one value or function. This looks like
either of the following:

    length:argument
    length[argument]
    
The first form is the common form of application. It is evaluated
right-to-left. The second form is used to change evaluation rules: it
binds tighter than the first form. It is most usually used with
functions that return other functions.

### Values as Functions

All values are also functions.

* Numbers: numbers take any value as an argument and evaluate to
  themselves.

    `3.14:1 // => 3.14`
    
* Strings: strings take any value as an argument and evaluate to
  themselves.

    `"hello world":1 // => "hello world"`
    
* Sequences: sequences take an integer as an argument and evaluate to
  the value at that index in the sequence. Sequences are indexed from
  zero. If the argument is too large an index for the sequence, an
  exception is raised.

    `("a", "b", "c"):2 // => "c"`
    
* Maps: maps take any value as an argument and evaluate to the value
  associated with that key. If the argument does not exist in the map
  as a key, an exception is raised.
  
    `{"a" 1, "b" "two", "c" 3}:"a" // => 1`




