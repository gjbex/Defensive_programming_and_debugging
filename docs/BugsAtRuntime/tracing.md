# What is changing?

When you observe programmers that are not familiar with debuggers, you'll often see them insert print statement to monitor how the value of a variable changes over time.

This pollutes the source code, and you'll certainly forget to take out some print statements when you are done debugging. A debugger offers multiple ways to achieve a similar result without the hassle.


## Display values

Often, you want to inspect a value each time the debugger halts at a breakpoint.  This can easily be achieved using the command `display`.  The argument to display is an expression that will be evaluated and displayed each time the application hits a breakpoint.

A trivial example would be to simply show the value of a variable, consider, e.g.,

~~~~fortran
real :: total
integer :: i
...
total = 0.0
do i = 0, max_pow
   total = total + 10.0**i
end do
~~~~

When you set a breakpoint in the do-loop, so at the statement that increments `total`, and run till you hit that breakpoint, you can display the values of `i` and `total`.

    (gdb) display i
    1: i = 0
    (gdb) display total
    2: total = 0

Now when you resume execution and hit a breakpoint, the values of `i` and `total` will be displayed, i.e.,

    (gdb) c
    Continuing.

    Breakpoint 1, display_demo () at display_demo.f90:9
    9	        total = total + 10.0**i
    1: i = 1
    2: total = 1

You can get an overview of all displays in your debug session using `info display`, i.e.,

    (gdb) i display
    Auto-display expressions now in effect:
    Num Enb Expression
    1:   y  i
    2:   y  total

As with breakpoints, displays have a numerical identifier that you can use to enable or disable them, delete them, and so on, e.g.,

    (gdb) d display 1

Although this can be useful, GDB offers more powerful options.


## Commands at breakpoints

This feature actually exceeds tracing, it can be used for other purposes as well.  The `command` command allows to specify action to be taken when a breakpoint is hit.  Here, you will see how to use it to trace the value of variables as your code executes.

First you set a breakpoint, next you add the command to be executed, i.e.,

    (gdb) b 9
    Breakpoint 1 at 0x5555555548a3: file display_demo.f90, line 9.
    (gdb) commands
    Type commands for breakpoint(s) 2, one per line.
    End with a line saying just "end".
    >silent
    >printf "i = %d, total = %f\n", i, total
    >continue
    >end

The `silent` command suppresses the usual output that is displayed when the application hits a breakpoint.  In this case, you use it because you just want to display variable values as the code executes.

The `printf` command is quite similar to the Bash `printf` built-in.  Its first argument is a formatting string, the following arguments are the expressions to display the values for.  Don't forget to add the newline character `\n` to get readable output.  Some format specifiers you can use are

  * `%f`: floating point number;
  * `%d`, `%x`: signed integer in decimal, and hexadecimal, respectively;
  * `%s`, `%c`: string and character, respectively.

The `continue` command ensures that the application will resume execution.

When you execute the application, you would see output similar to the following for our running example,

    (gdb) r
    Starting program: /home/gjb/Documents/Projects/training-material/Debugging/Gdb/Fortran/Tree/display_demo.exe
    i = 0, total = 0.000000
    i = 1, total = 1.000000
    i = 2, total = 11.000000
    i = 3, total = 111.000000
    i = 4, total = 1111.000000
    i = 5, total = 11111.000000
    i = 6, total = 111111.000000
    i = 7, total = 1111111.000000
    i = 8, total = 11111111.000000
    i = 9, total = 111111112.000000
    i = 10, total = 1111111168.000000


## Dynamic print

As mentioned, `command` has more applications than simple tracing, and frankly, it is an overkill for that purpose thanks to GDB's dynamic print command `dprintf`.

As its first argument this command takes a location, at which it should be executed each time that location is reached during the execution.  This is convenient, since no breakpoint has to be set.  The format string is the same as for the `printf` command.

For our running example,

    (gdb) dprintf 9, "i = %d, total = %f\n", i, total
    Dprintf 1 at 0x5555555548a3: file display_demo.f90, line 9.
    (gdb) r
    Starting program: /home/gjb/Documents/Projects/training-material/Debugging/Gdb/Fortran/Tree/display_demo.exe
    i = 0, total = 0.000000
    i = 1, total = 1.000000
    i = 2, total = 11.000000
    i = 3, total = 111.000000
    i = 4, total = 1111.000000
    i = 5, total = 11111.000000
    i = 6, total = 111111.000000
    i = 7, total = 1111111.000000
    i = 8, total = 11111111.000000
    i = 9, total = 111111112.000000
    i = 10, total = 1111111168.000000

As you can see, the same output is generated as the one you got by using `command`, with a lot less effort.


## Watching for change

Although tracing can be useful, it can be fairly cumbersome when not much changes over time.  It would be more useful to only display values that change.  Consider the following straightforward code sample.

~~~~fortran
integer :: i, j
integer, dimension(rows, cols) :: values
character(len=32) :: fmt_str
...
do j = 1, cols
    do i  = 1, rows
        values(i, j) = (i - 1)*cols + j
    end do
end do
~~~~

You want to monitor changes on the outer do-loop variable `j`.  When that variable changes, you want to see the value of `i`, as well as the new and old value of `j`.

This can easily be achieved by combining a number of concepts you already know.  We define a GDB variable `$current_j` to keep track of the current value of the Fortran variable `j`.  We set a conditional breakpoint in the inner do-loop, so that execution will only halt when `j` is not equal to `$current_j`, and we attach commands to that breakpoint.

    (gdb) set $current_j = 0
    (gdb) b 10 if j .ne. $current_j
    Breakpoint 1 at 0x8ef: file watch.f90, line 10.
    (gdb) commands
    Type commands for breakpoint(s) 1, one per line.
    End with a line saying just "end".
    >silent
    >printf "i = %d, j = %d, old j = %d\n", i, j, $current_j
    >set $current_j = j
    >continue
    >end
    (gdb) r
    i = 1, j = 1, old j = 0
    i = 1, j = 2, old j = 1
    i = 1, j = 3, old j = 2
    i = 1, j = 4, old j = 3


## Hardware watch points

As you saw in the video, hardware watch points can be very useful to pinpoint suspicious memory access patterns.  Typically, there are situations when the value of a variable or a data structure is modified, but you don't know where in the code that might happen.

Consider the following situation.  The application computes the evolution of the temperature of a rectangular flat surface represented as a 2D array.  The boundaries of the surface have a constant temperature throughout the computation.  The 2D matrix is initialised such that its first and last row, and its first and last column are set to the boundary temperature (`init_temp`).  In each time step, the temperature at each interior point of the 2D array is updated by taking into account the temperatures of its neighbours (`update_temp`).  In addition, with a given probability, an interior point of the 2D array is set to a random value (`perturb_temp`).

~~~~fortran
real, dimension(x_max, y_max) :: temp
real :: boundary, prob
integer :: t
...
call init_temp(temp, boundary)
call show_temp(temp)
do t = 1, t_max
    call update_temp(temp)
    call perturb_temp(temp, prob)
end do
call show_temp(temp)
~~~~

When you run the application, you notice that some values on the boundary have changed, and that shouldn't happen according to the design of the program.  There must be a bug.

This is a toy example, but you can easily imagine a similar, but vastly more complicated setting. You could set breakpoints in the do-loop, but to identify the culprit you have to check for change after each procedure call, which is tedious and error prone.

It is much easier and faster to just set a watch point on a boundary, so that the application will halt as soon as that it is modified.  So first set a breakpoint after the initialisation of `temp` is done, run the application, set a watch point, and continue.

    (gdb) b 9
    (gdb) r
    (gdb) watch temp(1, 1)@x_max
    Hardware watchpoint 2: temp(1, 1)@x_max
    (gdb) c
    Continuing.

    Hardware watchpoint 2: temp(1, 1)@x_max

    Old value = (0, 0, 0, 0)
    New value = (0, 0, 0.101466358, 0)
    perturb_temp (temp=..., prob=0.699999988) at watch_point.f90:62
    62	          end if

Presto!  The boundary is inadvertently modified by the procedure `perturb_temp`.  Now you can concentrate on that procedure to pinpoint the exact problem in the algorithm.

Contrary to appearances, he `watch` command doesn't actually monitor the value of variables, but rather the value stored in the memory the variable refers to.  This explains why it is called a "hardware watch point".  Watch points come in a few flavours:

  * `watch`: break when the value is modified;
  * `rwatch`: break when the value is read;
  * `awatch`: break when the values is read or modified.

As you would expect, `info watchpoints` will list the watch points in your current debug session.  Watch points will also be shown when you use `info breakpoints`, and you can manage them in the exact same way, e.g., disabling/enabling, deleting, and so on.
