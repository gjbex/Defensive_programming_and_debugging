# Arm DDT

Arm DDT is an excellent debugger that helps you debug applications at almost any scale, that run on tenthousands of cores.  It is a commercial product, so you need a license to run it, but perhaps your HPC center has one.

On their website, Arm desscribes DDT as follows:

> Arm DDT is the number one debugger in research, industry, and academia for software engineers and scientists developing C++, C, Fortran parallel and threaded applications on CPUs, GPUs, Intel and Arm. Arm DDT is trusted as a powerful tool for automatic detection of memory bugs and divergent behavior to achieve lightning-fast performance at all scales.

DDT is part of Arm Forge, which also includes MAP, an excellent profiler.

As an aside, although officially DDT stands for Distributed Debugging Tool, it is very likely a pun on dichlorodiphenyltrichloroethane, commonly known as DDT.  It is an insecticide that was used extensively from 1950s to 1980s.  It was mostly banned for its side effects on the environment.  However, Arm DDT is entirely safe to use, and will help you eradicate the bugs in your software.


## Debugging with DDT

Everything you know about GDB can be applied to DDT.  You can set breakpoints and inspect the values of variables. Stepping through the execution can be done using buttons or keyboard shortcuts.

Just like in GDB, breakpoints can be conditional, and you can set watchpoints as well.  Tracepoints offer the functionality that the dynamic print (`dprintf`) implements in GDB.

Inspecting the call stack and switching frames is very intuitive, as is switching between threads and/or processes.

Evaluating expressions at runtime can also be done.  These expressions are displayed in their own view, which is updated each time the application is paused.


## Data exploration

Arm DDT was indeed designed to work at scale, to debug applications that have thousands of processes and threads.  A lot of attention has been paid to ensure that information is aggregated as much as possible.  From the visualisation of the call stack, you can immediately see how many processes are pauzed in various function calls.

Another area where information aggregation is very important is the inspection of variables.  The user interface is cleverly designed to support doing this effectively for parallel code.  Spark lines give you insight into the values across processes or threads.  This helps to spot potential issues quickly, even without switching to other processes or threads.

Another feature that is quite convenient in this context is the option to compare a value across processes or threads.  This shows the value of that variable, but also the statistics over these values.  It includes counts for values such as infinity and NaN.

For arrays there is a specialised tool, i.e., the array view. This view can be used to visually inspect an array and create a 2D layout. If the array is distributed over multiple processes, this can be visualised as well.  Just as for the comparison across processes, statistics are available as well.

Given that visualisation can be a great help to spot anomalies in data, and hence bugs, the scientific visualisation package VisIt can be used integrated with Arm DDT.


## Memory access

In addition, Arm DDT has extensive support for memory access debugging, similar to what you can do with Valgrind.  You can tune the level of debugging, which impacts the performance.

You can check for

  * basic: invalid pointers passed to memory allocation functions;
  * check-funcs: checks more functions for invalid pointers (mostly string functions);
  * check-heap: heap corruption by, e.g., writes to invalid addresses;
  * check-fence: checks whether the end of an allocation has been overwritten when it is freed;
  * alloc-blank: initialises allocated memory to some known value;
  * free-blank: assigns a known value to memory locations that are freed;
  * check-blank: checks whether memory that was blanked has been overwritten (implies alloc-blank and free-blank);
  * realloc-copy: ensures that data is copied to a new pointer upon reallocation;
  * free-protect: enables (when possible) hardware checks to verify that memory that was freed is not overwritten.

As mentioned, this can have an impact of performance which you can mitigate at least in part by reconfiguring options at runtime, e.g., only enabling some checks during a specific phase of the execution.

It is also possible to limit memory checks to a range of processes only.  However, this may cause load imbalance, and hence not actually improve performance.


## Forging code

As mentioned, DDT is part of Arm Forge.  The name refers to the fact that the source code view in DDT is actually a full fledged editor.  From within DDT, you can modify and rebuild your code and it even integrates with version control systems.

This allows for a fast and convenient round-trip experience when identifying and fixing code defects.


## Log book

A seemingly minor feature can be a great convenience.  Arm DDT automatically maintains a log of your debug session by recording each action you take.  In addition, you can add your own annotations.

This can be a great help during lengthy debug sessions.


## Alternatives

Of course, there are alternatives to Arm DDT.

At a pinch, you can use GDB, but you would face several inconveniences since

  * you would have to ensure your application idles after starting it to ensure you can attach GDB debug sessions to the processes, and
  * you have to attach a GDB session to all the processes you are interested in.

In this setup, it would be very hard to aggregate information across processes and conveniently explore your application's data.

The Eclipse PTP (Parallel Tools Platform) should offer more convenient debugging options, but at least on the clusters I've access to, that doesn't work reliably.

Lastly, RogueWave has a commercial product that has many similarities to Arm DDT, e.g., TotalView.
