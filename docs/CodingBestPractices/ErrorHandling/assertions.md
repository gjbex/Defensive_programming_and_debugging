# Assertions

C/C++ support assertions.  These are macros defined in `assert.h` that test a Boolean condition, and will terminate the application when that condition evaluates to false.  Assertions can be used, e.g., to check preconditions, invariants and postconditions of functions.

Fortran doesn't have an assert mechanism, but using the preprocessor, you can build your own.


## Assert statements

Below you see an implementation of the factorial function.  It has some issues, but that is not relevant here.

~~~~c
int fac(int n) {
assert(n >= 0);
int result = 1;
for (int i = 2; i <= n; i++) {
    result *= i;
    assert(result > 1);
}
return result;
}
~~~~

In the code fragment above the precondition on the argument `n` is that it should be positive, since the factorial of a strictly negative integer is not defined.  This condition is verified by the assert statement.

At any given time, the variable result should be larger than 1.  This condition could be violated in case integer overflow occurs.  The invariant is checked by the second assert statement.  By construction, it also verifies the postcondition, i.e., the result of the factorial should always be larger than 1.

When you run an application that has assertions enabled, and that calls this function, you would get the following behaviour for a negative argument.

~~~~bash
$ ./assertions.exe -5
assertions.exe: assertions.c:23: fac: Assertion `n >= 0' failed.
Aborted (core dumped)
~~~~

For an argument that would cause `result` to overflow, the result is:

~~~~bash
$ ./assertions.exe 30
assertions.exe: assertions.c:27: fac: Assertion `result > 1' failed.
Aborted (core dumped)
~~~~

Although this may seem like a neat way to handle errors, it really isn't.  The feedback the user of your application gets is very low-level.  Especially for the second failure, it would be quite hard, if not impossible to figure out what went wrong without inspecting the source code.


## Use case

Since you are not supposed to use assertions to handle errors, you may wonder what purpose they serve.

In fact, assertions are quite useful while writing code because they help the developer to formalise expectations on function arguments and output (preconditions and postconditions), and to ensure that conditions that should always hold true actually do (invariants).

For production code, it is very easy to switch off assertions by defining the macro variable `NDEBUG` when building the application.

Note that assertions can have a serious impact on performance.  In the example above, the assert statement in the iteration would be executed `n` times, and we may expect the factorial function to be called often.  Executing all these tests on the value of `result` could accumulate to a noticeable fraction of the execution time of the application.


## Building with or without asserts

By way of illustration, the following make file would allow to build for release and for debug.  The former has assertions disabled, while the latter has them enabled.

~~~~
CC = gcc
CFLAGS = -g -O0 -Wall -Wextra

release: CFLAGS += -D NDEBUG

release: all
debug: all

all: assertions.exe

%.exe: %.c
	$(CC) $(CFLAGS) -o $@ $<

clean:
	$(RM) $(wildcard *.exe) $(wildcard *.o)
	$(RM) $(wildcard core.*) core
~~~~

The build targets `release` and `debug` will ensure that the `NDEBUG` macro variable is either defined or not defined respectively.

When using CMake as a build system, it will take care of this based on the value of the `CMAKE_BUILD_TYPE` variable.  When that value is either `Release` or `RelWithDebInfo`, assertions will be disabled.

Also note that depending on the level of optimisation, assertions may actually be optimised away. In the factorial example above, for instance, the assert in the iteration would be optimised out at optimisation level `-O2` when using GCC, while the one that checks the precondition would remain. Hence it may be wise to use `-O0` for debug builds.


## Asserts and testing

Although assertions can be pressed into service to implement software tests, it is better to use a unit testing framework for this purpose.
