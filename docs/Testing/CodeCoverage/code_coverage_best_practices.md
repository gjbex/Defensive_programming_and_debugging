# Code coverage best practices

Maintaining code over long periods of time is quite expensive. The larger the code base, the more effort has to be spent on keeping code up to date. If some parts of the code are never used, that adds to this burden without return on investment. Updates are an issue as well, since some unused parts of the code may get out of sync with respect to the parts that are executed regularly. If someone starts using the abandoned part of the code, interesting bugs may creep into her code.

Hence code that is not used is best removed from the code base. If you use a version control system and informative commit messages, it is quite easy to recover that code later when it is unexpectedly required.

An important concern when writing tests for your software project is whether or not all branches in function, and indeed all functions are tested. Figuring out by hand whether that is the case is pretty hard for sizable projects.

Fortunately, software tools are available for checking which parts of the code base are executed and which are not.  For many programming languages, one has to resort to third party tools, but the compilers for C, C++ and Fortran support this out of the box.

The first step in the workflow is to instrument the code with instructions to do the bookkeeping for reporting which lines of code have been executed. Compilers have options to do that automatically, so this can easily be incorporated into the build process by adding a make target specific for a code coverage build.

The second step is to execute the software, so that a report is generated. In case you wonder how to run your code to get the most useful report, this depends on your goal. If you want to detect code that is likely not executed in applications, running a number of typical use cases are the best way to go. On the other hand, if you want to verify that you have a comprehensive set of unit tests, execute those.

The third step is to inspect that report. Typically, you will get summary information, e.g., the percentage of the code covered in each file. In addition, each individual file can be inspected on a line by line basis. Lines that have not been executed are clearly marked, so that they are easy to spot.

Finally, you decide to either weed out the lines if they are dead code, i.e., code that will never be executed in the context of your project, or to create additional unit tests if that code will be executed but is not tested yet.

Since code coverage tests produce artifacts, it is best to add rules to remove these artifacts to your make file.  This ensures you start with a clean slate when rebuilding. 

Code coverage assessment is an important tool for delivering good quality code, and goes hand in hand with unit testing and functional testing.


## How to enable code coverage?

Code coverage is provided by the compiler, and the information gathered during runs of the application can be accessed using a tool that comes with your compiler.


### GCC

To enable code coverage testing for GCC, use the three compiler options

  1. `-g`
  1. `-fprofile-arcs`
  1. `-ftest-coverage`

When you run the application, statistics are gathered in files with extensions `.gcda` and `.gcno`.  This is cumulative, so these files are updated each time you run the application.  However, these

Those `.gcda` and `.gcno` files are binary, and not intended for human consumption.  The `gcov` tool will use the information stored in those files, and created an annotated source file with extension `.gcov`.  For instance, for a source file `palindrome.f90`, that is

~~~~bash
$ gcov palindrome.f90
~~~~

This will produce `palindrome.f90.gcov` which you can view using any text editor or even `less`.


### Intel

To enable code coverage testing for Intel compilers, use the three compiler options

  1. `-g`
  1. `-prof-gen=srcpos`
  1. `-prof-dir=./profile`

You can of course choose any directory you like to store the profile information.  Note that the directory should be created before compilation.

When you run the application, statistics are gathered in files in the profile directory, `./profile` in the option above.  This is cumulative, so these files are updated each time you run the application.  However, these

Next, you have to merge the build and runtime information using

~~~~bash
$ profmerge  -prof_dir ./profile
~~~~

Note that the name of the option is not exactly the same as the compiler options.

The information contained in the profile directory is not human readable. However, you can generate an HTML overview using

~~~bash
$ codecov  -dpi ./profile/pgopti.dpi  -spi ./profile/pgopti.spi
~~~~

The current working directory now contains a file `CODE_COVERAGE.HTML` that you can open with a web browser.  The output is color-coded, a yellow background means that those lines in a function have not been executed, red is for a function that was called at all.
