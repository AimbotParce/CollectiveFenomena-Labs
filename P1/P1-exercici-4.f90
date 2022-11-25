program main

    use histogram_mod

    implicit none
    integer dice
    integer, parameter :: n = 6
    real*8 :: probs(n) = (/0.1, 0.2, 0.3, 0.2, 0.1, 0.1/)

    integer, parameter :: nrolls = 1000000
    integer rand(nrolls), j
    
    call init_genrand(46235235)


    write(*,*) "Rolling the dice..."
    
    do j = 1, nrolls, 1
        rand(j) = dice(n, probs)
    end do
    
    call histogram(nrolls, real(rand, 8), 0.5d0, real(n, 8)+0.5d0, 6, "Dice rolls")

end program main


function dice(n, probs) result(output)
    ! Generate a random integer number between 1 and n, with probabilities probs
    implicit none
    integer, intent(in) :: n
    real*8, intent(in) :: probs(n)
    integer :: output
    real*8 :: rand
    real*8 :: genrand_real2

    integer i

    rand = genrand_real2()

    do i = 1, n, 1
        if (rand < sum(probs(1:i))) then
            output = i
            return
        end if
    end do 


    
end function dice