# Introduction to unit testing

Testing is obviously a way to ensure that at least part of the functionality behaves as expected. However, good tests can provide more than that, they can help ensure that changes to the code base don't introduce defects.

A code base evolves dynamically, potentially over a long period of time. Adding new features to software is typically quite error prone, and might inadvertently break some use cases. In order to minimize this risk should have a sizable collection of tests available that check whether results are as expected, and be able to run those easily and frequently as part of your development cycle.

Unit tests are an excellent approach. They consist of many small fragments of code that each test very specific aspects of the functionality of a library. Using frameworks such as `pFUnit` for Fortran or `CUnit` for C/C++ will take care of the "bookkeeping" and ensure that running tests is effortless.

In this section, we will discuss how to write effective unit tests using these frameworks, and how to integrate them into your development process.
