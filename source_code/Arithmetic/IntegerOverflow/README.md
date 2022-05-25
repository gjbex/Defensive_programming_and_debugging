# Integer overflow

Integer overflow can lead to very dangerous bugs, but they are not
considered an error by the CPU.  Hence they can only be caught using
instrumentation by the compiler.

## What is it?

1. `overflow_test.f90`: overflow on int32.
1. `overflow_8_test.f90`: overflow on int8.
1. `narrowing_test.f90`: ussues due to narrowing conversion of
   integers.
1. `Makefile`: make file to build the applications.

## How to use?

For each source file, three applications will be built.
1. no instrumentation,
1. instrumenting with `-ftrapv`,
1. instrumenting with sanitizer.
