# Introduction to finding bugs

Even while you maintain a clean coding style and practices, and use the compiler's abilities to catch mistakes, you'll still have to find and fix bugs.

Programming is not easy, often algorithms and data structures are quite sophisticated, and the application fails for edge or corner cases that were not taken into account. The semantics of a programming language can be quite subtle at times, so that the code may do things we don't expect.

Whatever the cause, bugs will be present, and given the somewhat depressing statistics on the time the average developer spends on that, we would better go about it as efficiently as possible.

Many of us would start inserting statements to write information about the program state to the screen to get a handle on what is going on, and identify the point in the code where variables are assigned suspicious values. When done systematically, this approach will work.

However, when searching for an elusive bug, this will require quite a number of extra lines of code, which we subsequently have to clean up again, potentially introducing a new bug.

Debuggers are designed to help us searching for bugs in a much more efficient way, without requiring code modifications. They allow us to monitor the execution of an application step by step if we need to, keeping track of changes to the values of variables. They allow us to run an application, but automatically halt executing based on a Boolean condition or access of a variable.

In this section, we will familiarize ourselves with the `GDB` debugger and its more sophisticated features. While doing so, we will discover some debugging techniques that are general, so that we can apply them when using other debugging tools as well.

A second debugging application we will discuss is `Valgrind`, essentially a collection of tools
to identify issues related to using memory inappropriately. Everyone is familiar with the dreaded `segmentation fault` crash, and knows that bugs causing this "unpleasantness" are notoriously hard to identify. `Valgrind` can be a great help in such situations, as well as in identifying the source of memory leaks.

In this section, we will deal with serial code, while the next will be devoted to tools for debugging parallel code.
