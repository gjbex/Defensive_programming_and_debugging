# pFUnit additional features

[pFUnit](https://sourceforge.net/projects/pfunit/) is a very rich framework for developing unit tests.  The screencast presented some of its features, but it is useful to know some more.


## More assertions

Besides the `@assertAqual` macro illustrated in the screencast, there is a long list of test macros available, e.g.,
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
