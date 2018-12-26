# How to verify correctness?

Although compilers and static code checkers can detect quite a number of issues in code, some checks can only be done at runtime.  Several tools are available, but for multi-threaded applications and distributed applications using MPI.


## OpenMP

Valgrind was already mentioned before to detect memory leaks and erroneous memory accesses. However, it can also to used to verify that no deadlocks and data races occur in a multi-threaded application.  Unfortunately, the DRD component of valgrind can only handle C and C++ code, and POSIX threads (the `pthreads` library) out of the box.  Support for OpenMP using `gcc` and `g++` is possible, but requires your own build of GCC.  Hence Valgrind will not be discussed futher here.

Intel Inspector can detect many problems for multi-threaded code, both for POSIX threads, and OpenMP.  It can handle C/C++ as well as Fortran code.  Unfortunately, it is a commercial product, and requires a valid license.

As usual, the code should be compiled with the `-g` flag in order to ensure that Intel Inspector can show the source code properly.  You don't need to do anything in addition to this to use Intel Inspector.

It is important to note that Intel Inspector generates a lot of overhead, both to the run time of the applications, and to the amount of memory being used.  You may want to start using Intel Inspector as soon as possible in the development cycle.

Intel Inspector has a GUI that that helps you to easily configure the verifications that should be done, and how thorough the checks should be.  The applications is started under control of Intel Inspector, and when it finishes, a report is generated and displayed.

Intel Inspector can detect data races and deadlocks.


## MPI

Just as OpenMP, MPI offers a lot of opportunities to make mistakes.  When using Intel MPI as a communications library, it is possible to do runtime verification using Intel Trace Analyzer and Collector (ITAC).  Besides detecting deadlocks, the `VTmc` library can also be linked in to check for various issues such as

  * Buffer size or type mismatch in communication calls.
  * Outstanding requests when the application terminates.
  * Deadlock detection.
  * Messages being sent, but never received.
  * Resource leaks on data types, communicators.

Using a configuration file, tests can be switched on or off.  The configuration file to be used at runtime can be defined using the environment variable `VT_CONFIG`.

If you want to use MPI checking, you have to

  1. link your application with `libVTmc.so` which is supplied by ITAC;
  1. optionally create a configuration file and assign its path to `VT_CONFIG`;
  1. use the Intel MPI library as communications library;
  1. run the application using `mpirun` as usual, but with the extra option `-check-mpi`.

Before the application starts, all checks will be listed.  When a check fails at runtime, the application is halted with an appropriate error message.

Below you see example output for an application that runs with several processes, all executing an `MPI_Reduce`.  However, not all processes use the same length for the send buffer.  This violates the MPI specification, may cause indeterminate behaviour, and is most likely not wat you have in mind anyway.

    [0] ERROR: GLOBAL:COLLECTIVE:SIZE_MISMATCH: error
    [0] ERROR:    Mismatch found in local rank [1] (global rank [1]),
    [0] ERROR:    other processes may also be affected.
    [0] ERROR:    No problem found in the 3 processes with local ranks [0:2:2, 3] (same as global ranks):
    [0] ERROR:       MPI_Reduce(*sendbuf=..., *recvbuf=..., count=5, datatype=MPI_DOUBLE, op=MPI_SUM, root=0, comm=MPI_COMM_WORLD)
    [0] ERROR:       main (/home/gjb/Documents/Projects/training-material/Debugging/Mpi/Itac/Verfification/buffer_size.c:21)
    [0] ERROR:       __libc_start_main (/lib/x86_64-linux-gnu/libc-2.27.so)
    [0] ERROR:       _start (/home/gjb/Documents/Projects/training-material/Debugging/Mpi/Itac/Verfification/buffer_size.exe)
    [0] ERROR:    Root expects 5 items but 8 sent by local rank [1] (same as global rank):
    [0] ERROR:       MPI_Reduce(*sendbuf=0xf136d0, *recvbuf=NULL, count=8, datatype=MPI_DOUBLE, op=MPI_SUM, root=0, comm=MPI_COMM_WORLD)
    [0] ERROR:       main (/home/gjb/Documents/Projects/training-material/Debugging/Mpi/Itac/Verfification/buffer_size.c:21)
    [0] ERROR:       __libc_start_main (/lib/x86_64-linux-gnu/libc-2.27.so)
    [0] ERROR:       _start (/home/gjb/Documents/Projects/training-material/Debugging/Mpi/Itac/Verfification/buffer_size.exe)
    [0] INFO: 1 error, limit CHECK-MAX-ERRORS reached => aborting
    [0] WARNING: starting premature shutdown

As you can see, the error message clearly states the issue, as well as the location in the code where the problem occurs.


### Alternative

MUST is an open source correctness checker for MPI application developed by the Technical University of Aachen, Germany.  If you manage to get the latest release candidate properly, it should offer some nice functionality at an attractive price.
