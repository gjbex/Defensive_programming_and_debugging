# Rosetta Stone for programming languages

This MOOC doesn't concentrate on a single programming language, but targets C, C++ and Fortran programmers. The terminology for similar concepts in those programming languages is unfortunately somewhat different, so this section tries to be a Rosetta Stone for this terminology.


## functions

In Fortran, we distinguish between functions and subroutines, which are collectively called procedures. Functions have a return value, while subroutines rely on side effects by modifying the arguments passed to the subroutine.

The following code fragment defines a function:

~~~~fortran
FUNCTION maximum(array)
    IMPLICIT none
    REAL, DIMENSION(:), INTENT(IN) :: array
    INTEGER :: i
    maximum = array(1)
    DO i = 2, SIZE(array)
        IF (maximum < array(i)) &
            maximum = array(i)
    END DO
END FUNCTION maximum
~~~~

The following subroutine would have similar functionality:

~~~~fortran
SUBROUTINE maximum(array, maxi)
    IMPLICIT none
    REAL, DIMENSION(:), INTENT(IN) :: array
    REAL, INTENT(OUT) :: maxi
    INTEGER :: i
    maxi = array(1)
    DO i = 2, SIZE(array)
        IF (maximum < array(i)) &
            maximum = array(i)
    END DO
END SUBROUTINE maximum
~~~~

Note that you should use Fortran's intrinsic function `MAX`, rather than roll your own.

C and C++ only have functions, although you could view a function with return type `void` as the equivalent of a Fortran subroutine.  A difference in terminology is that the values passed to a function in C and C++ are often referred to as parameters, rather than arguments.


## User-defined data type

In Fortran, we call this a derived data type, and the data fields are components.

~~~~fortran
TYPE, PUBLIC :: stats_type
    REAL :: sum = 0.0_f8
    INTEGER :: n = 0_i8
END TYPE stats_type
~~~~

In the code fragment above, `stats_type` is the name of the derived data type, while `sum` and `n` are its two components.

In C, there are multiple user defined types, but the one of interest here is the `struct`, which is rougly equivalent to the Fortran derived data type. Its data fields are called members.

~~~~c
struct {
    double sum;
    int n;
} stats_type;
~~~~

So here `struct stats_type` is the name of the C structure, and it has `sum` and `n` as members.

For C++, the difference would be that the name of the structure is simply `stats_type`, so the `struct` keyword isn't required.
