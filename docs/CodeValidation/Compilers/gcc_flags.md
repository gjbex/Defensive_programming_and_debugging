# GCC C/C++ compiler flags

By default, the `gcc` and `g++` compilers issue some warnings, but it can produce more.  It is always good practice to switch on "all warnings" with `-Wall`.  Contrary to expectations, `-Wall` doesn't activate all warnings though.  A number of extra warnings on top of those enabled by `-Wall` can be switched on by specifying `-Wextra`.  It is highly recommended to always use these two compiler options, and eliminate all warnings reported by them, i.e.,

~~~~bash
$ gcc -Wall -Wextra ...
~~~~


## Language specification conformance

The `gcc` compiler can also check for language specification conformity."  The `-Wpedantic` flag will activate this, and you should specify the specification it should check, i.e.,

  * `-std=c89`
  * `-std=c99`
  * `-std=c11`
  * `-std=c17`

For `g++`, these values are:

  * `-std=c++98`
  * `-std=c++11`
  * `-std=c++14`
  * `-std=c++17`

For example, to check for C++14 compliance, use

~~~~bash
$ g++ ... -Wpedantic -std=c++14 ...
~~~~
