# Error handling in C

Quite a number of bugs are introduced due to incorrect or even no handling of error conditions during the execution of an application.  This type of defect is especially annoying since the symptoms will occur some time after the actual cause, and manifest themselves in functions that seem to have little to do with that cause.  This "lack of locality" makes identifying the issue quite hard.

A defensive style of programming will help to prevent these situations.

Note that proper error handling can be quite complex and increase the size of your code base substantially.


## Dynamic memory allocation

In C, a primary example of non-local issues is the management of dynamic memory, i.e., memory allocated on the heap using `malloc` or a related function.

Consider the following code:

~~~~c
#include <stdlib.h>

double *create_vector(unsigned long n) {
    return (double *) calloc(n, sizeof(double));
}
...
void daxpy(double alpha, double *x, double *y, unsigned long n) {
    for (unsigned long i = 0; i < n; i++)
        x[i] = alpha*x[i] + y[i];
}
~~~~

Allocation functions such as `calloc` will return a `NULL` value when there is not enough memory space to accommodate the request.  However, since `create_vector` doesn't check, the application will continue under the assumption that its result is indeed an array with all `n` elements set to zero.

At some point, e.g., in a call to the function `daxpy`, the `double` pointer `x`, or `y`, or both may in fact contain that `NULL`, and the application will crash with a segmentation fault. The problem, in this case merely a symptom, will occur in `daxpy`, while the cause is in fact in `create_vector`, or, to be more precise, wherever the size of the array was computed. If this is a complex application, it may take you a while to track down the root cause of this crash.

You want errors to occur as soon as possible since the closer that happens in space and time to the root cause, the easier it will be to identify and fix the issue.

In this particular case, the function `create_vector` should check whether `calloc` returns `NULL`, and if so, generate an error.

~~~~c
#include <err.h>
#include <stdlib.h>

#define MEM_ALLOC_ERR 11

double *create_vector(unsigned long n) {
    double *v = (double *) calloc(n, sizeof(double));
    if (v == NULL)
        errx(MEM_ALLOC_ERR, "can't allocate vector of size %lu", n);
    return v;
}
~~~~

The `errx` function declared in the `err.h` will print the error message to standard error and terminate the application with exit status `MEM_ALLOC_ERR`.  This makes it a lot easier to find the problem since you only need to figure out why the value of `n` is too large.

Seasoned C programmers will argue that the above code fragment is not idiomatic and should be written as:

~~~~c
double *create_vector(unsigned long n) {
    double *v;
    if (!(v = (double *) calloc(n, sizeof(double))))
        errx(MEM_ALLOC_ERR, "can't allocate vector of size %lu", n);
    return v;
}
~~~~

When this application is run and it fails, this will produce the following output:

~~~~
allocation_error.exe: can't allocate data of size 10000000000
~~~~

Although this error message describes the issue, it could be more informative by using the values of a few macros:

  * `__FILE__` contains the name of the source file it occurs in,
  * `__LINE__` contains the line number of the source file it occurs on,
  * `__func__` contains the name of the current function (introduced in C99).


~~~~c
double *create_vector(unsigned long n) {
    double *v;
    if (!(v = (double *) calloc(n, sizeof(double))))
        errx(MEM_ALLOC_ERR, "%s:%d (%s) can't allocate vector of size %lu",
             __FILE__, __LINE__, __func__, n);
    return v;
}
~~~~

 Now the output would be:

 ~~~~bash
 allocation_error.exe: allocation_error.c:12 (create_vector): can't allocate data of size 10000000000
 ~~~~

The `__LINE__` macro is set to the line number it occurs on in the source file, so it will not actually be the line number on which the error occurs, but it points you in the  right direction anyway.

Although it is possible to print a backtrace of the current stack, that is probably not worth the effort since this can be handled more easily and conveniently using a debugger.


## String conversion

Often, the functions `atoi`, `atol`, and `atof` are used to convert command line arguments to `int`, `long`, and `float`/`double` values respectively.  However, in general, this is not good practice.

When the `char` array passed to these functions can not be converted to the desired data type, the behaviour is undefined according to the C specification.  In other words, it is up to the implementer of the standard library to decide what happens in this case.

For instance, consider the following simple program:

~~~~c
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    long n = 5;
    double a = 3.14;
    if (argc > 1)
        n = atol(argv[1]);
    if (argc > 2)
        a = atof(argv[2]);
    printf("n = %ld, a = %lf\n", n, a);
    return 0;
}
~~~~

When you compile this with either GCC or Intel compilers and run it, you will get the following output:

~~~~bash
$ ./command_line_args.exe
n = 5, a = 3.140000

$ ./command_line_args.exe 15abc 1.43e-2def
n = 15, a = 0.014300

$ ./command_line_args.exe 12.73
n = 12, a = 3.140000

$ ./command_line_args.exe abc def
n = 0, a = 0.000000
~~~~

When used as intended, the applications works as expected.  However, when the values passed via the command line are not appropriate, the application will run without warnings or errors, but it will most likely produce results you don't expect.

This is an argument to avoid `atoi` and its ilk, and to use functions that are more robust and check for problems.  The following code illustrates how to use `strtol` and `strtod`.

~~~~c
#include <err.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    long n = 5;
    double a = 3.14;
    if (argc > 1) {
        char *end_ptr = argv[1];
        n = strtol(argv[1], &end_ptr, 10);
        if (*end_ptr != '\0' || end_ptr == argv[1])
            warnx("'%s' could not be (completely) converted to long",
                  argv[1]);
    }
    if (argc > 2) {
        char *end_ptr = argv[2];
        a = strtod(argv[2], &end_ptr);
        if (*end_ptr != '\0' || end_ptr == argv[2])
            warnx("'%s' could not be (completely) converted to double",
                  argv[2]);
    }
    printf("n = %ld, a = %lf\n", n, a);
    return 0;
}
~~~~

This application will issue warnings if the command line arguments can not be converted properly.  The value of `end_ptr` is used to detect issues.  If  

  * `*end_ptr` != '\0', then the first part the the argument could be converted to a number, but subsequent characters could not, e.g., `15abc`;
  * `end_prt == argv[1]`, then either the argument was an empty string or it completely consists of characters that can not be converted to a number.

Of course, substituting `errx` for `warnx` would terminate the application rather than just print a warning message.  Which action is most appropriate depends on the application.  Just like `errx`, `warnx` is declared in `err.h`.

Of course, when you have to deal with non-trivial command line arguments such as options and flags, you should consider using the functions declared in `unistd.h` for that purpose.  This is however outside the scope of this course.


## File I/O

When reading or writing files quite a number of things can go wrong.

Just like the functions for memory allocation, the `fopen` function will return a null pointer when the operation fails.  If you don't check for that, your application will most likely crash with a segmentation fault as soon as it attempts to read or write.

The code fragment below will open a file, read it line by line, and output the length of each line, followed by the line itself.

~~~~c
#include <err.h>
#include <stdio.h>
#include <stdlib.h>

#define ARG_ERR 1
#define FILE_OPEN_ERR 2

int main(int argc, char *argv[]) {
    if (argc == 1)
        errx(ARG_ERR, "no file name specified");
    FILE *fp;
    char *line = NULL;
    size_t buffer_length;
    ssize_t nr_chars;
    if (!(fp = fopen(argv[1], "r")))
        err(FILE_OPEN_ERR, "can't open file '%s' for reading", argv[1]);
    while ((nr_chars = getline(&line, &buffer_length, fp)) != -1) {
        printf("%3zu: %s", nr_chars, line);
    }
    free(line);
    fclose(fp);
    return 0;
}
~~~~

The application verifies that the file has been opened successfully, and if not, it uses the `err` function declared in `err.h` to report this and terminate the application.  The `err` function is quite similar to `errx`, but it will also print the error message associated with the failed system call. For instance, when called with a file that doesn't exist, you will get the following error message:

~~~~bash
$ ./file_error.exe bla
file_error.exe: can't open file 'bla' for reading: No such file or directory
~~~~

On the other hand, if it is called with a file that exists, but that you don't have permission to read or write, you would get the following:

~~~~bash
$ ./file_error.exe test.txt
file_error.exe: can't open file 'test.txt' for reading: Permission denied
~~~~

In this case, using `err` rather than `errx` improves the quality of the error message and helps the user of your application to figure out what the problem might be.

It is also quite useful to check the return value of functions like `scanf`. This will alert you to problems that may otherwise go unnoticed. Consider the following input file that is used to initialise the coordinates of 3D point:

~~~~
x = 1.1
y = 2.2
z = 3.3
~~~~

The following application reads that configuration file and prints the coordinates of the point.

~~~~c
#include <err.h>
#include <stdio.h>
#include <string.h>

#define ARG_ERR 1
#define FILE_OPEN_ERR 2
#define VALUE_ERR 3

typedef struct {
    double x, y, z;
} Point;

int main(int argc, char *argv[]) {
    if (argc == 1)
        errx(ARG_ERR, "no file name specified");
    FILE *fp;
    char name[20];
    double value;
    Point point;
    if (!(fp = fopen(argv[1], "r")))
        err(FILE_OPEN_ERR, "can't open file '%s' for reading", argv[1]);
    while (fscanf(fp, "%s = %lf", name, &value) != -1) {
        if (!strcmp("x", name))
            point.x = value;
        else if (!strcmp("y", name))
            point.y = value;
        else if (!strcmp("z", name))
            point.z = value;
        else
            errx(VALUE_ERR, "invalid name '%s'", name);
    }
    fclose(fp);
    printf("x = %lf, y = %lf, z = %lf\n", point.x, point.y, point.z);
    return 0;
}
~~~~

Even with an incorrect input file such as the one below, this application will continue to run, most likely producing nonsense results.

~~~~
x = 1.1
y =
z = 3.3
~~~~

The output would be the following, an unintended result is printed, and no errors are reported:

~~~~bash
$ ./read_error_incorrect.exe input_incomplete.txt
x = 1.100000, y = 1.100000, z = 3.300000
~~~~

The following input would cause an error, although it is a fairly cryptic one:

~~~~
x = 1.1
y = O.5
z = 3.3
~~~~

This would be the output:

~~~~bash
./read_error_incorrect.exe input_nok.txt
read_error_incorrect.exe: invalid name 'O.5'
~~~~

Explicitly checking the number of values processed by `fscanf` will detect the problem and avoid some nasty issues later on.

~~~~c
#include <err.h>
#include <stdio.h>
#include <string.h>

#define ARG_ERR 1
#define FILE_OPEN_ERR 2
#define VALUE_ERR 3

typedef struct {
    double x, y, z;
} Point;

int main(int argc, char *argv[]) {
    if (argc == 1)
        errx(ARG_ERR, "no file name specified");
    FILE *fp;
    int nr_read;
    int line_nr = 0;
    char name[20];
    double value;
    Point point;
    if (!(fp = fopen(argv[1], "r")))
        err(FILE_OPEN_ERR, "can't open file '%s' for reading", argv[1]);
    while ((nr_read = fscanf(fp, "%s = %lf", name, &value)) != -1) {
        line_nr++;
        if (nr_read != 2)
            errx(VALUE_ERR, "invalid input on line %d of %s\n",
                 line_nr, argv[1]);
        if (!strcmp("x", name))
            point.x = value;
        else if (!strcmp("y", name))
            point.y = value;
        else if (!strcmp("z", name))
            point.z = value;
        else
            errx(VALUE_ERR, "invalid name '%s'", name);
    }
    fclose(fp);
    printf("x = %lf, y = %lf, z = %lf\n", point.x, point.y, point.z);
    return 0;
}
~~~~

When the input is invalid, you get an error:

~~~~bash
$ ./read_error.exe input_nok.txt
read_error.exe: invalid input on line 2 of input_nok.txt
~~~~

Note that keeping track of the line number in the input file and reporting it in case of an error will again help the user of this application to identify the problem.


## Overly defensive programming

Grace Hopper is credited with the quote
> It's easier to ask forgiveness than it is to get permission.

Before even attempting to open a file with a given name, you could check whether

  * something with that name exists,
  * it is actually a file,
  * you have permission to open it.

Doing those checks is like asking permission in an administrative matter.  It is a lengthy process, it is tedious and boring.  The alternative is to simply attempt to open the file, and if that fails, simply tell the user why.

Thanks to functions such as `err` and `warn` that will pick up the message associated with the most recent error, chances are that your application will write error messages that are as informative as the ones you'd handcraft by checking for all conceivable error conditions manually.  Your code will be more concise, simpler, and hence the probability of having bugs in your error handling code is reduced.


## Error context

At which level do you report an error?  This is a non-trivial question.

Suppose you are developing an application that reads some parameters from a configuration file, it creates data structures, initialises them, and starts to compute. One of the configuration parameters is the size of the vectors your computation uses, and those are dynamically allocated.

Now you already know that your should check the result of `malloc` to ensure that the allocation succeeded.  Failing to do so will most likely result in a segmentation fault.

However, the user of your application (potentially you) enters a vector size in the configuration file that is too large to be allocated.  No problem though, your application handles error conditions and reports to the user.

You could report the error and terminate execution in the function where it actually occurs, the `create_vector` function you defined in one of the previous sections.  This would inform the user that some data structure can not be allocated.  However, unless she is familiar with the nuts and bolts of the application, that may in fact be completely uninformative.  The function `create_vector` has no clue about the context in which it is called, and can hardly be expected to produce a more meaningful error message.

It would be more useful to the user if this error were reported to the calling function, which has more contextual information, and that this function would report an error that has better semantics.  At the end of the day, the relevant information is that you should reduce the value of a parameter in your configuration file.

Handling errors in the appropriate context is not that easy.  It requires careful planning and formulating error messages from the perspective of the user at each layer in your application.  In a language such as C, this means that functions should return status information.  In the C API for the MPI library for instance, almost all functions return an `int` exit value that can be used to check whether the function call was executed successfully.

In programming languages such as C++ and Python, error handling is simpler since you can use exceptions to propagate status information when a problem occurs and handle it using `try ... catch ...` statements in C++ or `try: ... except ...: ...` in Python.

Regardless of the programming language you use, proper error handling will be fairly complex.


## Floating point expectations

There is a number of problems that may arise during numerical computations and that go unnoticed or are only noticed late, i.e., when a lot of expensive computations have been performed.

The IEEE standard 754 defines five exceptions that can occur as a result of floating point operations:

  1. inexact: accuracy is lost;
  1. divide by zero;
  1. underflow: a value can not be represented and is round to zero;
  1. overflow: a value is too large to be represented; and
  1. invalid: operations is invalid for the given operands.

A divide by zero and an overflow will result in positive or negative infinity, depending on the sign of the operand, while an invalid operation will result in positive or negative NaN (Not a Number).  These values will propagate throughout your computations rendering them useless.

Note that an underflow will easily go unnoticed, which makes it even more dangerous.

The ISO C99 standard defines a number of constants and functions to detect IEEE floating point exceptions, primarily:

  * `fetestexcept` to test whether an floating point exception occurred, and
  * `feclearexcept` to reset the exception bits.

You can test for the five exceptions using the following predefined constants:

  * `FE_INEXACT`,
  * `FE_DIVBYZERO`,
  * `FE_UNDERFLOW`,
  * `FE_OVERFLOW`,
  * `FE_INVALID`, or
  * for all using `FE_ALL_EXCEPT`.

Below is a code sample that shows how to detect invalid and/or overflow in a computation.  The relevant declarations are in the header file `fenv.h`.

~~~~c
#include <err.h>
#include <fenv.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

double sum(int n);

int main(int argc, char *argv[]) {
    int status;
    int n = 10;
    if (argc == 2)
        n = atoi(argv[1]);
    double result = sum(n);
    if ((status = fetestexcept(FE_INVALID | FE_OVERFLOW))) {
        if (status & FE_INVALID)
            warnx("invalid operation detected");
        else if (status & FE_OVERFLOW)
            warnx("overflow detected");
    }
    printf("sum = %le\n", result);
    return 0;
}
~~~~

This application would trap any IEEE floating point overflow or invalid exceptions that are raised in the function `sum`.

Alternatively, functions in `math.h` can be used to check whether a value is normal, e.g.,

~~~~c
#include <err.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

double sum(int n);

int main(int argc, char *argv[]) {
    int status;
    int n = 10;
    if (argc == 2)
        n = atoi(argv[1]);
    double result = sum(n);
    if (!isnormal(result))
        warnx("non-normal result detected");
    printf("sum = %le\n", result);
    return 0;
}
~~~~

The `math.h` header defines a number of other functions that may be useful in this context, e.g.,

  * `isinf`,
  * `isfinite`,
  * `isnan`.
