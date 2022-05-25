# GCC sanitizer

GCC's `gcc`/`g++` and `gfortran` compilers support a number of runtime checks by instrumenting your code at compile time.  The workflow is straightforward:

  1. compile and link your application, letting the compiler instrument your code;
  1. run your application; and
  1. if it crashes, you get feedback on the nature of the issue.

Note that the non-instrumented application doesn't always crash, it may happily run, enthusiastically producing erroneous results for you.

The sanitizer can perform a variety of runtime checks, we will discuss a few of the most useful ones. The full documentation can be found in GCC's [manual](https://gcc.gnu.org/onlinedocs/gcc-8.2.0/gcc/Instrumentation-Options.html#Instrumentation-Options).

Building and running your unit tests with the sanitizer enabled is a very good approach.

_Note:_ The sanitizer will display the line number of the code related to the problem at hand, provided you compile with the `-g` option to include debugging information into the executable.


## Pointer issues

The first class of problems that the sanitizer tries to address is issues with pointers and arrays.  The code can be instrumented using the following option:

~~~~bash
$ gcc  -g  -fsanitize=address  ...
~~~~

When an array is accessed out of bounds, the program will halt, report the memory address of the illegal access, and show a stack trace.


## Memory leaks

When using dynamic memory allocation (`malloc` in C or `new` in C++) it is important to pair those allocations with deallocations (`free` in C, `delete` in C++).  Failing to do so may result in memory leaks, i.e., your application consumes more and more memory over time.  Chances are that at some point during the execution, no more memory is available, and your application will exit if your code checks the result of the allocation, or crashes with a segmentation fault otherwise.

Given the complexity of managing memory by hand, it shouldn't come as a surprise if your application has a memory leak.  Again, the compiler can help you detect these at runtime by instrumenting the application.

~~~~bash
$ gcc  -g  -fsanitize=leak  ...
~~~~

When the application finishes, a report is generated on the memory that is inaccessible at exit, and where in the source code this was allocated.  It is then up to you to add a deallocation in the proper location to avoid the leak.


## Undefined behaviour

The third, very broad class of issues that the sanitizer may spot is undefined behaviour.  In general, these are issues that the programming language specification doesn't define the behaviour for.  For example, the C specification doesn't define what should happen when an array is accessed out of bounds.

GCC's documentation is a bit confusing on this topic.  On the one hand, it states that
> -fsanitize=undefined:
>  Enable UndefinedBehaviorSanitizer, a fast undefined behavior detector. Various computations are instrumented to detect undefined behavior at runtime. Current suboptions are:
> ...

However, although all suboptions are equal, clearly some are more equal than others.  For instance, the check for floating point division by zero is not switched on by `-fsanitize=undefined`.  Admittedly, the documentation states this explicitly.
> -fsanitize=float-divide-by-zero:
>    Detect floating-point division by zero. Unlike other similar options, -fsanitize=float-divide-by-zero is not enabled by -fsanitize=undefined, since floating-point division by zero can be a legitimate way of obtaining infinities and NaNs.

You would have to specify `-fsanitize=float-divide-by-zero` explicitly, as well as some of the other suboptions.  Read the documentation carefully.

A few of the interesting undefined behaviours the sanitizer will check for are:
  1. `bounds`: array indices out of bounds (_note:_ computationally cheaper than address sanitizing, but restricted to arrays only);
  1. `float-divide-by-zero`: floating point division by zero;
  1. `integer-divide-by-zero`: integer division by zero;
  1. `null`: error on null pointer dereferencing, rather than segmentation fault.

Note that both `bounds` and `null` are also captured by `-fsanitize=address`, but the former are more lightweight with respect to the instrumentation.


## Integer overflow

Unfortunately (depending on your point of view), integer overflow is not an error.  The sanitizer can detect it in some circumstances when you specify `-fsanitize=signed-integer-overflow`.  Note that the compiler doesn't always instrument the code, so there may be false negatives.
