program main

    implicit none
    integer*4, parameter :: seed = 123456789, L = 96
    integer*4 :: i, j

    integer*2 :: mat(L,L)
    integer*2 :: genrand_int2
    real*8 magne, magnetization

    character(len=100) :: gnuCmd
    

    write(*,*) "GENERATION OF A 2D SPIN SYSTEM by Marc Parcerisa"
    ! Initialize the random number generator
    call init_genrand(seed)

    ! Generate a random spin array
    do i = 1, L
        do j = 1, L
            mat(i,j) = genrand_int2()
        enddo
    enddo

    ! Write the array to a file
    call write_config(L, mat)

    ! Plot the array
    write(gnuCmd, "(a,i3, a)") 'gnuplot -e "L=',L,'" "gnu\P1-plotconfig.gnu"'
    call system(gnuCmd)

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

subroutine write_config(L, mat)
    implicit none
    integer, intent(in) :: L
    integer*2, intent(in) :: mat(L,L)

    integer i, ios
    

    open(unit=10, iostat=ios, file="dat/config.conf")
    if ( ios /= 0 ) stop "Error opening file config.conf"
    
    ! Write the whole image as an array
    do i = 1, L
        write(10,*) mat(i,:)
    enddo

    close(unit=10, iostat=ios)
    if ( ios /= 0 ) stop "Error closing file config.conf"
    
end subroutine write_config
