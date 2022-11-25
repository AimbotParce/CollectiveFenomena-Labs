program main

    use histogram_mod
    implicit none
    integer*4, parameter :: seed = 123456789, n = 40000
    integer :: i
    real*8 :: rand(n)
    real*8 :: genrand_real2, sum, sum2

    write(*,*) "CHECKING RANDOM NUMBER GENERATOR MT19937 by Marc Parcerisa"


    call init_genrand(seed)

    sum = 0.0
    sum2 = 0.0
    

    do i = 1, n, 1
        rand(i) = genrand_real2()
        ! write(*,*) i, rand(i) ! uncomment to see the random numbers
        sum = sum + rand(i)
        sum2 = sum2 + rand(i)**2
    end do

    write(*,*) "mean = ", sum/n
    write(*,*) "variance = ", sum2/n - (sum/n)**2
    write(*,*) "standard deviation = ", dsqrt(sum2/n - (sum/n)**2)


    write(*,*) "Computing historgam..."
    call histogram(n, rand, 0.d0, 1.d0, 10, "MT19937_histogram")


end program main
