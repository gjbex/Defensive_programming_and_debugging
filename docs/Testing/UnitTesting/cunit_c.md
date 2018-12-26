# CUnit additional features

[CUnit](http://cunit.sourceforge.net/) is a very rich framework for developing unit tests.  The screencast presented some of its features, but it is useful to know some more.


## More assertions

Besides the `CU_ASSERT_EQUAL` macro illustrated in the screencast, there is a long list of test macros available, e.g.,
  * `CU_ASSERT_TRUE`/`CU_ASSERT_FALSE`: test Boolean condition;
  * `CU_ASSERT_DOUBLE_EQUAL`: test floating point equality up to a given tolerance;
  * `CU_ASSERT_NSTRING_EQUAL`: test string equality;
  * `CU_ASSERT_PTR_EQUAL`: test whether addresses are equal;
  * `CU_PASS`/`CU_FAIL`: test whether code paths are taken.

For each `EQUAL` macro, there is a corresponding `NOT_EQUAL` version that asserts inequality.

At the risk of repeating ourselves, _never_ use `CU_ASSERT_EQUAL` to compare floating point values!

Although all the test macros could be expressed by the generic `CU_ASSERT`, e.g., `CU_ASSERT_EQUAL(a, b)` is logically equivalent to `CU_ASSERT(a == b)` it is good practice to use the most appropriate macro to formulate your test.  Doing so will make your intent clear, and may yield failure messages that are more informative.


## Initialise and clean up

In most unit testing frameworks, this is called setup and tear down.  In the context of CUnit, the initialisation and cleanup function are provided to a test suite, and they are run before the first test starts, and the last test in that suite completes, respectively.

The purpose of the initialisation function is to set up the stage for testing.  It may for instance initialise a data structure under test, or initialise a connection to a database.  The concept is often called a "fixture", since it ensures a consistent state when the tests are run.

The clean up function ensures that all resources acquired by the initialisation function are released. So it may free the memory allocated for the data structure, or close the connection to the database.

The initialisation and clean up functions take no arguments and are expected to return 0 upon successful completion.  They are passed as the optional second and third argument of the `CU_add_suite` function.

Suppose that we want to test functions that perform computations on arrays, we could create an array as a fixture.  The initialisation and cleanup function could be implemented as follows.

~~~~c
static const int size = 5;
static int *array;

int initialize() {
    array = (int *) malloc(size*sizeof(int));
    if (!array)
        return 1;
    for (int i = 0; i < size; i++)
        array[i] = i + 1;
    return 0;
}

int cleanup() {
    free(array);
    return 0;
}
~~~~

The tests would be defined below the declaration of the static variables so that they can access them.

~~~~c
void test_sum() {
    int sum = 0;
    for (int i = 0; i < size; i++)
        sum += array[i];
    CU_ASSERT_EQUAL(sum, 15);
}
~~~~

It is of course unfortunate that global variables have to be used as fixtures.  The initialisation and cleanup function can now be assigned to a test suite by passing them as arguments to `CU_`.

~~~~c
    ...
    CU_pSuite suite = CU_add_suite("array", initialize, cleanup);
    ...
~~~~

Note that many unit testing frameworks allow more flexibility.  They can have setup and tear down functions that are called before and after each individual test.


## C++

Although you could use CUnit for testing C++ code, there are better alternatives.  A very nice framework is [Catch2](https://github.com/catchorg/Catch2).  You can express tests quite naturally using Catch2 so that they resemble a narrative.

The framework takes a further step along that path by offering support for [Behaviour Driven Development](https://en.wikipedia.org/wiki/Behavior-driven_development) (BDD).
