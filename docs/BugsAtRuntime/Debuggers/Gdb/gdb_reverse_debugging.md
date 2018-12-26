# Can you go back in time?

Some debuggers support reverse debugging, i.e., when your application is halted at a breakpoint, you can actually take a step backward in the execution.  The philosophy is that you run up to a point where there is trouble, and then step back in time to see when the problem arises.

This may sound promising, and it is an interesting approach, but not without its issues.  The main problem is the memory requirement of this approach.  Since there is in general no way to reverse the actual computation, the state of the application has to be recorded.  Imagine that one of the data structures in your application is a 100,000 by 100,000 matrix of floating point numbers, and that this matrix is modified in each time step of an iterative process, then it is easy to compute the memory requirements of storing the state for a single time step: it would be 40 billion bytes.  Keeping track over multiple time steps would require an excessive amount of memory.

Hence the designers of Arm DDT have decided to forego reverse debugging, since it does not scale for typical HPC applications that run thousands or even hundred thousands of processes.

Another issue is that the execution time will potentially be much longer, due to the bookkeeping operations the debugger has to perform in order to keep track of the state of the application.  This is an obvious concern for HPC applications, but it may already be an issue for small scale scientific applications as well.

In GDB you can actually do reverse debugging, and for small scale applications it can sometimes be useful.


## Workflow for reverse debugging

The workflow can be summarised as follows:

  1. find a location in the code that is close to the point were you know there is a problem, but where the state is still okay; set a breakpoint at that location;
  1. set a breakpoint at the earliest location where the problem manifests itself;
  1. run the application until it halts at the first breakpoint;
  1. enable reverse debugging by enabling state recording using the `record` command;
  1. continue executing the application until it halts at the second breakpoint;
  1. step back and inspect the state of variables to your heart's content.

Note that for performance and to conserve memory, the number of statements executed between the first and second breakpoint should be minimal.

The commands to go back in time are named after those to go forward in time, i.e.,

  * `reverse-next`
  * `reverse-step`
  * `reverse-continue`
  * `reverse-finish`

The command `set exec-direction reverse` changes the semantics of `next`, `step` and `continue` so that they step back in time.  This may be convenient, but can also lead to considerable confusion.


## Example session

Consider an application that operates on vectors, the relevant data structures and function declarations are listed below.

~~~~c
typedef struct {
    double *element;
    int n;
} Vector;

Vector *init_vector(int n);
void fill_vector(Vector *v, double start_value, double delta_value);
void print_vector(Vector *v);
~~~~

The function `init_vector` allocates an array of length `n` to `element`, and initialises all elements to 0.

The main code, lines 14 through 18, are shown below.

~~~~c
for (int j = 0; j < nr_vectors; j++) {
     vectors[j] = init_vector(vector_len);
     fill_vector(vectors[j], j, 0.1*(j + 1.0));
     print_vector(vectors[j]);
}
~~~~

We start the application under the control of the debugger and set breakpoints at lines 15 and 17 respectively.  We will start recording for reverse debugging at line 15, continue till line 17, and reverse.

    (gdb) b 15
    Breakpoint 1 at 0xb61: file features.c, line 15.
    (gdb) b 17
    Breakpoint 2 at 0xbc4: file features.c, line 17.
    (gdb) r

    Breakpoint 1, main () at features.c:15
    15	        vectors[j] = init_vector(vector_len);
    (gdb) record
    (gdb) n
    16	        fill_vector(vectors[j], j, 0.1*(j + 1.0));
    (gdb) p vectors[j]->element[1]
    $1 = 0
    (gdb) n

    Breakpoint 2, main () at features.c:17
    17	        print_vector(vectors[j]);
    (gdb) p vectors[j]->element[1]
    $2 = 0.10000000000000001
    (gdb) reverse-next
    16	        fill_vector(vectors[j], j, 0.1*(j + 1.0));
    (gdb) p vectors[j]->element[1]
    $3 = 0

Executing the `reverse-next` command has restored `vectors[j]` to the state before the function call to `fill_vector`.
