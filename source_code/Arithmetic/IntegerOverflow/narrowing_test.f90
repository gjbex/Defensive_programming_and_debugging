program narrowing_test
    use, intrinsic :: iso_fortran_env, only : int8
    implicit none
    integer(kind=int8) :: i, j
    integer :: n

    i = 126
    do n = 1, 3
        j = i + n*256
        print *, j
    end do

end program narrowing_test
