# The FunL Programming Language

## Short description

FunL is a function-level language as defined by John Backus in his
1977 ACM Turing Award lecture, "Can Programming Be Liberated From the
von Neumann Style?"  Function-level languages are intended to "make
programming sufficiently cheaper or more reliable to justify the cost
of producing and learning to use them."  (Backus 1977)

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

For a more full description, see
http://github.com/cndreisbach/funl/blob/master/description.md.

## Example

```funl
length = map:1 | fold:+

length:[1, 2, 3] // => 3

// Decomposition of the above
// (map:1 | fold:+):[1, 2, 3]
// (fold:+):(map:1):[1, 2, 3]
// (fold:+):[1:1, 1:2, 1:3]
// (fold:+):[1, 1, 1]
// +:[+:[1, 1], 1]
// 3 
```

