# Introduction to static code checkers

For some programming languages such as C, C++ and Python among others, we can use tools that analyse our source code to find potential defects.  These tools work by analysing the source code files, looking for patterns in the code that may indicate issues.

Static analysers can also be used to report violations of style conventions and best practices for the target language.  They offer considerable help to ensure that our code is consistenly formatted, clean, and idiomatic.

For an interpreted language such as Python, static code analysers such as Pylint and Flake8 are a great help.  Programming errors only occur at runtime, so you easily use a lot of time by having to run and rerun your code until they have all been fixed.  This can be time consuming, and you are never certain that all code paths have been executed.  Using a static analyser will detect at least a number of common defects, saving you quite some time.

For compiled languages such as Fortran, C and C++, the compiler usually does a good job detecting many of the problems a static analyser would report, but these tools will still alert you to issues that are missed by the compiler.

For C and C++, many static analysers are available, some as commercial products, others as free and open source software. Here we will discuss `Cppcheck` and illustrate some of its capabilities that help us improve our coding style and detect bugs. It will report some issues the compilers will typically miss, so it is worth being added to your development toolchain.

Cppcheck also provides some advice on improving the performance of your code, but that is outside the scope of this training.
