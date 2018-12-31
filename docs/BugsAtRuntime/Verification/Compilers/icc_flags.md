# Intel C/C++ compiler flags for runtime checks

The `icc`/`icpc` compilers can instrument code to do a number of runtime checks.  This will have a performance impact, so production code should never be compiled with these options enabled.


## Floating point exceptions

The compiler can instrument the code to trap floating point exceptions.  The `fp-trap` (in `main`) and `-fp-trap-all` (in all functions) options take the following values as a comma-separated list:

  * `invalid`,
  * `divzero`,
  * `overflow`,
  * `common`: the previous three values,
  * `denormal`,
  * `underflow`,
  * `inexact`: probably not very useful since most floating point operations will lead to loss of accuracy,
  * `all`.

It may also be helpful to switch on floating point stack checking after each function call, which you can do by adding the `-fp-stack-check` flag.

To instrument for the most common floating point exceptions, compile with:

~~~~bash
$ icc -fp-trap-all=common -fp-stack-check ...
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

To check for stack buffer overruns, the `icc`/`icpc` compilers provide a specific flags as well.  The `-fstack-protector` enables overrun checks on some types of buffers, while `-fstack-protector-strong` will check for all types of buffers.  Additioally, the `-fstack-protector-all` flag will ensure checks in all functions.

~~~~bash
$ icpc -fstack-protector-strong -fstack-protector-all ...
~~~~

Alternatively, the options `-check=stack` can also be used to detect stack buffer overruns and underruns.


## Uninitialised variables

It is good practice to explicitly initialise variables.  In many circumstances, forgetting to initialise a variable can lead to interesting and random results.  The compiler can instrument the code to check for uninitialised variables at runtime.  When such a variable is used, your application will crash with an appropriate informative error message.

~~~~bash
$ icc  -check=uninit  ...
~~~~

_Note:_ this compiler option should only be used for development and testing, not for production.  A performance penalty is incurred since extra instructions have to be executed when your application runs.

_Note:_ when the compiler flag `-Wremarks` is used, the compiler will also generate warnings on potentially uninitialised variables.


## Other checks

To check for narrowing conversions at runtime, the `-check=conversions` option is useful.
