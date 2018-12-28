# Structural bugs

These issues are likely the ones that first come to mind when you think of bugs.

This is a very broad category that can be divided into a number of subcategories.  

  * Control flow
  * Logic
  * Processing
  * Initialisation

In the sections below, each type will be discussed, and examples will be given.


## Control flow

### Loop termination

A prime example of a control flow bug is improper termination of loops.  Programmers who switch between 1-based languages (e.g., Fortran, MATLAB, R, ...) and 0-based languages (C, C++, Python) or those just starting to use the latter are prone to this.

Consider the following C code fragment:

~~~~c
const int n = 5;
double data[n];
for (int i = 0; i <= n; i++)
    data[i] = some_function(i);
~~~~

Although the loop index `i` starts at 0, which is correct, during the last iteration `i` will be equal to `n`, so `data[n]` will try to access the array out of bounds, since it's last element is at index `n - 1`, rather than `n`.

This situation is somewhat less likely to happen in Fortran code.

Out of bound array access can be detected using compiler flags and Valgrind.

The following example involves a `while` iteration, and is also quite common.  The application reads (a simplified form of) a FASTA file.  For each sequence, it counts and prints the sequence ID, followed by the number of A, C, G, and T nucleotides.

~~~~c
#include <err.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_ID_LEN 80

typedef struct {
    int a, c, g, t;
} NucleotideCounts;

void reset_counts(NucleotideCounts *counts);
void update_counts(NucleotideCounts *counts, char *sequence);
void print_counts(NucleotideCounts counts);

int  main(int argc, char *argv[]) {
    if (argc != 2)
        errx(1, "no file name given");
    FILE *fp;
    if (!(fp = fopen(argv[1], "r")))
        err(2, "can't open file '%s'", argv[1]);
    char *line_ptr = NULL;
    size_t nr_chars = 0;
    char current_id[MAX_ID_LEN] = "", next_id[MAX_ID_LEN] = "";
    NucleotideCounts counts;
    while (getline(&line_ptr, &nr_chars, fp) != -1) {
        int nr_assigned = sscanf(line_ptr, "> %s", next_id);
        if (nr_assigned == 1) {
            if (strlen(current_id) > 0) {
                printf("%s: ", current_id);
                print_counts(counts);
            }
            strncpy(current_id, next_id, MAX_ID_LEN);
            reset_counts(&counts);
        } else if (nr_chars > 0) {
            update_counts(&counts, line_ptr);
        }
    }
    free(line_ptr);
    fclose(fp);
    return 0;
}

void reset_counts(NucleotideCounts *counts) {
    counts->a = counts->c = counts->g = counts->t = 0;
}

void update_counts(NucleotideCounts *counts, char *sequence) {
    for (char *nucl = sequence; *nucl != '\0'; nucl++)
        switch (*nucl) {
            case 'A':
                counts->a++;
                break;
            case 'C':
                counts->c++;
                break;
            case 'G':
                counts->g++;
                break;
            case 'T':
                counts->t++;
                break;
            case '\n':
                break;
            case '\r':
                break;
            default:
                warnx("invalid nucleotide symbol '%c'", *nucl);
        }
}

void print_counts(NucleotideCounts counts) {
    printf("A: %d, C = %d, G = %d, T = %d\n",
           counts.a, counts.c, counts.g, counts.t);
}
~~~~

However, when you run the application on the following FASTA file, the output is not what you would hope for.

~~~~
> seq01
AACGTACCT
CCAGGT
> seq02
GGACAGGTT
AGGCTAAGC
TC
> seq03
CGGAC
~~~~

You will see the result for the first two sequences, but not for the last.

~~~~bash
$ ./count_nucleotides_c.exe seq.fasta
seq01: A: 4, C = 5, G = 3, T = 3
seq02: A: 5, C = 4, G = 7, T = 4
~~~~

The output is correct but incomplete.  By now, you will easily find the problem and fix it using a debugger.

Unfortunately, there are no tools that can help you detect such problems, except for a set of comprehensive unit and functional tests.


### Missing code paths

Consider the following Fortran function that computes the factorial of a given number.

~~~~fortran
integer function factorial(n)
    implicit none
    integer, intent(in) :: n
    integer :: i
    factorial = 1
    do i = 2, n
        factorial = factorial(i)
    end do
end function factorial
~~~~

This function has two code paths, although they are implicit since there is no `if` statement.
  1. If `n < 2`, the `do` loop is not executed, only the result is set to 1.
  1. If `n >= 2`, the result is initialised to 1, and modified in each iteration of the `do` loop.

The function will return a result for each value of its argument (ignoring integer overflow issues for now).  However, if the function is called with a negative argument, the return value is 1, which is of course incorrect.

A code path to cover this case is not implemented, and hence the factorial function does have a bug.

A comprehensive battery of tests may be able to pick up on such issues.


## Logic problems

### Negation and double negation

Although all programmers are very familiar with propositional logic, surprisingly many bugs are caused by mistakes, especially when negation is involved.  Consequences of the following rules are often messed up:

  * `not(a and b) == not(a) or not(b)` (De Morgan)
  * `not(a or b) == not(a) and not(b)` (De Morgan)
  * `(a and b) or c == (a or c) and (b or c)` (distribution)
  * `(a or b) and c == (a and c) or (b and c)` (distribution)

In these simple forms hardly anyone will make a mistake, but matters get more interesting when double negation is involved, e.g., `not(a and not(b)) == not(a) or b`.

In general, humans have a somewhat harder time dealing with double negation.  Even if your code contains double negation, and the implementation is in fact correct, it will be harder to understand when someone reads your code.  Modifications may lead to bugs.

Idiomatic C is quite prone to this, since you'll often see code like the example below.  Experienced C programmers have no problem interpreting this code, but the casual ones may stumble.

~~~~c
const int n = 10;
double *data;
if (!(data = (double *) malloc(n*sizeof(double)))) {
    /* Oops, NULL pointer returned!  Handle this! */
}
~~~~

The assignment in C is an expression, not a statement, so it may appear anywhere the syntax allows any expression.  The value of the expression is the value that was assigned, so in this case the address returned by the `malloc` function.  This address can be `NULL` if `malloc` failed to allocate memory as requested, otherwise it will be a valid memory address.  The semantics is that `NULL` is false, all other addresses are true.  So if `malloc` returns `NULL`, the Boolean expression in the `if` statement evaluates to true, so that the problem can be handled.

A less idiomatic formulation of this code might actually be beneficial, depending on the experience level of those involved in the project.

~~~~c
const int n = 10;
double *data= (double *) malloc(n*sizeof(double));
if (data == NULL) {
    /* Oops, NULL pointer returned! Handle this! */
}
~~~~


### Not so exclusive cases

Consider the following Fortran subroutine that classifies numbers into categories low, medium, and high.

~~~~fortran
subroutine print_classification(x)
    implicit none
    real, intent(in) :: x
    real, parameter :: low = -5.0, high = 5.0
    if (x < low) then
        print '(A)', 'low'
    else if (low < x .and. x < high) then
        print '(A)', 'medium'
    else
        print '(A)', 'high'
    end if
end subroutine print_classification
~~~~

The intent is that when the argument is

  * less than -5.0, `low` should be printed,
  * between -5.0 and 5.0, `medium` should be printed, and
  * larger than 5.0, `high` should be printed.

This is almost always what happens, except when the argument is -5.0.

  1. `x < low` is false,
  1. `low < x .and. x < high` is also false, so
  1. print `high`.

Note that the description of what the subroutine is supposed to do is ambiguous, which illustrates a problem caused by the formulation of the requirements.

Again, only proper testing will help detect such issues.


### Semantics of logic evaluation

The semantics of logic evaluation differs among programming languages.  C, C++, and Python implement lazy evaluation. For Fortran the situation is more complicated since the standard doesn't specify whether logic evaluation is lazy or not.

The following example was already discussed previously.  Consider a C fragment that processes a string, but only if it is non-empty.

~~~~c
char *text;
...
if (strlen(text) && text != NULL)
    process(&text);
~~~~

Although we test for both conditions, this code will yield a segmentation fault if `text` is a null pointer.  In C, Boolean expressions are evaluated from left to right.  Also, evaluation is lazy, so for a logical and, if the left operand evaluates to false, there is no point in evaluating the right operand, since the expression as a whole will evaluate to false, regardless of the right operand's value.

~~~~c
char *text;
...
if (text != NULL && strlen(text))
    process(&text);
~~~~

To summarise the behaviour for lazy evaluation of Boolean expressions:
  * `<expr_1> && <expr_2>`: `<expr_1>` is always evaluated, `<expr_2>` only when `<expr_1>` evaluates to true;
  * `<expr_1> || <expr_2>`: `<expr_1>` is always evaluated, `<expr_2>` only when `<expr_1>`  false.

For some programming languages, e.g., Bash, it is considered idiomatic to use lazy evaluation to control the flow of execution.  Although you can do the same in C or C++, it is not considered idiomatic, and will make your code hard to understand.

~~~~c
char *text;
...
!text && strlen(text) && process(&text);
~~~~

Sometimes, a construct such as the one below is used, again relying on lazy evaluation.

~~~~c
FILE *fp;
(fp = fopen(file_name, "w")) || (fp = stdout);
fprintf(fp, "hello");
fp == stdout || fclose(fp);
~~~~

Please save yourself some problems and don't indulge in this kind of programming.

The last type of potential confusion, and hence a source of bugs, is the distinction between logical and bitwise operators.  Although they may yield the same results in some circumstances, they will not in others.

| logical operator | bitwise operator | semantics |
|------------------|------------------|-----------|
| `||`             | `|`              | or        |
| `&&`             | `&`              | and       |
| `!`              | `~`              | not       |

For example,

  * `2 & 4 == 0` which is false, while `2 && 4 == 1` which is true,
  * `~1 == -2` which is true, while `!1 == 0` which is false.

Bitwise operators are not lazy, both operands will always be evaluated.

Cppcheck will warn you about potential confusion between `&` and `&&`, and `|` and `||`.

For Fortran, the semantics depends on the compiler, since the specification is silent on the matter.  The `gfortran` 8.2 compiler will generate code that does lazy logical evaluation, while for Intel's `ifort` 2018 compiler this is not the case.  Relying on the behavior of a certain compiler is sure to yield non-portable, and hence buggy applications.


## Processing Bugs

Arithmetic bugs are typically classified as processing bugs, but as mentioned in the introduction, they merit their own category.

Another type of important processing bugs are resource leaks.  A prime example would be memory leaks.  Memory is dynamically allocated, but not deallocated.  Over time, the memory footprint of the application increases, and the operating system may run out of memory.  In the best case, the allocation error is handled gracefully, in the worst, you get a segmentation fault.

Memory leaks can be identified using GCC's sanitizer, Cppcheck, Valgrind or Intel Inspector.

Other types of resources may leak as well, and this may have unpleasant consequences.  A handle to a file that is open for writing but is not closed, may lead to data loss and perhaps even corrupt data files.
If file I/O is localised in time, and the granularity of compute and I/O phases is large, it may be prudent to only open the file at the start of the I/O phase and close it at the end.  If the program crashes during a compute phase, your data is safe.  However, keep in mind that opening and closing files has overhead,  so it is not a good idea if a program is continuously doing I/O operations.  An operating system command such as `lsof` can help you identify open files while your program is running.

Network connections are another potential source of resource leaks.  Opening, but not closing many connections may result in a de facto denial of access attack on a database or another resource.  The same considerations as for file I/O apply to network connections.  In many HPC systems, file I/O on a compute nodes is essentially network I/O, since this typically is done on shared file systems.  The operating system command `netstat` may be useful to determine network connections.

In the context of MPI, resources have to be managed as well.  Communicators, derived data types, groups, windows for one-sided communication and so on are created, and must be paired with the corresponding call to free them once they are no longer required.  For example, an `MPI_Win_free` should be paired with an `MPI_Win_create`.  A tool such as Intel Trace Analyser and Collector can help identifying such issues.


## Initialisation bugs

The initialisation of variables, or the lack thereof, is another nice source of problems.

As mentioned previously, explicitly initialising variables is good practice, and compilers as well as static code analysers can help you detect the use of uninitialised variables.

Attempting to use memory that has not been allocated also falls into this category.  The following Fortran code will result in a segmentation fault.

~~~~fortran
program unallocated
    use, intrinsic :: iso_fortran_env, only : error_unit
    implicit none
    integer :: n, i
    real, dimension(:), allocatable :: data
    real :: r
    character(len=80) :: buffer

    if (command_argument_count() < 1) then
        write (fmt='(A)', unit=error_unit) &
            'missing command argument, positive integer expected'
        stop 1
    end if
    call get_command_argument(1, buffer)
    read (buffer, fmt='(I10)') n
    do i = 1, n
        call random_number(r)
        data(i) = r
    end do
    print '(A, F15.5)', sum(data)
end program unallocated
~~~~

The variable `data` has been declared `allocatable`, but the `allocate` statement is missing.

This type of problem can sometimes be detected by the compiler, but certainly by Valgrind.
