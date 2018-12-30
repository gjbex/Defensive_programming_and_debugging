# Catch2: unit testing for C++

Although you could use CUnit for testing C++ code, there are better alternatives.  A very nice framework is [Catch2](https://github.com/catchorg/Catch2).  You can express tests quite naturally using Catch2 so that they resemble a narrative.

The framework takes a further step along that path by offering support for [Behaviour Driven Development](https://en.wikipedia.org/wiki/Behavior-driven_development) (BDD).

Catch2 is a header-only library, so it is trivial to install, and has support for CMake if you're so inclined.


## The basics

The function under test computes the factorial of a given integer, i.e.,

~~~~cpp
#include <stdexcept>

int fac(int n) {
    if (n < 0)
        throw std::domain_error {"argument must be positive"};
    int result {1};
    for (int i = 2; i < n; ++i)
        result *= i;
    return result;
}
~~~~


### Defining the tests

Defining tests for Catch2 is quite straightforward using the `TESTCASE` macro.  It takes one or two arguments, the name of the test that has to be unique, and, optionally, a tag that is used to group tests. In the example below, `"factorials"` is the name of this test, while `"[fac]"` is the tag.

~~~~cpp
#include <catch/catch.hpp>

TEST_CASE("factorials", "[fac]") {
    REQUIRE( fac(0) == 1 );
    REQUIRE( fac(3) == 6 );
}
~~~~

The code block implements the test, using the `REQUIRE` macro relying on C++ Boolean expressions to implement the tests.  Note that the Boolean expressions should be limited to comparison or a function call. Expressions that include logical operators `&&`, `||` and `!` are too hard to provide meaningful feedback when a test fails.


### Setting up the tests

Setting up the tests is trivial in Catch2.  You simply have to define a preprocessor variable in a C++ file, i.e.,

~~~~cpp
#define CATCH_CONFIG_MAIN
#include <catch/catch.hpp
~~~~

The main function will be generated automatically.  However, that will take the preprocessor/compiler a while, so it is recommended to put the lines above inn their own C++ source file.  That way, the code is generated and compiled only once, and not each time you add or make a change to a test.  Believe me, you will be grateful for this tip.


### Building and running

The build the tests, the compiler needs to be aware of the location of the Catch2 header files, so you have to specify the appropriate `-I` flag.  The most convenient way is to use he single include file which is in the `single_include` directory of the distribution.

~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
test_fac.exe is a Catch v2.5.0 host application.
Run with -? for options

-------------------------------------------------------------------------------
factorials
-------------------------------------------------------------------------------
test_fac.cpp:6
...............................................................................

test_fac.cpp:8: FAILED:
  REQUIRE( fac(3) == 6 )
with expansion:
  2 == 6

===============================================================================
test cases: 1 | 1 failed
assertions: 2 | 1 passed | 1 failed
~~~~

The report is quite comprehensive, showing you the computed versus the expected value for the test(s) that failed, as well as summary information.  In this case, the single test case failed, while of the two assertions, one failed, and one passed.

The `fac` function needs some work.


## More assertions

Although `REQUIRE` is Catch2's main work horse, a few other macros and features are very useful as well.  As was mentioned when discussing best practices, it is important to test for failure, and with Catch2, the `REQUIRE_THROWS_AS` can be used for this purpose.  In the example above, the `fac` function will throw a `domain_error` exception when its argument is strictly negative, since the factorial is only defined for positive integers.  Testing for this is straightforward.

~~~~cpp
#include <stdexcept>
    ...
    REQUIRE_THROWS_AS( fac(-1), std::domain_error );
    ...
~~~~

To test on the exception's message, rather than its type, `REQUIRE_THROWS` can be used, e.g.,

~~~~cpp
    ...
    REQUIRE_THROWS_WITH( fac(-1), "argument must be positive" );
    ...
~~~~

This form is useful to test non-trivial exception messages.

Finally, it is also possible to verify that an exception is thrown (`REQUIRE_THROWS`) or not (`REQUIRE_NOTHROW`).

Catch2 has no dedicated macro for testing floating point equality, but the `Approx` class is provided for this purpose.  It has two methods to set either the relative (`epsilon`) or absolute (`margin`) accuracy of the comparison.  For instance, suppose that the function `compute_pi`, well, computes the value of pi, then it could be tested whether the result deviates from 3.14 by less than one percent as follows:

~~~~cpp
    REQUIRE( compute_pi() == Approx.epsilong(0.01) );
~~~~

Althernatively, the following test would check whether the computed value is in the interval [3.13, 3.15]:

~~~~cpp
    REQUIRE( compute_pi() == Approx.magrin(0.01) );
~~~~

Another quite useful macro is `REQUIRE_THAT`.  It takes two arguments, the computed value and a matcher.  To check whether a string matches a regular expression, the `Catch::Matchers::Matches` matcher can be used, e.g., suppose the function `gen_ip4_address` returns strings such as `"127.0.0.`"` to represent IP4 addresses, than the following `REQUIRE_THAT` macro would verify that.

~~~~cpp
    using Catch::Matchers::Matches;
    ...
    REQUIRE_THAT( gen_ip4_address(),
                  Matches(R"(^\d{1,3}(?:\.\d{1,3}){3}$)") );
    ...
~~~~

Besides the `Matches` matcher, Catch2 also defines `StartsWith`, `EndsWith`, `Equals` and `Contains` for `std::string`.  For `std::vector`, three matchers are defined, `Contains`, `ContainsVector` (subset) and `Equals`.  Moreover, a generic `Predicate` matcher can be used to turn a lambda function (or any callable for that matter into a matcher.

Note that matchers can be combined into Boolean expressions involving the operators `&&`, `||` and `!`.

Finally, a second version for each  `REQUIRE` macro is defined, e.g., `CHECK`, `CHECK_THAT`, etc.  Unlike the `REQUIRE` family, execution of the test case doesn't stop when a `CHECK` fails.


## Fixtures

Fixtures for Catch2 tests are implemented as classes.  The constructor will do the set up and, if required, the destructor is responsible for the tear down.

`TEST_CASE_METHOD` is used to define test cases.  This macro takes two or three arguments.  The first is the class that implements the fixture, the second is the unique name of the test case, and, optionally, the third is the tag.

As a somewhat contrived example, consider a stack that is initialized, and integer values are pushed onto it, starting from 0 up to `max_value`.

~~~~cpp
#include <stack>

class VectorFixture {
    protected:
        std::stack<int> data;
        const int max_value {5};
    public:
        VectorFixture() : data() {
            for (int i = 1; i <= max_value; ++i)
                data.push(i);
        };
};
~~~~

Now tests that use this fixture can be defined as `TEST_CASE_METHOD`, e.g.,

~~~~cpp
nclude <catch2/catch.hpp>

TEST_CASE_METHOD(VectorFixture, "sum", "[stack]") {
    int sum {0};
    while (!data.empty()) {
        sum += data.top();
        data.pop();
    }
    REQUIRE( sum == max_value*(max_value + 1)/2 );
}

TEST_CASE_METHOD(VectorFixture, "product", "[stack]") {
    int prod {1};
    while (!data.empty()) {
        prod *= data.top();
        data.pop();
    }
    REQUIRE( prod == fac(max_value) );
}
~~~~

As you can see, for each test case, the stack in the fixtures is emptied, illustrating that the fixture is set up (and teared down) for each individual test case.

Alternatively, you can also define the test cases as ordinary object methods in for the fixture class, and register them as such using the `METHOD_AS_TEST_CASE` macro.


## Behavior-driven design (BDD)

Catch2 also supports a behavior-driven design approach to testing, and in fact, according to the library's author, this is the prefered way to handle fixtures.
The tests for the factorial function can be implemented as a scenario, i.e.,

~~~~cpp
#include <catch2/catch.hpp>
#include <stdexcept>

SCENARIO( "factorial function return values and exceptions", "[fac]" ) {
    GIVEN( "factorial function 'fac'" ) {
        WHEN( "argument == 0" ) {
            THEN( "fac(0) == 1" ) {
                REQUIRE( fac(0) == 1 );
            }
        }
        WHEN( "argument > 0" ) {
            THEN( "fac(n) == n*fac(n-1)" ) {
                for (int i = 1; i < 6; i++)
                    REQUIRE( fac(i) == i*fac(i - 1) );
            }
        }
        WHEN( "argument < 0" ) {
            THEN( "exception thrown" ) {
                REQUIRE_THROWS_AS( fac(-1), std::domain_error );
            }
        }
    }
}
~~~~

When the resulting test application is run with the `-s` option, it will show the following output.

~~~~
test_fac.exe is a Catch v2.5.0 host application.
Run with -? for options

-------------------------------------------------------------------------------
Scenario: factorial function return values and exceptions
      Given: factorial function 'fac'
       When: argument == 0
       Then: fac(0) == 1
-------------------------------------------------------------------------------
test_fac.cpp:9
...............................................................................

test_fac.cpp:10: PASSED:
  REQUIRE( fac(0) == 1 )
with expansion:
  1 == 1

-------------------------------------------------------------------------------
Scenario: factorial function return values and exceptions
      Given: factorial function 'fac'
       When: argument > 0
       Then: fac(n) == n*fac(n-1)
-------------------------------------------------------------------------------
test_fac.cpp:14
...............................................................................

test_fac.cpp:16: PASSED:
  REQUIRE( fac(i) == i*fac(i - 1) )
with expansion:
  1 == 1

test_fac.cpp:16: PASSED:
  REQUIRE( fac(i) == i*fac(i - 1) )
with expansion:
  2 == 2

test_fac.cpp:16: PASSED:
  REQUIRE( fac(i) == i*fac(i - 1) )
with expansion:
  6 == 6

test_fac.cpp:16: PASSED:
  REQUIRE( fac(i) == i*fac(i - 1) )
with expansion:
  24 == 24

test_fac.cpp:16: PASSED:
  REQUIRE( fac(i) == i*fac(i - 1) )
with expansion:
  120 == 120

-------------------------------------------------------------------------------
Scenario: factorial function return values and exceptions
      Given: factorial function 'fac'
       When: argument < 0
       Then: exception thrown
-------------------------------------------------------------------------------
test_fac.cpp:20
...............................................................................

test_fac.cpp:21: PASSED:
  REQUIRE_THROWS_AS( fac(-1), std::domain_error )

===============================================================================
All tests passed (7 assertions in 1 test case)
~~~~

To illustrate how BDD simplifies creating and working with fixtures, considerr the following implementation of the same tests as in the section on fixtures.

~~~~cpp
#define CATCH_CONFIG_MAIN
#include <catch2/catch.hpp>
#include <stack>

int fac(int n) {
    int result = 1;
    for (int i = 2; i <= n; ++i)
        result *= i;
    return result;
}

SCENARIO( "stack test", "[stack]" ) {
    GIVEN( "stack with numbers 1 to 5" ) {
        const int max_val {5};
        std::stack<int> data;
        for (int i = 1; i <= max_val; ++i)
            data.push(i);
        WHEN( "computing sum" ) {
            int sum {0};
            while (!data.empty()) {
                sum += data.top();
                data.pop();
            }
            THEN( "sum == 5*6/2" ) {
                REQUIRE( sum == max_val*(max_val + 1)/2 );
            }
        }
        WHEN( "computing product" ) {
            int prod {1};
            while (!data.empty()) {
                prod *= data.top();
                data.pop();
            }
            THEN( "product == 5!" ) {
                REQUIRE( prod == fac(max_val) );
            }
        }
    }
}
~~~~

When the test application is run with the `-s` flag, the following output is produced.

~~~~
stack_test.exe is a Catch v2.5.0 host application.
Run with -? for options

-------------------------------------------------------------------------------
Scenario: stack test
      Given: stack with numbers 1 to 5
       When: computing sum
       Then: sum == 5*6/2
-------------------------------------------------------------------------------
stack_test.cpp:19
...............................................................................

stack_test.cpp:25: PASSED:
  REQUIRE( sum == max_val*(max_val + 1)/2 )
with expansion:
  15 == 15

-------------------------------------------------------------------------------
Scenario: stack test
      Given: stack with numbers 1 to 5
       When: computing product
       Then: product == 5!
-------------------------------------------------------------------------------
stack_test.cpp:29
...............................................................................

stack_test.cpp:35: PASSED:
  REQUIRE( prod == fac(max_val) )
with expansion:
  120 == 120

===============================================================================
All tests passed (2 assertions in 1 test case)
~~~~

The code in the `GIVEN` section of the code is executed before each `WHEN` case.  Arguably, this is a very nice style of formulating tests.
