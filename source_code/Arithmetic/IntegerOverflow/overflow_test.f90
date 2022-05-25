program trapv_test
    use, intrinsic :: iso_fortran_env, only : int32
    integer(kind=int32) :: i, n, j

    i = 2147483640
    do n = 1, 10
        j = i + n
        print *, j
    end do

end program trapv_test
