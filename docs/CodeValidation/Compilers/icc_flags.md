# Intel C/C++ compiler flags

Although the GCC compiler suite is quite powerful, it may be worth your while to look into the Intel compilers as well.  Often they deliver executables that are better optimised than those produced by GCC. Note however that the Intel compilers are a commercial product, although you can (at the time of writing) obtain a free license for developing open source software or for training purposes.

_Note:_ you may want to read the terms of the various Intel license agreements quite carefully.

Some of the compiler flags available for `gcc`/`g++` will work with `icc`/`icpc`, Intel's C and C++ compilers.  However, we will point out some differences here.


## Generating warnings

The first order of business is to ensure that your code compiles without warnings.  To switch on a lot of warnings with one convenient flag, you can use the same flag as for GCC, i.e.,

~~~~bash
$ icc  -Wall  ...
~~~~

Even more warnings can be switched on by:

~~~~bash
$ icc  -Wall  -Wremarks  -Wchecks  -w3  ...
~~~~


## Floating point model

The Intel compilers will optimise more aggressively than their GCC counterparts when the `-O2` flag is specified (incidentally, this is the default for Intel compilers).  A notable difference is the floating model being used.  At `-O2` the Intel compiler is free to make some assumptions that allow optimisations of your code by, e.g., using commutativity, distributivity and associativity of operators.

Although these properties strictly hold for real numbers, they do not for operations on floating point numbers.  This may give rise to different, and potentially erroneous results.

Hence it is good practice to verify results based on (non-trivial) floating point computations enforcing a floating point model that is faithful to the source code.

~~~~bash
$ icc  -fp-model source  ...
~~~~

This will ensure that no "adventurous" optimisations involving floating point operations are carried out. The result obtained with an application compiled this way should be compared to one with the default floating point value for verification.

_Note:_ For numerical intensive code, this option will severely degrade performance, and hence should be used for verification only.
