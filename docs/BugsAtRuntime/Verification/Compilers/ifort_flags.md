# Intel Fortran compiler flags for runtime checks

The `ifort` compiler can instrument code to do a number of runtime checks.  This will have a performance impact, so production code should never be compiled with these options enabled.

## Stack traces

When your application crashes, you want as much information as possible, so that the problem can be fixed as soon as possible.  Compiling with debugging information enabled will of course help, but the Intel compiler has an additional option to provide more useful information.

~~~~bash
$ ifort  -traceback  ...
~~~~

This traceback option will produce a stack dump that is much more informative than what is ordinarily produced by the Fortran runtime.


## Floating point exceptions

Floating point exception can be trapped when using the `-fpe-all` option that takes a level as value.  Level 0 will abort the application when one of the following floating point exceptions occurs:

  * invalid,
  * divide-by-zero,
  * overflow.

It will set underflow results to zero as well.  To get more feedback on the origin of the floating point exception this options is best combined with `-traceback`, i.e.,

~~~~bash
$ ifort -traceback -fpe-all=0 ...
~~~~


## Array bounds checks

Getting an array index wrong is easy, and trying to access an array using an index that is out of bounds usually results in a crash of your application with a segmentation fault (or not, which is most likely worse).

The compiler can insert code into your application to check array bounds at runtime.  When you run an application that has been compiled using this option, your application will still crash, but with an informative error message.

~~~~bash
$ ifort  -check bounds  ...
~~~~

_Note:_ this compiler option should only be used for development and testing, not for production.  A performance penalty is incurred since extra instructions have to be executed when your application runs.


## Uninitialised variables

It is good practice to explicitly initialise variables.  In some circumstances, forgetting to initialise a variable can lead to interesting and random results.  The compiler can instrument the code to check for uninitialised variables at runtime.  When such a variable is used, your application will crash with an appropriate informative error message.

~~~~bash
$ ifort  -check uninit  ...
~~~~

_Note:_ this compiler option should only be used for development and testing, not for production.  A performance penalty is incurred since extra instructions have to be executed when your application runs.


## Other checks

Besides `bounds` and `uninit`, various other runtime checks are available.  All of the can be activated by specifying `-check all`.  More specifically, the following are of interest for debugging purposes:

  * `contiguous`:  verifies that a pointer to contiguous data is not assigned to a non-contiguous object, e.g., by slicing;
  * `pointers`: verifies that no disassociated or uninitialized pointers are used, nor unallocated allocatable objects;
  * `shape`: checks array conformance, e.g., in assignments and `allocate` with an `source` argument;
  * `stack`: checks the stack for buffer overrun or underrun;
  * `format` and `output_conversion`: enables various checks on formats for output.

_Note_: The `stack` check will disable all optimisations, i.e., implies `-O0` so this check should never be enabled for production, and by implication, the same holds for `all`.
