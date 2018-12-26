# Data races and deadlocks

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

As an example, consider Alice and Bob using an online shopping application.  Both are a fan of the obscure author Justin Aane who wrote the novel "Pride", and its sequel "Prejudice".  The webshop has only one copy of each left in stock.  Alice adds "Pride" to her shopping basket, while Bob adds "Prejudice" to his.  Now Alice would would like to add "Prejudice", while Bob would like to add "Pride".  However, both see that the books are no longer in stock.  They decide to keep the novel they already put in their shopping basket, and to wait until the missing book is back in stock to make the purchase.  However, both "Pride" and "Prejudice" are out print, and Alice and Bob find themselves in a deadlock situation.

Formally, the books are the resources and our protagonists, Alice and Bob the processes. A resource (book) is held by a process (person) when it is in that persons shopping basket.

  1. Since there is just a single copy of each book, having one in a shopping basket is mutually exclusive: either Alice or Bob can have it in their respective basket, but not both simultaneously.  (Condition 1: mutual exclusion)
  1. Both Alice and Bob hold on to the content of their shopping basket, while waiting to add the missing volume. (Condition 2: hold and wait)
  1. Bob can't make Alice remove her "Pride" from her shopping basket, and Alice has no influence over Bob's basket either. (Condition 3: no preemption)
  1. Alice is waiting for "Prejudice", held by Bob, who is in turn waiting for "Pride", held by Alice. (Condition 4: ircular wait)
