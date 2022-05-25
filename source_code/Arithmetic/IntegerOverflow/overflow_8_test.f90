program trapv_8_test
    use, intrinsic :: iso_fortran_env, only : int8
    integer(kind=int8) :: i, n, j

    i = 125
    do n = 1, 5
        j = i + n
        print *, j
    end do

end program trapv_8_test
