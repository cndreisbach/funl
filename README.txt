The FunL Programming Language
Clinton N. Dreisbach <crnixon@gmail.com>

SHORT DESCRIPTION

FunL is a function-level language as defined by John Backus in his 1977 ACM
Turing Award lecture, "Can Programming Be Liberated From the von Neumann Style?"
Function-level languages are intended to "make programming sufficiently cheaper
or more reliable to justify the cost of producing and learning to use them."
(Backus 1977)

FunL can be best described by what it lacks:

* Variables
* Multiple scopes
* State

Because of this, it is very easy to take part of a FunL program and insert it
into another FunL program without worry. FunL has an algebra of functions that
allows for direct substitution of function definitions into function
application, as well as comparing the equality of two functions.

All values in FunL are also functions, allowing the composition of any
combination of values and functions in the language.

For a more full description, see http://github.com/crnixon/funl/description.md.

EXAMPLE

def length = map[1] | fold[+]

length:<1, 2, 3> // => 3

// Decomposition of the above
// (map[1] | fold[+]):<1, 2, 3>
// fold[+]:(map[1]:<1, 2, 3>)
// fold[+]:<1:1, 1:2, 1:3>
// fold[+]:<1, 1, 1>
// 3 


LICENSE

FunL is released under the Simplified BSD License, which is printed below.

Copyright (c) 2012 Clinton N. Dreisbach
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met: 

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer. 
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution. 

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies, 
either expressed or implied, of the FreeBSD Project.

