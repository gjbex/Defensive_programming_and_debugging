# Introduction to code coverage

Unit tests are very useful to formulate fine-grained test to check the functionality of functions and methods. Unit tests check for edge and corner cases, but also for handling of error conditions such as exceptions being thrown.

This is of course very useful in itself, but using a run of the complete unit test suite can also provide a good test to see whether all functions and methods are called, and all codes paths in the code get executed.

Code coverage tools will instrument your code, run it, and provide feedback on regions of code that are not executed doing that run.

Since we claim that code that is not tested is not correct, coverage provided by running all the unit tests should in fact be (close to) 100 %.  If code coverage is insufficient, more unit tests should be added to the test suite.

We will show how to use `gcov` and `codecov`, code coverage tools the GCC and Intel compiler suite respectively, and provide a number of examples to illustrate how to use the output to increase the quality of our unit test suite.
