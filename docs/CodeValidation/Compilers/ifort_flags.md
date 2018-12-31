# Intel Fortran compiler flags

Although the GCC compiler suite is quite powerful, it may be worth your while to look into the Intel compilers as well.  Often they deliver executables that are better optimised than those produced by GCC. Note however that the Intel compilers are a commercial product, although you can (at the time of writing) obtain a free license for developing open source software or for training purposes.

_Note:_ you may want to read the terms of the various Intel license agreements quite carefully.

Some of the compiler flags available for `gfortran` will work with `ifort`, Intel's Fortran compiler.  However, we will point out some differences here.


## Generating warnings

The first order of business is to ensure that your code compiles without warnings.  To switch on a lot of warnings with one convenient flag, you can use:

~~~~bash
$ ifort  -warn all  ...
~~~~

Even more warnings can be switched on by:

~~~~bash
$ ifort  -warn all  -diag-enable remark  ...
~~~~


## Language specification conformance

The current Intel Fortran compiler is heir to a long lineage of compilers that implemented various extensions to the Fortran specifications over the decades.  This implies that if you, intentionally or otherwise, use such an extension, your code may not compile using other Fortran compilers, or that the semantics for these extensions differ subtly between compiler implementations.

It is good practice to adhere strictly to the standards, and the compiler can enforce that if you instruct it to.  The standard is specified as an argument, i.e., f90/f95/f03/f08/f15 for Fortran 90, 95, 2003, 2008 and 2015 respectively, e.g.,

~~~~bash
$ ifort  -stand f08  ...
~~~~

Regardless of this option, it is good practice to ensure that neither the Intel, nor the GCC compiler generates warnings on your code, so compiling with both during development is definitely a good idea.


## Additional warnings

To disable Fortran implicit typing, it is good practice to add an `implicit none` statement at the start of each compilation unit.  Needless to say, this is easy to forget, so it is good practice to compile your code with a flag that disables implicit typing for all code.
  
~~~~bash
$ ifort  -implicit-none  ...
~~~~


## Floating point model

The Intel compilers will optimise more aggressively than their GCC counterparts when the `-O2` flag is specified (incidentally, this is the default for Intel compilers).  A notable difference is the floating model being used.  At `-O2` the Intel compiler is free to make some assumptions that allow optimisations of your code by, e.g., using commutativity, distributive property and associativity of operators.

Although these properties strictly hold for real numbers, they do not for operations on floating point numbers.  This may give rise to different, and potentially erroneous results.

Hence it is good practice to verify results based on (non-trivial) floating point computations enforcing a floating point model that is faithful to the source code.

~~~~bash
$ ifort  -fp-model source  ...
~~~~

This will ensure that no "adventurous" optimisations involving floating point operations are carried out. The result obtained with an application compiled this way should be compared to one with the default floating point value for verification.

_Note:_ For numerical intensive code, this option will severely degrade performance, and hence should be used for verification only.
