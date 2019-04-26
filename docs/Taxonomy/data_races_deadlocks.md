# Data races and deadlocks

Data races and deadlocks are bugs that occur only in the context of parallel programming.


## Data races

Data races can lead to incorrect results of computations.  Potentially, this type of bug is subtle, and may go unnoticed for a long time.


### Formal definition

Formally, a data race will occur when two or more threads

  1. access the same memory location concurrently;
  1. at least one thread accesses that memory location for writing; and
  1. no implicit or explicit locks are used to control access.


### Data races in OpenMP and MPI

Both OpenMP and MPI applications may be susceptible to this type of bug.

For OpenMP, there are several ways to introduce a data race, e.g.,

  * a variable that should be thread-private is shared;
  * a shared variable is used for a reduction operation, but neither a `reduction` clause, a `critical` or an `atomic` directive is used to guarantee atomic updates.
  * an inappropriate `nowait` clause on a workshare directive.

In MPI application, data races can be caused by, e.g.,

  * reusing a communication buffer before that was save, e.g., asynchronous point-to-point communication or collectives;
  * inappropriately or missing active target synchronisation when using one-sided communication;
  * inappropriate or missing fences for passive target synchronisation when using one-sided communication;
  * shared memory operations without proper synchronisation.

Data races in multi-threaded application can be detected using Valgrind or Intel Inspector.  For OpenMP, only the latter will work out of the box.


## Deadlocks

Informally, a deadlock occurs in a concurrent system when each process is waiting for some other process to take action.


### Formal definition

Formally, a deadlock situation occurs when all the following four conditions are met:
 
  1. Mutual exclusion: At least one resource must be held in a non-shareable mode. Otherwise, the processes would not be prevented from using the resource when necessary. Only one process can use the resource at any given instant of time.
  1. Hold and wait or resource holding: a process is currently holding at least one resource and requesting additional resources which are being held by other processes.
  1. No preemption: a resource can be released only voluntarily by the process holding it.
  1. Circular wait: each process must be waiting for a resource which is being held by another process, which in turn is waiting for the first process to release the resource. In general, there is a set of waiting processes, P = {P1, P2, ..., PN}, such that P1 is waiting for a resource held by P2, P2 is waiting for a resource held by P3 and so on until PN is waiting for a resource held by P1.

These are known as the Coffman conditions.


### Example: web shopping

As an example, consider Alice and Bob using an online shopping application.  Both are a fan of the obscure author Justin Aane who wrote the novel "Pride", and its sequel "Prejudice".  The web shop has only one copy of each left in stock.  Alice adds "Pride" to her shopping basket, while Bob adds "Prejudice" to his.  Now Alice would would like to add "Prejudice", while Bob would like to add "Pride".  However, both see that the books are no longer in stock.  They decide to keep the novel they already put in their shopping basket, and to wait until the missing book is back in stock to make the purchase.  However, both "Pride" and "Prejudice" are out print, and Alice and Bob find themselves in a deadlock situation.

Formally, the books are the resources and our protagonists, Alice and Bob the processes. A resource (book) is held by a process (person) when it is in that persons shopping basket.

  1. Since there is just a single copy of each book, having one in a shopping basket is mutually exclusive: either Alice or Bob can have it in their respective basket, but not both simultaneously.  (Condition 1: mutual exclusion)
  1. Both Alice and Bob hold on to the content of their shopping basket, while waiting to add the missing volume. (Condition 2: hold and wait)
  1. Bob can't make Alice remove her "Pride" from her shopping basket, and Alice has no influence over Bob's basket either. (Condition 3: no preemption)
  1. Alice is waiting for "Prejudice", held by Bob, who is in turn waiting for "Pride", held by Alice. (Condition 4: circular wait)


### Deadlocks in OpenMP and MPI

For OpenMP application, deadlocks will not occur, unless you are careless when using explicit lock functions from its runtime library.

In MPI applications, there are several ways to create a deadlock, e.g.,

  * both partners in point-to-point communication do a blocking synchronous send (`MPI_Ssend`, or an `MPI_Send` that does an `MPI_Ssend`);
  * not all processes in a communicator participate in a collective communication operation;
  * active target synchronisation for one-sided communication is implemented incorrectly (`MPI_Win_post`/`MPI_Win_start`/`MPI_Win_complete`/`MPI_Win_wait`).

Deadlocks in multi-threaded application can be detected using Valgrind or Intel Inspector.  For OpenMP, only the latter will work out of the box.

Deadlocks in MPI applications can be diagnosed by Intel Trace Analyzer and Collector (ITAC) or MUST.
