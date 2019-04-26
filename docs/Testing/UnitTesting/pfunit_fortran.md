# pFUnit additional features

[pFUnit](https://sourceforge.net/projects/pfunit/) is a very rich framework for developing unit tests.  The screencast presented some of its features, but it is useful to know some more.

### Code to test

Consider the following module defined in `fac_mod.f90` under test.

~~~~fortran
module fac_mod
    use, intrinsic :: iso_fortran_env, only : i32 => INT32
    implicit none

    public :: fac

contains

    integer(kind=i32) function fac(n)
        implicit none
        integer(kind=i32), intent(in) :: n
        integer(kind=i32) :: r = 1_i32
        integer :: i
        do i = 2, n
            r = r*i
        end do
        fac = r
    end function fac

end module fac_mod
~~~~

### Unit tests

Unit tests for this module reside in a file with extension `.pf`, e.g., `fac_tests.pf`, and consist of Fortran code with annotations and macros that are preprocessed by pFUnit.

The test below verifies that the factorial of 0 is 1.

~~~fortran
@test
subroutine test_fac_0()
    use fac_mod
    use pfunit_mod
    implicit none
            
    @assertEqual(1, fac(0))
end subroutine test_fac_0
~~~

A second test in the same file will test whether the factorial of 5 is 120, i.e.,

~~~~fortran
@test
subroutine test_fac_5()
    use fac_mod
    use pfunit_mod
    implicit none
            
    @assertEqual(120, fac(5))
end subroutine test_fac_5
~~~~

### Scaffolding

The actual testing program is provided by the pFUnit framework.  To ensure that the tests will be included, an include file `testSuites.inc` is created in which you specify the test suite(s) to take into account.

~~~~fortran
ADD_TEST_SUITE(fac_tests_suite)
~~~~

The `.pf` files has to be preprocessed first, i.e.,

~~~~
tests: tests.exe

ifneq ($(BASEMK_INCLUDED),YES)
include $(PFUNIT)/include/base.mk
endif

FC = gfortran
FFLAGS += -g -I$(PFUNIT)/mod -I.
LIBS = $(PFUNIT)/lib/libpfunit$(LIB_EXT)

SRCS = $(wildcard *.pf)
OBJS = $(SRCS:.pf=.o)
APPL_OBJS = fac_mod.o

tests.exe: $(APPL_OBJS) $(OBJS)
	$(FC) $(FFLAGS) $(FPPFLAGS) -o $@  \
        $(PFUNIT)/include/driver.F90 $(OBJS) $(APPL_OBJS) $(LIBS)

testSuites.inc: $(SRCS)

%.F90: %.pf
	$(PFUNIT)/bin/pFUnitParser.py $< $@

fac_mod.o: fac_mod.f90
	$(FC) $(FFLAGS) -c $<

%.o: %.F90
	$(FC) -c $(FFLAGS) $(FPPFLAGS) $<

clean:
	$(RM) *.exe
~~~~

The `.pf` files will be preprocessed by `pFUnitParser.py` into `.F90` files.  Note the `.F90` extension which ensure that the Fortran preprocessor will be called prior to compilation.

The executable is built using the provided `driver.F90 that will use the `testSuites.inc` file to determine the test suites to run.

To build the tests, the `PFUNIT` environment variable should be set to the path where pFUnit is installed, and make can be run, i.e.,

~~~~bash
$ export PFUNIT=/path/to/pfunit
$ make
~~~~

### Running tests

When the executable is successfully built, you can run the tests by executing it.

~~~~bash
$ ./tests.exe
~~~~

The test for the factorial of 5 will fail since the implementation contains a bug.


## More assertions

Besides the `@assertAqual` macro illustrated above, there is a long list of test macros available, e.g.,

  * `@assertTrue`/`@assertFalse`: test a Boolean condition;
  * `@assertLessThan`/.../`@assertGreaterThanOrEqual`: test numerical inequalities;
  * `@assertAny`/`@assertAll`: test values of logical arrays;
  * `@assertSameShape`: test shape of (multi-dimensional) arrays;
  * `@assertIsNaN`/`@assertIsFinite`: test whether a floating point value is NaN or infinite;
  * `@assertIsAssociated`: test whether a pointer is associated with a target;
  * `@assertFailure`: test whether an inappropriate code path is taken.

There are negations for some assertions, e.g., `@assertNotEqual` and `@assertNotAssociated`.

The `@assertEqual` macro is overloaded, it can test for equality of integer, real and complex numbers, logical values and strings.  For assertions on real values, an optional argument can and should be supplied, the tolerance for comparison.  At the risk of repeating ourselves, you should _never_ test for exact equality of real numbers.

Although almost all the test macros could be expressed by the generic `@assertTrue`, e.g., `@assertNotEqual(a, b)` is logically equivalent to `@assertTrue(a /= b)` it is good practice to use the most appropriate macro to formulate your test.  Doing so will make your intent clear, and may yield failure messages that are more informative.


## Setup and tear down

In order to ensure that each test runs in a well-prepared environment, you can use fixtures.  These are artefacts that are set up before a test runs, and that are teared down (cleaned up) after the test finishes.  A pFUnit definition file can define these setup and teardown subroutine by using the `@before` and `@after` annotations respectively.  The setup and tear down procedures take no arguments.

The purpose of the setup procedure (annotated with `@before`) is to, well, set up the stage for testing.  It may for instance initialise a data structure under test, or initialise a network connection.

The tear down procedure (annotated with `@after`) ensures that all resources acquired by the setup procedure are released. So it may deallocate the memory of the data structure, or close the connection.

Although this approach is straightforward, it is not ideal since the scope of the fixture objects would have to be global or defined in a separate module.  Hence it is more elegant to create a new class derived from pFUnit's `TestCase` base class.  In the new class, the base class methods `setUp` and `tearDown` can be overridden to initialise and clean up the fixtures.  The tests are also implemented as methods of the new class.

Suppose that we want to test procedures that perform computations on arrays, we could create an array as a fixture.  It would be a field of a user defined type derived from `TestCase`, i.e.,

~~~~fortran
module tests
    use pfunit_mod
    implicit none

    @testcase
    type, extends(TestCase) :: tests_type
        integer :: n = 5
        integer, allocatable, dimension(:) :: data_array
    contains
        procedure :: setUp
        procedure :: tearDown
    end type tests_type
contains
    ...
end module tests
~~~~

The definition of the `setUp` and `tearDown` procedures are contained in the module.

~~~~fortran
subroutine setUp(this)
    implicit none
    class(tests_type), intent(inout) :: this
    integer :: i
    allocate(this%data_array(this%n))
    do i = 1, this%n
        this%data_array(i) = i
    end do
end subroutine setUp
~~~~

~~~~fortran
subroutine tearDown(this)
     implicit none
     class(tests_type), intent(inout) :: this
     deallocate(this%data_array)
end subroutine tearDown
~~~~

For the `setUp` and `tearDown` methods, no annotation is required since they override `TestCase` methods.

The tests themselves are also contained in the module as methods of the `tests_type` class, e.g.,

~~~~fortran
@test
subroutine test_sum(this)
    use pfunit_mod
    implicit none
    class(tests_type), intent(inout) :: this
    integer :: i, total
    total = 0
    do i = 1, size(this%data_array)
        total = total + this%data_array(i)
    end do
    @assertEqual(15, total)
end subroutine test_sum
~~~~

In the test subroutine, you need to use the `pfunit_mod` module since you will be using assertions such as `@assertEqual`.

Note that many unit testing frameworks allow more flexibility.  They can have setup and tear down functions that are called before the first test in a suite starts, and after the last test in a suite ends.
