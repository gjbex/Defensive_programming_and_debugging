# How can you debug OpenMP code using GDB?

Debugging OpenMP applications with GDB is fairly straightforward. To include debugging information in the application, use `-g` as usual when compiling and building the application.

When starting the debugger, you may want to control the number of OpenMP threads.

~~~~bash
$ OMP_NUM_THREADS=2  gdb  ./application.exe
~~~~

All GDB commands you are familiar with will work when debugging an OpenMP application.  However, there are a few relevant ones specifically for multithreaded applications.

*Note*: none of the commands discussed below are specific to OpenMP as such, they will also work when you use threading libraries such as `pthreads`.


## Listing threads

When the program is halted in a parallel region, it will display the thread ID that hit the breakpoint.  You can get information on the running threads using

    (gdb) info threads

The thread GDB halted in is marked with an asterisk.  Notice that the thread ID listed by GDB is not the OpenMP thread number.  So typically, GDB thread 1 will have OpenMP thread number 0, and so on.  This may be somewhat confusing.


## Switching threads

The variables that will be printed are those local to the thread, so all shared and thread-private variables.  You can switch the context to another thread using the `thread` command, and the GDB thread ID to switch to, e.g.,

    (gdb) thread 2

Note that it is very likely that this thread will be at another point in the source code. You can make it continue to the breakpoint using the `continue` command.  However, all threads will be resumed, so the first thread that hit the breakpoint will continue past it.  This may or may not be what you want.


## Scheduler locking

Although it is quite useful to debug race conditions and deadlock situations that GDB halts all threads when the first reaches a breakpoint, sometimes you just like all threads to continue to the same breakpoint in order to conveniently check the value of variables across threads.

This can be achieved by turning on scheduler locking, i.e.,

    (gdb) set scheduler-locking on

Now the `continue`, `next`, `step` commands will only advance the current thread.

*Note*:  this can lead to a deadlock.

To turn scheduler locking off again, simply use

    (gdb) set scheduler-locking off

To check the status of scheduler locking, use the `show` command, i.e.,

    (gdb) show scheduler-locking


## Sending GDB command to multiple threads

You can easily execute GDB command on multiple threads at once.  For instance, suppose you would like all threads to halt on a breakpoint, and compare that values of variables across threads.

Suppose that thread number 1 has halted on the breakpoint, first turn on scheduler locking, and then let all threads but the first continue to the breakpoint. The total number of threads is 4.

    (gdb) set scheduler-locking on
    (gdb) thread apply 2-4 continue

You can verify with `info thread` that all threads have halted at the breakpoint.  Now we can print the value of a variable, say `tid`, across threads.

    (gdb) thread apply all print tid

The keyword `all` can be used as a shortcut for the list of all thread IDs. The thread list to apply the command to can be

  * one or more thread IDs, separated by spaces, and/or
  * one or more ranges, e.g., `2-4`; or
  * `all`.
