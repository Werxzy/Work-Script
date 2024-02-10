# Work Script for Pico8

## Syntax

```text
/ Comments can be created by placing "/" at the start of a comment.

    cls

/ A function can be called by having its name at the start of a line.
/ Functions can by anything defined by _ENV or by compiling

    print hello 10 10

/ parameters can be provided after the function name, separated a space.

    time = _a

/ Values returned by a function can be given to variables
/ The type of variable depend on the first character
/ _a is a local variable, only accessable via the current Work Script function call.
/ .a is an object variable, stored in a provided table.
/ @a is a variable accessable by all Work Script instances.
/ a is a string

    cos _a = _b

/ A function call can have any number of parameters and return values, provided the function accepts them.

/ example of function named avg
    math _1 + _2 / 2 = _1
    returning _1
/ usage
    avg 1.2 3.1 = _a
    print _a

/ _1 numbered variables are allowed and are primarily used as parameter names for Work Script functions.

loop:
    cls
    go_to #loop

/ labels can be created by using ":" after the name.
/ Execution can jump to labels by using go_to and referencing the label with "#".
/ Label references with # get turned into integers after compiling based on their position within the function calls. 
```
