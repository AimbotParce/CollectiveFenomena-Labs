program main

    implicit none
    integer*4, parameter :: seed = 123456789, L = 96
    integer*4 :: i, j

    integer*2 :: mat(L,L)
    integer*2 :: genrand_int2
    real*8 magne, magnetization

    character(len=100) :: gnuCmd
    

    write(*,*) "MAGNETIZATION OF A 2D SPIN SYSTEM by Marc Parcerisa"
    ! Initialize the random number generator
    call init_genrand(seed)

    ! Generate a random spin array
    do i = 1, L
        do j = 1, L
            mat(i,j) = genrand_int2()
        enddo
    enddo

    ! Compute magnetization of spin array
    magnetization = magne(L, mat)
    write(*,"(1x,a, f5.0)") "Magnetization = ", magnetization
    write(*,*) "Per particle = ", magnetization/(L*L)

end program main


function genrand_int2() result(output)
    
    integer*2 output
    real*8 genrand_real2

    ! Generate a random whole number between -1 and 1
    if ( genrand_real2() <= 0.5d0 )then
        output = 1
    else
        output = -1
    end if

end function genrand_int2


function magne(L,mat) result(output)

    implicit none
    integer, intent(in) :: L
    integer*2, intent(in) :: mat(L,L)
    real*8 output

    integer i, j, sum

    sum = 0

    do i = 1, L
        do j = 1, L
            sum = sum + mat(i,j)
        enddo
    enddo

    output = real(sum, 8)
    
end function magne