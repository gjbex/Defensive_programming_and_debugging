# How do I get a handle on a running program?

In some circumstance, you need information on what a running program is doing.  You can't or don't want to stop and relaunch it under control of a debugger.  No problem, GDB can actually attach to a running application.

However, most modern Linux operating systems have hardened kernels, and by default, process tracing is not permitted.  The error message you would get when trying it would be similar to

    ptrace: Operation not permitted

You will need root access to change the default behaviour, either temporarily or permanently.  The latter may be convenient, but perhaps not such a good idea from a security point of view.  Kernel hardening has been done for a reason.  A third alternative is to run the debugger as root, but I would strongly advise against that.


## Enabling process tracing

### Temporarily enabling process tracing for non-root users

*As root* on an Ubuntu system, execute the following command

~~~~bash
# echo 0 > /proc/sys/kernel/yama/ptrace_scope
~~~~

Process tracing will be allowed until the next reboot, or until you revert it manually by executing, again *as root*

~~~~bash
# echo 1 > /proc/sys/kernel/yama/ptrace_scope
~~~~


### Permanently enabling process tracing for non-root users

On Ubuntu, edit the file `/etc/sysctl.d/10-ptrace.conf`.  Its last line reads

~~~~bash
kernel.yama.ptrace_scope = 1
~~~~

This line should be changed to

~~~~bash
kernel.yama.ptrace_scope = 0
~~~~

Again, this may not be wise.


## Attach GDB to a running application

To attach the GDB debugger to a running application, you first need the application's process ID.  You can use the `top` command for that purpose.  The process ID for each process is displayed in the first column (PID).  Alternatively, you can use `pgrep`.  For instance, suppose the application you want to attach to is `infinite_loop.exe` (perhaps aptly named), you would get the process ID using

~~~~bash
$ pgrep infinite_loop
13661
~~~~

The process ID will of course be different on your system, and vary from run to run.

You can attach GDB as follows:

~~~~bash
$ gdb ./infinite_loop.exe 13661
~~~~

This will immediately halt the application, showing the statement that will be executed next.  You can now use GDB to explore the state of your application, printing variables, stepping, and so on.  When you quit the debugger, your application will continue to run.

If you decide while debugging that there is no point for it to run, you can stop the application from within GDB by using the `kill` command.  You will be prompted for confirmation.


## Tracing system calls

The Linux command `strace` can be used to quickly get an idea of what is going on if your application seems to be stuck.  It will print a trace of the system calls done by the process, e.g., read/write operations or exec calls.

Although this gives of course much less information than attaching a debugger, it can be useful nevertheless.  For instance, you can detect at a glance that the application is stuck in a read operation, so it might be waiting for a reply from a network operation.

Using `strace` is straightforward, simply determine the process ID of the application you want to trace, and run `strace`, e.g.,

~~~~bash
$ strace -p 13661
~~~~


## What files does my application use?

Sometimes an application uses temporary files without you being aware of it, which may lead to interesting problems.  To determine which files are used by a running process, determine its process ID and run `lsof` (list open files).

~~~~bash
$ lsof  -p 13661
~~~~

For a dynamically linked application, this will also show the currently loaded shared object files.


## What resources does my application use?

To check the amount of memory an application currently has allocated, or the user time versus the system time, `prtstat` can be quite useful.  Again, determine the process ID of the running application, and use

~~~~bash
$ prtstat 13661
~~~~
