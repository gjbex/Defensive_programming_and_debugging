# Introduction to documentation

Documentation is a very important, and often sadly neglected part of a software development project.

When you are developing an application, you should write documentation for the user of your application to help her correctly use the software and its features, and interpret output, warnings and errors correctly.

As part of that application, you create new classes and functions that form a library, and that can potentially be reused. Or, alternatively, the deliverable of your project might be a library as such, to be used by others. This library and its contents should be documented as well.

Incorrect use of APIs (Application Programming Interfaces) or misconceptions about the semantics of functions is one of the major sources of bugs. Good quality and up-to-date documentation can help a lot to cut down on the number of the resulting code defects.

We will discuss `doxygen`, a tool for generating nicely formatted API documentation, and that supports a wide range of programming languages.

For application documentation, we take a look at `mkdocs` which can be integrated into your development process using GitHub and ReadTheDocs.

Additionally, we will briefly discuss the difference between documentation and comments in code.
