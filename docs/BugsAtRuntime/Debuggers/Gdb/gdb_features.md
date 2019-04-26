# What can you do with GDB?

The screencasts have shown you a number of features of GDB, but there is a lot more you can do.  Here you'll get a recap of what was shown, as well as an overview of a few additional features.


## How to prepare for debugging?

Make sure your application can be debugged conveniently.  This implies compiling with
  * `-g` to add references to the source code in the executable, and
  * `-O0` to switch off optimisation.

Note that `-g` has no influence on the performance of your application, it just adds a little bit to its size.  In most circumstances, you don't care about it.

Remember to build with optimisation enabled once you're done debugging.


## How do you start the debugger?

Start GDB on the command line to debug the executable `application.exe` using

~~~~bash
$ gdb ./application.exe
~~~~

If your application takes command line arguments, those can be conveniently passed by using GDB's `--args` option.  You normally run your application using

~~~~bash
$ ./application.exe  --verbose  --n 5
~~~~

To debug it with the same command line arguments, simply invoke the debugger as follows

~~~~bash
$ gdb  --args  ./application.exe  --verbose  --n 5
~~~~


## How to get help?

GDB has a help system that is quite useful.  The `help` command will list the available topics.  You can also request help on specific command, e.g., `help print`.  If you don't really know which topic covers the concept you are looking for, you can use the `apropos` command, e.g., `apropos variable`.


## How to quit the debugger?

The `quit` or `q` command will quit the debugger, but you'll be asked for confirmation.


## How to view your source code?

Although you would typically have an editor open that displays the source code of the application you are debugging, it can nevertheless be convenient to list it in the debugger itself, just to have a quick peek.   The `list` or `l` command will do that for you.  It can be used in a number of ways, e.g.,

  * `l`: list the code at the current location;
  * `l <ln>`: list the code in the current file around line `<ln>`;
  * `l <file>`: list the code in file `<file>`;
  * `l <file>:<ln>`: list the code in the file `<file>` around line `<ln>`;
  * `l <func>`: list the source code of the function named `<func>`.

If you don't feel comfortable with this way of working, you can enable TUI mode.  This will split your screen into two parts.  The upper part shows your source code, the lower is the GDB command line.  When GDB is running, you can switch to TUI mode as follows:

    (gdb) tui enable

You can switch back to non-TUI using

    (gdb) tui disable

You should experiment with it to see what is most comfortable for you.  If you decide you like TUI, you can start GDB in TUI mode by invoking `gdbtui`, rather than `gdb`, on the command line of your shell.


## Breakpoints

Setting a breakpoint can be done with the `break` or `b` command, followed by

  * a line number, e.g., `b 15`
  * a function name, e.g., `b fib`
  * a file name and a line number, e.g., `b fib.c:17`
  * or a file name and a function name, e.g., `b fib.c:fib`

A breakpoint can be conditional, and that condition is formulated in the programming language of the application being debugged.  E.g., the following GDB command would halt the application when it enters the function `fib` when called with an argument `n` that is less than 2.

    (gdb) b fib if n < 2

The syntax of the condition is that of the programming language being debugged, so for C/C++ versus Fortran, respectively

  * `==` versus `.eq.`
  * `!=` versus `.ne.`
  * `<` versus `.lt.`
  * `&&` versus `.and.`
  * ...

Note that the "new style" Fortran comparison operators `==`, `<`, ..., and `/=` will not work, which is, frankly, a bit of a pain.

GDB offers quite some options to manage breakpoints.  Breakpoints have a numerical identifier so that specific actions can be performed on them.  In the following `<n>` denotes a breakpoint number.  Current breakpoints can be

  * listed using `info breakpoints`, or `i b`
  * temporarily disabled/enabled using `disable b <n>` and `enable b <n>`
  * delete a breakpoint using `delete <n>` or `d <n>`
  * delete all current breakpoints using `delete` or `d`

If you want to make an existing breakpoint conditional, that is as simple as attaching a condition to it using the `cond` command, e.g.,

    (gdb) b 17
    Breakpoint 3 at 0x156f: file watch_point.f90, line 19.
    ...
    cond b i == 10

Now the breakpoint with identifier 3 will be conditional, i.e., the application will only halt when the variable `i` is equal to 10.  So there is no need to create a new breakpoint.


## How to execute and to step through code?

To run the application, use the `run` command, followed by the required command line arguments, if any, e.g.,

    (gdb) r 15

The command above will start the application with `15` as the first and only command line argument.

The application will run until

  * it reaches the first enabled breakpoint, or
  * until it terminates abnormally, or
  * until it terminates normally.

Once the application hits a breakpoint, you can continue the execution in several ways:

  * use `continue` or `c` to resume execution until the next breakpoint is hit (which might be the same if the code iterates),
  * use `next` or `n` to execute the statement the execution halted at, stepping over function calls, or
  * use `step` or `s` to step into a function that is in the current statement.

The `continue` command can optionally be followed by a number, e.g., for the following code fragment the breakpoint is in the for-loop:

~~~~c
for (int i = 0; i < 10; i++)
    printf("%d\n", i);
~~~~

When the execution is halted the first time, the do-loop will be in its first iteration, so `i == 1`.  Using `c 5` at this point will resume the application and halt it the fifth time the breakpoint is hit. So when the application is halted, `i == 6` (the breakpoint was skipped 4 times).

The `until <ln>` command can be very useful.  It will run the application until the specified line number `<ln>` is reached, without having to set a breakpoint.  However, it works only in the current frame.  More generally, `advance <loc>` will continue to execute the application up to the specified location `<loc>` that takes the same format as that for the `break` command.

While evaluating a function, it is often convenient to halt at the end of the function, just before it goes out of scope.  This is easily done using the `finish` command.


## What can you do at a breakpoint?

Checking the value of variables is one of the main operations once your application hits a breakpoint.  This way, you can verify that your expectations are met.

By the way, during lengthy debug sessions, you may want a reminder of the point  in the code you are currently at.  For this purpose, the `frame` command is quite useful.  It will display the current frame and the line of code the application will execute next, e.g.,

    (gdb)
    #0  main () at features.c:11
    11	    if (vectors == NULL)

We will discuss frames in more detail in a later section.


### Inspecting values

The value of a variable can be displayed using the `print` or `p` command, e.g.,

    (gdb) p a

GDB will attempt to provide a view that is as useful as possible if it can determine the semantics of the variable.  For an array, it will print the elements.  For a C structure, member names and their respective values will be displayed.  Since pointers have no semantics for the compiler, the usual dereferencing is required to display relevant information besides the raw address.

For example, consider the following data structure that represents a vector with `n` double precision floating point elements.  The `element` member is a pointer, do before you can store values as elements, dynamic memory allocation has to be done.

~~~~c
typedef struct {
    double *element;
    int n;
} Vector;
~~~~

Now consider the following variable:

~~~~c
Vector *vectors[5];
~~~~

Note the difference between `vectors` and `vectors[0]->element`-- the former is an array, the second is a pointer.

After it has been properly initialised, you could print several things at a breakpoint:

  1. `p vectors`: array of 5 addresses, each for a `Vector`;
  1. `p &vectors`: address of the first `Vector` in the array;
  1. `p vectors[0]`: address of the first `Vector`;
  1. `p *vectors[0]`: struct representation with the value of the `n` field, and the address assigned to the `element` field for the first `Vector`;
  1. `p vectors[0]->n`: value of the `n` member of the first `Vector`;
  1. `p &vectors[0]->n`: address of the member `n` of the first `Vector`;
  1. `p vectors[0]->element`: address of the first element of the first `Vector`;
  1. `p *(vectors[0]->element)`: value of the first element of the first `Vector`;
  1. `p vectors[0]->element[0]`: value of the first element of the first `Vector`;
  1. `p vectors[1]@3`: the addresses of the second up to and including the fourth `Vector`;
  1. `p vectors[0]->element[0]@vectors[0]->n`: all element values of the first `Vector`.

The last example is fairly involved, so step by step:
  1. `vectors[0]->n` is the number of elements of the first `Vector` in the array, call that `k` for convenience,
  1. `vectors[0]->element[0]@k` is a slice that starts at index 0 and has length `k`.

Since this expression is somewhat unwieldy, you could use a _GDB variable_ to store the length of the `Vector`, i.e.,

    (gdb) set $len = vectors[0]->n
    (gdb) p vectors[0]->element[0]@$len

Note that when you display a result using `print`, the result is in fact stored in a GDB variable, e.g.,

    (gdb) p vectors[0]->n
    $5 = 3
    (gdb) p $5 + 5
    $6 = 8


### Inspecting types

Very often, you are not only interested in the value of variables, but also in the definition of their data type.  Two commands can be quite useful to get that information, `whatis` and `ptype`.  The former provides a more high-level view on the type, while the latter gives you more details.

For instance, for the running example, you might want to explore the data structure, e.g.,

    (gdb) whatis vectors
    type = Vector *[100]
    (gdb) ptype vectors
    type = struct {
        double *element;
        int n;
    } *[100]

Using `whatis`, you would have to dig up the type definition of `Vectors`, which is a `typedef` to the structure that is displayed directly by `ptype`.


### Executing functions and modifying state

It is even possible to evaluate arbitrary function calls in GDB.  Consider the following  declarations:

~~~~c
double vector_length(Vector *v);
void fill_vector(Vector *v, double start_value, double delta_value);
Vector *init_vector(int n);
~~~~

The first function can be evaluated at a breakpoint using `print` which will display the result of the computation.

    (gdb) p vector_length(vectors[0])

The second function does not return a value, so it is better to call it using the `call` command.

    (gdb) call fill_vector(vectors[0], 1.0, 0.2)

It is even possible to create a new `Vector` structure, assign it to a GDB variable, and call additional functions on it.

    (gdb) set $v = init_vector(5)
    (gdb) p vector_length($v)

You can modify the value of variables at runtime while in the debugger using the `set var` command.

    (gdb) set var vectors[0] = init_vector(vector_len)

This can help you experiment while debugging by setting values to what you suspect they should be.  However, thread with care, there be dragons.  It is all too easy to completely mess up the state of your application.


### Exploring data structures

If you know your data structures well and are proficient referencing/dereferencing memory then `print` will serve you well.  However, to explore code that you are not familiar with, the `explore` command may be a great help.  It interactively guides you through the data exploration.

The session below would be typical for the data structure in the running example.

    (gdb) explore vectors
    'vectors' is an array of 'Vector *'.
    Enter the index of the element you want to explore in 'vectors': 0
    'vectors[0]' is a pointer to a value of type 'Vector'
    Continue exploring it as a pointer to a single value [y/n]: y

    The value of '*(vectors[0])' is of type 'Vector' which is a typedef of type 'struct {...}'
    The value of '*(vectors[0])' is a struct/class of type 'struct {...}' with the following fields:

    element = <Enter 0 to explore this field of type 'double *'>
        n = 5 .. (Value of type 'int')

    Enter the field number of choice: 0
    '(*(vectors[0])).element' is a pointer to a value of type 'double'
    Continue exploring it as a pointer to a single value [y/n]: y
    '*((*(vectors[0])).element)' is a scalar value of type 'double'.
    *((*(vectors[0])).element) = 0

    Press enter to return to parent value:

    Returning to parent value...

    The value of '*(vectors[0])' is a struct/class of type 'struct {...}' with the following fields:

    element = <Enter 0 to explore this field of type 'double *'>
        n = 5 .. (Value of type 'int')

    Enter the field number of choice: 0
    '(*(vectors[0])).element' is a pointer to a value of type 'double'
    Continue exploring it as a pointer to a single value [y/n]: n
    Continue exploring it as a pointer to an array [y/n]: y
    Enter the index of the element you want to explore in '(*(vectors[0])).element': 1
    '((*(vectors[0])).element)[1]' is a scalar value of type 'double'.
    ((*(vectors[0])).element)[1] = 0.10000000000000001

    Press enter to return to parent value:

    Returning to parent value...

    Enter the index of the element you want to explore in '(*(vectors[0])).element'---Type <return> to continue, or q <return> to quit---

As you can see, this can be rather useful to gather information on an unknown data structure.  Whether you like this approach is very much a personal preference.  Personally, I prefer going with  `print` and `ptype`, but les gouts et les couleurs ...


## How to deal with function calls?

When a function is called, information is placed on the stack, an area of memory reserved for that purpose.  It contains values of the arguments the function was called with, as well as local variables in that function.

Using the `frame` command, you can check at any time which function you are currently looking at, including the arguments it was called with, and see the line of code that will be executed next.

To list all the local variables and their value in the function you can use the `info locals` command.  This is useful to get a quick overview.  Similarly, `info args` will display the arguments names and values to the function in this frame.

The call stack that stores the frames can be visualised using the `backtrace` or `bt` command, e.g.,

    (gdb) bt
    #0  fill_vector (v=0x555555757280, start_value=0,
        delta_value=0.10000000000000001) at vectors.c:23
    #1  0x0000555555554bc4 in main () at features.c:16

In this case, there are two frames.  The top frame is the function `fill_vector` where the debugger is  currently halted, the bottom frame is the `main` function from where `fill_vector` was called.

Often, you will want to examine the calling context of a function, i.e., a frame that is higher up in the call stack.  You can move to the frame of the `main` function by using the `up` command, i.e.,

    (gdb) up
    #1  0x0000555555554bc4 in main () at features.c:16
    16	        fill_vector(vectors[j], j, 0.1*(j + 1.0));

Now, it is easy to inspect the value of variable in the `main` function.  To move back to the called function you can use `down`.  `up` and `down` allow you to easily traverse the call stack.  However, you can jump to a particular frame immediately by using `frame <fn>` where `<fn>` denotes the frame number as displayed in the output of `backtrace`.

Note that regardless of the frame you are examining, the application is halted in the exact same statement until you decide to step or otherwise resume the execution.

GDB has of course  many more features, which will be explored later.
