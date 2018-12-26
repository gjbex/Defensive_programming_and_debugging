# Bugs in data

Some bugs in this category aren't directly caused by you as a programmer, but rather by the user of your software.  Any application requires data as input.  This can be as trivial as a few command line arguments, or as complex as reading a data file in some arcane format.  If the input data doesn't meet the expectations of your application, the latter may crash, or worse, produce incorrect results.  Although there are no actual tools to help out, a few tips may prove valuable.

Data conversion is another source of problems, and here careless programming can actually be the problem.


## Input data

Validate your input data.  Ensure that when you convert a string representation to, e.g., a number,

  * you don't use functions that silently fail,
  * no errors are raised that you do not handle, and
  * the string is processed completely.

Examples were given in the sections on error handling.

If there are some requirements on the input data, you would be wise to verify that they are met.  For instance, if you expect a number to be positive, check that it is.  Input validation is one of the areas where Grace Hopper's maxim doesn't apply.  Asking permission is a bit of a bother, and sometimes a lot of work, but far better than having to ask forgiveness.

When you define a file format for input data, it is good practice to write a validator.  Such an application simply parses the data file, and validates its contents, giving warnings and errors if necessary.  The functions for this implementation can be reused in the application(s) that actually process this data.

Never write your own code to parse a data format if an off-the-shelf library is available.  Even deceivingly simple data formats such as comma separated values files (CSV) are surprisingly hard to parse correctly.  There are quite some edge and corner cases to consider, many caused by platform specific issues.  Don't even think of implementing your own parser for XML.

Fortunately, implementations for parsers that deal with common scientific data formats are available for Fortran, C, and C++.  Using those will improve the robustness of your code.  If they fail, oh well, at least you can blame someone else.

Note that there is an overlap here with the section on bugs in requirements.  Carefully specifying the requirements for command line arguments and input data will help you develop accurate validators and more robust code.


## Data conversion

A fairly large number of bugs is caused by inappropriate data conversion.  In some cases, you may potentially loose information due to conversion. For instance, converting 64 bits integers to 32 bits values will in general cause problems.  Similar, converting a double precision floating point value to single precision will loose precision.  These are called 'narrowing conversions'.


### C/C++

C and C++ compilers will not prevent you from doing narrowing conversions by default.  Even with `-Wall` and `-Wextra` enabled you will get no warnings.  However, adding the `-Wconversion` flag proves to be quite useful.  It will produce warnings for each narrowing conversion in the following code fragment.

~~~~c
#include <stdio.h>

int main() {
    long a = 94850485030;
    long b = 495849853000;
    int c = a + b;
    printf("c = %d\n", c);
    double x = 1.435e67;
    double y = 4.394e89;
    float z = x + y;
    printf("z = %e\n", z);
    int d = x;
    printf("d = %d\n", d);
    return 0;
}
~~~~


### Fortran

The `gfortran` compiler will give you warnings when you specify `-Wall`, so it will give three for the following code:

~~~~fortran
program conversions
    use, intrinsic :: iso_fortran_env, only : &
        r8 => REAL64, r4 => REAL32, i8 => INT64, i4 => INT32
    implicit none
    real(kind=r8) :: x, y
    real(kind=r4) :: z
    integer(kind=i8) :: a, b
    integer(kind=i4) :: c, d
    x = 1.394e76_r8
    y = 2.37e56_r8
    z = x + y
    print '(E15.5)', z
    a = 309403103049_i8
    b = 49031944903_i8
    c = a + b
    print '(I15)', c
    d = z
    print '(I15)', d
end program conversions
~~~~
