# Error handling in C++

All advise given on error handling in C is of course also relevant for C++.  However, C++ adds exception handling as a way to deal with run-time errors, and propagate these through your application.

To accommodate this, C++ has a few keywords: `throw`, `try` and `catch`.  When an error has been detected, an exception can be thrown, e.g.,

~~~~cpp
#include <stdexcept>

int fac(int n) {
    if (n < 0) {
        std::string msg {"fac received "};
        msg += std::to_string(n) + ", argument must be positive";
        throw std::domain_error {msg};
    } else {
        int value = 1;
        for (int i = 2; i <= n; i++)
            value *= i;
        return value;
    }
}
~~~~

The `throw` statement will transfer control to the calling context of the `fac` function.  The destructor of all objects on the stack will be called since they go out of scope.

The exception `domain_error` used here is declared in the `stdexcept` header.  This header declares some standard exceptions that cover many cases, e.g., `logic_error`, `invalid_argument`, `out_of_range`, and so on.

In the calling context, the exception can be caught, and handled appropriately using a `try ... catch ...` statement, e.g.,

~~~~cpp
...
try {
    std::cout << fac(n) << std::endl;
catch (std::domain_error& e) {
    std::cerr << "math function called with argument not in its domain: "
              << e.what() << std::endl;
    ...
}
...
~~~~

In the code fragment above, the exception is caught and handled in the immediate calling context.  If that is not the case, the exception percolates up the call stack, for each function calling the destructors for the stack variables that go out of scope.

Using exceptions makes it easier to handle exception in context to provide the user of your application with relevant feedback.  What can be done at that point depends on the exception safety level.  Generally, four levels of exception safety are recognised:

  1. Nothrow exception guarantee: the function or method never throws an exception.  This is expected from destructors.
  1. Strong exception guarantee: the state of the program is rolled to the state just before the exceptional state occurred, e.g., failed operations on STL containers.
  1. Basic exceptions guarantee: clean-up may be required, but the application is in a valid state.
  1. No exceptions guarantee: the application is not in a valid state, e.g., invariants are violated, or resource leaks may have occurred.

For the last level, no exception guarantee, recovery will be dangerous, while handling exceptions gets easier on each higher level.

Often, it can be convenient to define application-specific exceptions.  These can be derived from the `std::exception` class.  It is good practice to define a base class, perhaps abstract, that is the ancestor to all application-specific exceptions.

It is worth noting that C++ has no `finally` block as other programming languages such as Java and Python have.  In those languages, the `finally` block is used to ensure that resources are managed properly both in case of normal behavior as well as failure.  In C++, this is not required if resource management follows the RAII principle (Resource Allocation Is Initialization), which essentially means that the destructor is responsible for proper resource deallocation.

Another interesting point is rethrowing of exceptions.  If you want to rethrow an exception preserving its polymorphic type, `throw;` will do that, e.g.,

~~~~cpp
try {
    ...
} catch (std::exception& e) {
    std::cerr << "Oops!" << std::endl;
    throw;
}
~~~~

In the calling context of this fragment of code, `e` will still have its original polymorphic type.
