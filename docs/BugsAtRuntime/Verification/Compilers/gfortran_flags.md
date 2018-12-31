# GCC Fortran compiler flags for runtime checks

The `gfortran` compiler can instrument code to do a number of runtime checks.  This will have a performance impact, so production code should never be compiled with these options enabled.


## Floating point exceptions

Floating point exception can be trapped when using the `-ffpe-trap` option that takes a comma-separated list of the following values:

  * `invalid`: traps, e.g., `sqrt(-1.0)`;
  * `overflow`: numerical overflow;
  * `zero`: traps division by zero;
  * `underflow`: numerical underflow;
  * `inexact`: likely not useful, since most floating point operations incur loss of precision;
  * `denomralized`: operations on denormal values, i.e., infinity or NaN.

Unless you explicitly handle floating point exceptions in your code, it may be useful to compile with trapping of the first three exceptions enabled, i.e.,

~~~~bash
$ gfortran -ffpe-trap=invalid,overflow,zero ...
~~~~


## Array bounds checks

Getting an array index wrong is easy, and trying to access an array using an index that is out of bounds usually results in a crash of your application with a segmentation fault (or not, which is most likely worse).

The compiler can insert code into your application to check array bounds at runtime.  When you run an application that has been compiled using this option, your application will still crash, but with an informative error message.

~~~~bash
$ gfortran  -fcheck=bounds  ...
~~~~

_Note:_ this compiler option should only be used for development and testing, not for production.  A performance penalty is incurred since extra instructions have to be executed when your application runs.


## Other checks

Several other runtime checks besides `bounds` can be enabled using the `-fcheck` option that take the value `all`, or a comma-separated list of the following values:

  * `do`: verify that no invalid loop control variables modifications are done;
  * `mem`: check implicit memory allocations;
  * `pointer`: check use of pointers and allocations;
  * `recursion`: checks that only procedures that are declared `recursive` are used recursively;
  * `array-temps`: checks construction of temporary arrays (not useful for debugging, but very interesting for optimisation).

Again, instrumenting your code with these runtime checks will generate overhead, so you will probably only want to enable this while developing and testing your code.
