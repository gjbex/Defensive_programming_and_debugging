# CUnit testing for C

[CUnit](http://cunit.sourceforge.net/) is a very rich framework for developing unit tests for C functions..


## The basics

The function under test computes the factorial of a given integer, i.e.,

~~~~c
int fac(int n) {
    int f = 1;
    while (n > 1)
        f *= --n;
    return f;
}
~~~~

### Defining the tests

Unit tests are functions that are registered as such, and executed by the framework.  The signature of these functions is `void f(void)`, and their body contains at least one CUnit assertions, e.g.,

~~~~c
#include <CUnit/CUnit.h>

void test_fac_0(void) {
    CU_ASSERT_EQUAL(fac(0), 1);
}
~~~~

This test would verify that the computed result, i.e., `fac(0)`, the factorial of 0, is equal to the expected result 1.  Typically, several tests would be defined to cover the paths through the `fac` function, e.g.,

~~~~c
void test_fac_3(void) {
    CU_ASSERT_EQUAL(fac(3), 6);
}
~~~~


### Setting up the tests

When the tests are defined, a test application can be created.  The first and last step is to initialise and clean up the test registry, i.e.,

~~~~c
#include <err.h>
#include <CUnit/Basic.h>

int main(void) {
    if (CU_initialize_registry() != CUE_SUCCESS)
        errx(EXIT_FAILURE, "can't initialize test registry");
    ...
    CU_cleanup_registry();
    return 0;
}
~~~~

Unit tests are grouped into suites, so you need to add at least one suite to the registry once that has been initialized.  A suite has a unique name, `fac` in the code fragment below.  For now, don't worry about the second and third argument of the `CU_add_suite` function, a later section will discuss that.

~~~~c
    ...
    CU_pSuite facSuite = CU_add_suite("fac", NULL, NULL);
    if (CU_get_error() != CUE_SUCCESS)
        errx(EXIT_FAILURE, "%s", CU_get_error_msg());
    ...
~~~~

Now the unit test functions can be added to the test suite, i.e.,

~~~~c
    ...
    CU_add_test(facSuite, "fac(0)", test_fac_0);
    CU_add_test(facSuite, "fac(3)", test_fac_3);
    ...
~~~~

The last step is to ensure that the tests are executed when the application runs.  The simplest way to do this is by using the `CU_basic_run_tests` function.  This will execute all the tests in each suite that was added to the registry.  This is the complete definition of the `main` function.

~~~~c
int main(void) {
    if (CU_initialize_registry() != CUE_SUCCESS)
        errx(EXIT_FAILURE, "can't initialize test registry");
    CU_pSuite facSuite = CU_add_suite("fac", NULL, NULL);
    if (CU_get_error() != CUE_SUCCESS)
        errx(EXIT_FAILURE, "%s", CU_get_error_msg());
    CU_add_test(facSuite, "fac(0)", test_fac_0);
    CU_add_test(facSuite, "fac(3)", test_fac_3);
    CU_basic_run_tests();
    CU_cleanup_registry();
    return 0;
}
~~~~

### Building and running

To build the test application, remember to link with the `-lcunit` flag and other flags or libraries required on your system (use `pkg-config` to determine those).

When you run the test application, you will get a report like the one below

~~~~
    CUnit - A unit testing framework for C - Version 2.1-3
    http://cunit.sourceforge.net/


Suite fac, Test fac(3) had failures:
    1. tests.c:17  - CU_ASSERT_EQUAL(fac(3),6)

Run Summary:    Type  Total    Ran Passed Failed Inactive
              suites      1      1    n/a      0        0
               tests      2      2      1      1        0
             asserts      2      2      1      1      n/a

Elapsed time =    0.000 seconds
~~~~

There is one suite in the registry, and that was run, it had two tests, both were run, one passed, the other failed.  In total, there wre two assertions, both ran, one passed, the other failed.

The test that failed was `fac(3)`, clearly, the `fac` function requires some work.


## More assertions

Besides the `CU_ASSERT_EQUAL` macro illustrated above, there is a long list of test macros available, e.g.,

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

It is of course unfortunate that global variables have to be used as fixtures, although at least their scope is limited to the file since they were declared static.  The initialisation and cleanup function can now be assigned to a test suite by passing them as arguments to `CU_`.

~~~~c
    ...
    CU_pSuite suite = CU_add_suite("array", initialize, cleanup);
    ...
~~~~

Note that many unit testing frameworks allow more flexibility.  They can have setup and tear down functions that are called before and after each individual test.
