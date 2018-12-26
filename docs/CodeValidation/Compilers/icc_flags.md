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


## Bounds & pointer checks

Getting an array index wrong is easy, and trying to access an array using an index that is out of bounds usually results in a crash of your application with a segmentation fault (or not, which is most likely worse).

The compiler can insert code into your application to check array bounds at runtime.  When you run an application that has been compiled using this option, your application will still crash, but with an informative error message.

~~~~bash
$ icc  -check-pointers=rw  ...
~~~~

In the example above, both read and write access through pointers is checked at runtime.  To limit checks to writes only, specify `write` rather than `rw`.

_Note:_ this compiler option should only be used for development and testing, not for production.  A performance penalty is incurred since extra instructions have to be executed when your application runs.

Additionally, the compiler can also generate code to check whether dangling pointers are used, i.e., pointers to memory that has already been deallocated.

~~~~bash
$ icc  -check-pointers=rw  -check-pointers-dangling=all  ...
~~~~


## Uninitialised variables

It is good practice to explicitly initialise variables.  In many circumstances, forgetting to initialise a variable can lead to interesting and random results.  The compiler can instrument the code to check for uninitialised variables at runtime.  When such a variable is used, your application will crash with an appropriate informative error message.

~~~~bash
$ icc  -check=uninit  ...
~~~~

_Note:_ this compiler option should only be used for development and testing, not for production.  A performance penalty is incurred since extra instructions have to be executed when your application runs.

_Note:_ when the compiler flag `-Wremarks` is used, the compiler will also generate warnings on potentially uninitialised variables.


## Floating point model

The Intel compilers will optimise more aggressively than their GCC counterparts when the `-O2` flag is specified (incidentally, this is the default for Intel compilers).  A notable difference is the floating model being used.  At `-O2` the Intel compiler is free to make some assumptions that allow optimisations of your code by, e.g., using commutativity, distributivity and associativity of operators.

Although these properties strictly hold for real numbers, they do not for operations on floating point numbers.  This may give rise to different, and potentially erroneous results.

Hence it is good practice to verify results based on (non-trivial) floating point computations enforcing a floating point model that is faithful to the source code.

~~~~bash
$ icc  -fp-model source  ...
~~~~

This will ensure that no "adventurous" optimisations involving floating point operations are carried out. The result obtained with an application compiled this way should be compared to one with the default floating point value for verification.

_Note:_ For numerical intensive code, this option will severely degrade performance, and hence should be used for verification only.
