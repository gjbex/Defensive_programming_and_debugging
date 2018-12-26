# Are bugs deterministic?

Thanks to the hype about quantum computing, chances are that you are familiar with the German theoretical physicist Werner Heisenberg (1901-1976). He was one of the pioneers of quantum physics and formulated the uncertainty principle that is named after him.  However, one of his key insights was that the state of a system can be altered by observing it.

Hence the term ['Heisenbug' was coined](https://queue.acm.org/detail.cfm?id=1036486) to refer to bugs that seem to vanish once you start to debug.

Often, to allow for effective debugging, the applications are modified.  For instance, you would probably be compiling with optimisation disabled (`-O0`) rather than the default `-O2` optimisation level.  You may be inserting print statements (don't, use a debugger) to try and see what is going on.  All these small changes can in fact suppress the symptoms of the bug, making debugging all the more "interesting".

There are a few other categories of bugs that are named after scientists or events, but those names haven't really caught on.

  1. bohrbug: a good, old fashioned, reliable bug (like [Niels Bohr](https://en.wikipedia.org/wiki/Niels_Bohr)'s model for the atom: simple, deterministic);
  1. mandelbug: when searching for such a bug, you discover more and more bugs (like a [Mandelbrot](https://en.wikipedia.org/wiki/Benoit_Mandelbrot) fractal); it is also used for bugs that appear to be non-deterministic;
  1. schroedinbug: a bug that only manifests itself after the programmer noticed that it should be there (like [Schroedinger](https://en.wikipedia.org/wiki/Erwin_Schr%C3%B6dinger)'s cat thought experiment);
  1. hindenbug: a bug with truly catastrophic consequences (Like the [Hindenburg zeppelin disaster](https://en.wikipedia.org/wiki/Hindenburg_disaster));
  1. higgs-bugson: a bug you know is likely there because of unconfirmed user reports but that you can't pin down (like the [Higgs boson](https://en.wikipedia.org/wiki/Higgs_boson) until its existence was finally confirmed recently).

Given that these terms are fun, but not widely known and used, I'll use the term Heisenbug somewhat loosely to also include mandelbugs.

A scary example of a mandelbug occurs in the following code:

~~~~c
#include <err.h>
#include <stdio.h>
#include <stdlib.h>

static double __arg__;
#define SQR(a) ((__arg__ = (a)) == 0.0 ? 0.0 : __arg__*__arg__)

int main(int argc, char *argv[]) {
    double *a, *b, *c, sum;
    int n = 1000000, i;
    if ((a = (double *) malloc(n*sizeof(double))) == NULL)
        errx(EXIT_FAILURE, "can't allocate a[%d]", n);
    if ((b = (double *) malloc(n*sizeof(double))) == NULL)
        errx(EXIT_FAILURE, "can't allocate b[%d]", n);
    if ((c = (double *) malloc(n*sizeof(double))) == NULL)
        errx(EXIT_FAILURE, "can't allocate c[%d]", n);
    sum = 0.0;
    for (i = 0; i < n; i++) {
        b[i] = (rand() % 2) ? 0.01*i : 0.0;
        c[i] = (rand() % 2) ? 0.03*i : 0.0;
        sum += b[i]*b[i] + c[i]*c[i];
    }
    printf("sum = %.2lf\n", sum);
    for (i = 0; i < n; i++)
        a[i] = SQR(b[i]) + SQR(c[i]);
    sum = 0.0;
    for (i = 0; i < n; i++)
        sum += a[i];
    printf("sum = %.2lf\n", sum);
    free(a);
    free(b);
    free(c);
    return EXIT_SUCCESS;
}
~~~~

When you compile this using GCC (7.x, but any other I'm aware of) this application will produce the correct result, i.e.,

~~~~bash
$ ./a.out
sum = 166581086880546.25
sum = 166581086880546.25
~~~~

However, compiling the same code using the Intel compiler (upto 18.x) will produce an application that prints the following output:

~~~~bash
$ ./a.out
sum = 166581086880546.25
sum = 224904286352835.62
~~~~

The output is very clearly wrong.  It will be an exercise for you to figure out what the problem might be.
