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

Sequences are denoted by square brackets, like so:

    [1, 2, 3, "four", [5, 6]]

### Maps

Maps are open, not predefined, structures that map a set of values to
corresponding values. Usually, the former value (called the key) is a
string, but it can be any type of value.

Maps are denoted by curly braces, like so:

    {"hello" "world", "name" "Clinton", "count" 12}

## Functions

### Application

Functions are applied to one and only one argument (a value or
function) at a time and return one value or function. This looks like
the following:

    function:argument

Application is evaluated right-to-left, so if a function returns
another function which you wish to apply, you will need to use
parentheses for operation order, like so:

    (fold:+):[1, 2, 3]

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

    `["a", "b", "c"]:2 // => "c"`

* Maps: maps take any value as an argument and evaluate to the value
  associated with that key. If the argument does not exist in the map
  as a key, an exception is raised.

    `{"a" 1, "b" "two", "c" 3}:"a" // => 1`


## Operators

### Definition

A function can be defined and assigned to a keyword like so:

    length = map:1 | fold:+

While the right side of this definition may not yet make sense, the
left side should. "length" is the keyword that we are assigning the
function to.

### Construction

For any set of functions f1, f2, ... fn; `<f1, f2, ... fn>` creates a
new function which constructs a sequence of each function applied to
the argument. An example:

    sum-and-multiple = <sum, multiple>
    sum-and-multiple:[1, 2, 3, 4] // => [10, 24]

### Composition

Given functions `f` and `g`, `g | f` composes a new function which
will apply the function `g` to the argument, then the function `f` to
the result. An example:

    length = map:1 | fold:+
    length:["a", "b", "cde"] // => 3

    // This is the same as:

    (fold:+):(map:1):["a", "b", "cde"]

Note that the functions are applied in left-to-right order. This
resembles the pipe syntax of Unix shells, where an input is sent to
the first command, and the output of that command is piped to the next
command. Composition does not add any abilities you could not do
without the pipe operator, but does make more readable and
understandable code.

### Constant

The operator `~` when applied to a function or value will create a new
function that returns the original. An example:

    ~x:y // => x

You may ask why this is useful, and it is a valid question. In other
function-level languages, the constant function was necessary because
values were not functions. Therefore, the length function above would
look like this:

    length = map:~1 | fold:+

You may, however, for some reason, want to create a function that
returns a sequence, map, or other function, in which case the constant
operator may be useful. This operator is under review.

### Conditional

The conditional operator is a ternary operator used for flow
control. Given a predicate and two results, it will return a function
that returns the first result if the predicate is true and the second
result if the predicate is false. An example:

    (odd -> "odd"; "even"):3

The condition must have parentheses around it if used inline, but can be
left bare for definition:

    odd-or-even = odd -> "odd"; "even"

When this function is applied to a value, the value is applied to the
predicate and to the result used. This can result in some weirdness if
you do not want to use the value in the results. In this case, use the
constant operator.

    // Will not work
    ((odd -> sin; cos):3):1.0 // => results in sin:3, which is then applied to 1.0, resulting in 3.
    // Will work
    ((odd -> ~sin; ~cos):3):1.0 // => results in (~sin:3):1.0. ~sin:3 is sin, which is then applied to 1.0.

This is obviously not optimal. _Patterns_, a more powerful conditional
form, are being considered.
