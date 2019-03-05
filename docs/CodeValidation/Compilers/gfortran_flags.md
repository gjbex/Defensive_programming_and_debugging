# Options for GCC's Fortran compiler

By default, the `gfortran` compiler issues some warnings, but it can produce more.  It is always good practice to switch on "all warnings" with `-Wall`.  Contrary to expectations, `-Wall` doesn't activate all warnings though.  A number of extra warnings on top of those enabled by `-Wall` can be switched on by specifying `-Wextra`.  It is highly recommended to always use these two compiler options, and eliminate all warnings reported by them, i.e.,

~~~~bash
$ gfortran -Wall -Wextra ...
~~~~


## Language specification conformance

The `gfortran` compiler can also check for language specification conformity, at least up to some level, to quote the documentation, "improvements to GNU Fortran in this area are welcome."  The `-Wpedantic` flag will activate this, and you should specify the specification it should check, i.e.,

  * `-std=f95`
  * `-std=f2003`
  * `-std=f2008`
  * `-std=f2018`

For example, to check for Fortran 2003 compliance, use

~~~~bash
$ gfortran ... -Wpedantic -std=f2003 ...
~~~~


## Additional warnings

A few other options can be helpful as well.  Those are not activated by `-Wall` and `-Wextra`.

It is good practice to have `implicit none` in each compilation unit, but that is also easy to forget.  The compiler has a flag, `-fimplicit-none`, that will verify that all variables have been declared, regardless of whether `implicit none` was specified.

Another good practice is to explicitly declare what to use from a module in a `use` statement.  The compiler can warn you when this has not been done if you specify the `-Wuse-without-only` flags.

You may want to be warned if you use variables that are not uninitialised, since this could lead to nasty bugs.  Use the `-Wmaybe-uninitialized` flag to do so (included in `-Wall`). *Note:* this warning will only be reported when the compiler is optimising the code, i.e., when you specify at least `-O1`.  Without optimisation, enabling this warning would produce too many false positives.

It can also be useful to verify that procedures are either intrinsic, or have been declared `external` explicitly.  You can activate this check using the `-Wimplicit-procedure` flag.

A potential source of bugs is unintended integer division.  Computing a value such as `1/2` will yield 0, which is most likely not your intention.  The compiler can detect this and issue a warning when you add the `-Winteger-division` flag.  However, remember that this is a compile time check, so you will not get a warnings for an expression such as `a/b` where `a` and `b` are `integer` variables, but their values are the result of a computation.

Some additional checks on implicit conversion between types and kinds can be activated using the `-Wconversion-extra` flag.
