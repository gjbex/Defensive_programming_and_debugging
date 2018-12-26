# Functional testing best practices

Unit testing is an invaluable help for the developer since it catches bugs introduced when the code base changes. Tests can be executed easily and are run frequently.

However, unit tests typically concentrate on the low level functionality of the software project. They test whether individual functions behave as expected. This is white box testing, since the tests are developed with access to the "innards" of the software under test.

In some circumstances, this may be all that is required, e.g., when developing a relatively small or very focussed library. In many cases though, unit testing is best supplemented by functional testing.

The point of view of functional testing is opposite to that of unit testing since functional tests will focus on the application as a whole.  Are the results for a sophisticated use case reproduced as expected?  Does the application's user interface, command line interface (CLI), or graphical user interface (GUI) behave as expected?  Are options handled as expected?  This is often called black box testing since only the user interface is accessed.

Functional testing can also be applied to third party applications that are part of a workflow. For instance, suppose that your application relies on the output of another application not developed by you. If the output format of that application changes from one version to the next, running a functional test will make clear whether there is an impact on your workflow, and you may fix problems by adapting your application.

The best way to do functional testing is by using a continuous integration workflow. When the functional tests are run, first a container is prepared with the required operating system and software stack. Next, your software is built within the container, so that the environment is completely controlled. If the build succeeds, tests are run. A report is generated to show failures if they occur.

Note that it is possible to set up a matrix of operating system versions and compiler versions to ensure that your code will build and executed cleanly on a wide range of software platforms.

[Travis CI](https://travis-ci.org/) is a very nice online continuous integration service that is free to use for open source software projects.

The question remains how to code the actual tests that will be executed by the continuous integration system. A convenient way is to reuse the unit test paradigm, but now on the level of the shell. In other words, the unit tests will be relatively short shell scripts that invoke your application using various parameters and input data, and verify the results.

The [shunit2 framework](https://github.com/kward/shunit2) provides a nice framework for this purpose. It provides similar functionality as the unit testing frameworks for specific programming languages. However, from the point of view of the software project this is black box, rather than white box testing.

The same concerns as for unit testing apply. For instance, it is important that the tests cover the use cases as well as possible. Here too, code coverage can be a great help to detect which application aspects are tested, and for which additional tests need to be implemented to improve the coverage.

We will illustrate the use of shunit2 for functional testing in this section.  Full continuous integration is a bit out of scope of this course.
