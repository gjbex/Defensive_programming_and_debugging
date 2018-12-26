# Parallel programming best practices

Parallel programming is fraught with its own opportunities to introduce bugs.  The specification of both OpenMP and MPI are quite clear, but sometimes fairly complex.  Misinterpretation or lack of awareness may lead to very interesting and long debugging sessions.  PRACE offers excellent courses on the topic which you are strongly encouraged to attend if you didn't do so yet.

Often, bugs are introduced as a side effect of code optimisation.  Semantics are often quite subtle and it is easy to get things wrong.  Therefore it is recommended to start with a non-optimised version of your code, and ensure you have comprehensive tests.  Only then proceed to the optimisation of the code.

This discussion is limited to best practices to avoid bugs in parallel code.  Best practices for performance optimisation is a topic in itself.  PRACE organises excellent trainings and workshops on this topic as well.


## Multithreaded programming

For multithreaded programming, data races are a potential issue.  It is crucial to ensure that updates to variables by multiple threads are done correctly.  OpenMP offers several constructs to support common use cases, e.g., the `reduction` clause and the `critical` directive.

A common source of errors is inadvertently sharing a variable across threads.  To ensure that you have to decide whether a variable should be shared or thread-private, it is good practice to set the default to none (`default(none)` clause).  The compiler will report errors for each variable that is not explicitly declared either shared or private.

However, in C and C++ you can often completely side step this issue by using local variables in the parallel region.  Consider the following code fragment

~~~c
int num_threads, thread_num;
#pragma omp parallel private(num_threads, thread_num)
{
    num_threads = omp_get_num_threads();
    thread_num = omp_get_thread_num();
    ...
}
~~~ 

The version below is simpler, and reduces the scope of the variables to the parallel region.

~~~c
#pragma omp parallel
{
    int num_threads = omp_get_num_threads();
    int thread_num = omp_get_thread_num();
    ...
}
~~~

In Fortran, you might expect to achieve the same using the `block ... end block` construct.  However, the OpenMP standard is silent on the semantics, so results will be implementation depedent.  The Intel Fortran compiler `ifort` will yield an error notifying you that a block construct is not allowed in an OpenMP block. GCC `gfortran` on the other hand will happily compile the code, which, at least in situations I tested, seems to do the intuitively right thing.  Given this ambiguity, you obviously should not use a block construct in an OpenMP block.

Subtle errors may also be introduced by the `nowait` clause that you would typically introduce to get better performance.  A subsequent loop may start iterating on data that is not yet processed by the previous one, leading to data races.  Controlling the loop schedule explicitly may resolve such issues.

Forgetting a `taskwait` directive has similar consequences as an ill-advised `nowait`, it will also lead to race conditions.

When using locks, there is the potential of deadlock.  If possible, it is preferable to avoid locks altogether.

A word of caution: when developing OpenMP applications, ensure that you test it on a system that has at least the number of cores as the number of threads you detect.  Race conditions and/or deadlocks may be hidden by thread scheduling done by the operating system if the number of threads exceeds sthe number of cores.


## MPI

Almost all MPI functions in the C API return error values.  Similarly, most of the Fortran procedures take an error value argument.  It may seem like a good idea to check these values, and take appropriate action. However, in practice that often makes no sense.  For instance, if an `MPI_Bcast` were to fail, the application will crash before the error handling code gets executed.  Quoting from the OpenMPI documentation:

> Almost all MPI routines return an error value; C routines as the value of the function and Fortran routines in the last argument.  C++ functions do not return errors.  If the default error handler is set to `MPI::ERRORS_THROW_EXCEPTIONS`, then on error the C++ exception mechanism will be used to throw an MPI::Exception object.
> Before the error value is returned, the current MPI error  handler is called.  By default, this error handler aborts the MPI job, except for I/O  function errors.  The error handler may be changed with `MPI_Comm_set_errhandler`;  the predefined error handler `MPI_ERRORS_RETURN` may be used to cause error values to be returned.  Note that MPI does not guarantee that an MPI program can continue past an error.

So essentially, writing error handling code for MPI is, with the exception of MPI-I/O related calls, counter productive.  It increases the length of your code, obscures the logic, and doesn't contribute to its quality.

On the topic of error values, as a Fortran programmer you should be aware that when you use the `mpi` module, you have to include an error value argument for most procedures.  Forgetting to do so leads to very interesting, non-local bugs that are hard to track down.  The procedure will in that case still write the error value to memory, but to some unspecified location, leading to trouble down the road.

A much better alternative is to use the `mpi_f08` module.  A first advantage is that the error value is an optional argument.  Since you will not use the value anyway (except perhaps for MPI-I/O), it is simpler to just leave it out in the procedure call.  A second advantage is that many types were introduced, e.g., `MPI_Stats`, `MPI_Request`.  The procedures are defined using these types, and hence the compiler can catch a lot of errors that would go unnoticed when using the older `mpi` module.  If you accidentally swap two arguments, and they have distinct types, the compiler will yield an error.  Given the non-trial procedure signatures, using keyword arguments is very helpful as well.

C++ programmers might be happy to notice there is a C++ API for MPI, but don't get excited.  It has been deprecated in the MPI-3 standard, and will disappear in some future specification release.  For new development, you would be wise to avoid it.


### Deadlocks

When using MPI, there are quite some opportunities to create a deadlock situation.  Some are obvious, others more subtle.

Among the more obvious causes of a deadlock are

  * tag mismatch in MPI send and receives,
  * source and destination mix-ups in MPI sends and receives,
  * incorrect ordering of MPI send and receive calls between peers.

In the first two situations, a process will be stuck in a communication operation because its partner is expecting either a different tag, or another partner to communicate with altogether.

The third situation usually occurs when pairs of processes are exchanging information.  Both start a, e.g., send operation, which blocks because no corresponding receive is done.  Note that this may actually be a heisenbug.  Depending on whether the send operation is synchronous or asynchronous, the deadlock may manifest itself or not.  For `MPI_Send`, that can be determined at runtime.

There are various approaches to write more robust code in this scenario.  You can use non-blocking sends/receives, and wait for completion before reusing/using the buffer.  As alternatives, you can use `MPI_Sendrecv` to exchange information between two processes, or even `MPI_Neighbor_alltoall`.

If not all processes in a communicator participate in a collective operation, the application will also deadlock.

When using one-sided communication, care has to be taken with the order of the calls of `MPI_Win_post`, `MPI_Win_start`, `MPI_Win_complete` and `MPI_Win_wait`.  If you have them in an inappropriate order you will get a deadlock as well.

Although there are quite a number of creative ways to end up in a deadlock, this is a situation that is easy to detect, although perhaps not trivial to fix.  Data races are more subtle.


### Data races

In the context of point-to-point or collective asynchronous communication, using or reusing a buffer before the communication is completed can lead to data races.  Most likely, you will need to use `MPI_Wait` or similar to ensure the asynchronous request is completed.

When using one-sided communication, RMA epochs and local load/store epochs should not overlap, so you have to take care to use `MPI_Win_fence` or `MPI_Win_post`, `MPI_Win_start`, `MPI_Win_complete` and `MPI_Win_wait` in the appropriate order, and which operations to perform during the resulting epochs.  To improve performance, each of those operations can be optimised using assertions on the operations performed in the previous, current and subsequent epochs.  However, mistakes will lead to data races.

MPI shared memory programming is subject to the same pitfalls that were discussed in the previous section on multithreaded programming with OpenMP.


Typically, Fortran compilers do an excellent job on optimising your code.  However, sometimes the compiler can go a bit too far, and you have to ensure that certain optimisations are not performed.  Consider the following code fragment.

~~~ fortran
call MPI_Irecv(buffer, count, data_type, source, tag, communicator, &
               request)
...
call MPI_Wait(request, status)
~~~

It should be obvious that the variable `buffer` can not be used between the calls to `MPI_Irecv` and `MPI_Wait`.  Its value is only guaranteed to be updated when the call to `MPI_Wait` is done.  Between the two calls, the value of `buffer` can be the old value, the new value, or even a partially updated value for a non-trivial message.

The Fortran compiler may decide to optimise the code by storing the value of `buffer` in a register after the call to `MPI_Irecv`.  The value of `buffer` in memory is updated, but after the call to `MPI_Wait` the value stored in the registry is used, since from the point of view of the compiler there was no way the value of `buffer` could have changed between the two MPI procedure calls.  If that happens, you have a data race on your hands.

You can prevent this optimisation by declaring the `buffer` variable `asynchronous` if your compiler correctly implements that.  Such a compiler is compliant with TS-29113.  The MPI variable `MPI_ASYNC_PROTECTS_NONBLOCKING` will be `.true.` in that case.  The Intel compiler `ifort` (version 2018 for certain) is TS-29113 compliant, GCC's `gfortran` (version 7.3) is not.

To ensure that even a non-TS-29113 complient compiler does the right thing, MPI-3 defines a procedure `MPI_F_sync_reg` that only serves to trick the compiler.

~~~ fortran
real, asynchronous :: buffer
...
call MPI_Irecv(buffer, count, data_type, source, tag, communicator, &
               request)
...
if (.not. MPI_ASYNC_PROTECTS_NONBLOCKING) &
    MPI_F_sync_reg(buffer)
call MPI_Wait(request, status)
~~~


### Miscellaneous issues


For collective communication routines such as `MPI_Bcast` or `MPI_Gather`, buffer sizes at the root process and the other processes in the communicator should match.  This is required by the MPI standard, and modern MPI implementations will at least warn if this is not the case.

Similarly, types for send and receive buffers in communication routines should match.  Failure to do so may result in interesting bugs that are hard to track down.

Defining, but forgetting to commit an MPI user defined type using `MPI_Type_commit` is also a potential source of problems.

Any resource that has been allocated should be freed as well.  Failing to do so may lead to a memory leak.  This is fairly obvious for dynamic memory allocation, but when using MPI, there are other resources as well, e.g., user defined types and groups.  Those should be freed when no longer required using  `MPI_Type_free` and `MPI_Group_free` respectively.

For both one-sided communication and shared memory programming with MPI remote addresses have to be computed, which of course again leads to excellent opportunities to introduce nasty bugs in your code.  Similarly, dynamic memory allocation using, e.g., `MPI_Alloc_mem` may lead to issues.
