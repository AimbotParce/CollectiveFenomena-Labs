! Montecarlo simulation.
! Use: P2-exercici-1.f90 -s <width> <height> -n <iteration_count> -t <temperature>
! [all arguments are optional]

program main

    implicit none

    real*8 energ, E
    integer*2 genrand_int2

    integer *2, allocatable, dimension(:, :) :: S
    integer, allocatable, dimension(:) :: PBCx, PBCy

    integer i, j
    integer, parameter :: seed = 123456781
    ! Watch out! Depending on the seed, the program converges at different speeds, and may even
    ! not converge at all or converge on a metastable state.
    ! I recommend the seed 123456781, which converges pretty rapidly.
    ! The seed 123456782 gives a nice example of a metastable state.
    ! And the seed 123456789 does not converge in at least 3000 iterations.

    ! User defined variables
    integer width, height, Niter
    real*8 T

    call parse_arguments(width, height, Niter, T)

    allocate(S(1:width,1:height))
    allocate(PBCx(0:width+1))
    allocate(PBCy(0:height+1))

    PBCx(0) = width
    PBCx(width+1) = 1
    PBCy(0) = height
    PBCy(height+1) = 1
    do i = 1, width
        PBCx(i) = i
    end do
    do i = 1, height
        PBCy(i) = i
    end do



    write(*, *) "Testing energy function: Generating a skewed system with S = +1"
    do i = 1, width
        do j = 1, height
            S(i,j) = 1
        end do
    end do

    E = energ(S, width, height, PBCx, PBCy)

    write(*, *) "Energy of the system: ", E, " Expected: ", -2*width*height
    if ( E == -2 * width * height) then
        write(*, *) "Energy function works!"
    else
        write(*, *) "Energy function does not work!"
    end if



    write(*, *) "Now generating a random system with S = +1 or -1"
    ! Generate a random spin array
    call init_genrand(seed)
    do i = 1, width
        do j = 1, height
            S(i,j) = genrand_int2()
        enddo
    enddo

    ! Calculate the energy of the system
    E = energ(S, width, height, PBCx, PBCy)
    write(*, *) "Energy:", E

    write(*, *) "Running the Metropolis algorithm"
    call metropolis(S, width, height, PBCx, PBCy, E, T, Niter)

    write(*, *) "Generating plot of the convergence"
    call system("gnuplot gnu/plot_convergence.gnu")


end program main


subroutine parse_arguments(width, height, Niter, T)

    implicit none
    integer, intent(out) :: width, height, Niter
    real*8, intent(out) :: T
    
    integer :: num_args, i
    character(len=12), dimension(:), allocatable :: args
    
    num_args = command_argument_count()
    allocate(args(num_args))
    do i = 1, num_args
        call get_command_argument(i,args(i))
    end do

    ! Set default values
    width = 48
    height = 48
    Niter = 3000
    T = 1.3d0

    i = 1
    do while ( i <= num_args )
        ! Check if the argument starts with a dash
        if (args(i)(1:1) == '-') then
            ! Check if the argument is -s
            if (args(i)(2:2) == 's') then
                read(args(i+1), "(i3)") width
                read(args(i+2), "(i3)") height
                i = i + 2 ! Skip the next two arguments
            ! Check if the argument is -t
            else if (args(i)(2:2) == 't') then
                read(args(i+1), "(f8.1)") T
                i = i + 1 ! Skip the next argument
            ! Check if the argument is -n
            else if (args(i)(2:2) == 'n') then
                read(args(i+1), "(i5)") Niter
                i = i + 1 ! Skip the next argument
            else
                write(*, *) "Unknown argument ", args(i)
            end if
        end if

        i = i+1
    end do

end subroutine parse_arguments

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


function energ(mat, width, height, PBCx, PBCy) result(energy)

    implicit none
    integer, intent(in) :: width, height, PBCx(0: width+1), PBCy(0: height+1)
    integer*2, intent(in) :: mat(1:width, 1:height)
    real*8 :: energy

    integer i, j, sum

    sum = 0

    do i = 1, width
        do j = 1, height
            sum = sum - mat(i,j)*mat(PBCx(i+1), j) - mat(i,j)*mat(i, PBCy(j+1))
        enddo
    enddo

    energy = real(sum, 8)
    
end function energ


subroutine monte_carlo_step(mat, width, height, PBCx, PBCy, energy, temp, newEnergy)

    implicit none
    integer, intent(in) :: width, height, PBCx(0: width+1), PBCy(0: height+1)
    integer*2, intent(inout) :: mat(1:width, 1:height)
    real*8, intent(in) :: energy, temp
    real*8, intent(out) :: newEnergy
    real*8 deltaE, genrand_real2

    integer :: randPoint, i, j, k

    newEnergy = energy
    do k = 1, width*height

        ! Generate a random number between 1 and width*height
        randPoint = int( width * height * genrand_real2())
        ! Translate it to a matrix index
        i = mod(randPoint, width) +1
        j = int(randPoint / width) + 1


        ! Calculate the energy of the system if the spin at (i,j) is flipped
        deltaE = 2 * mat(i,j) * (mat(PBCx(i-1), j) + mat(PBCx(i+1), j) + mat(i, PBCy(j-1)) + mat(i, PBCy(j+1)))

        if (deltaE <= 0) then
            mat(i,j) = -mat(i,j)
            newEnergy = newEnergy + deltaE
        else
            if (genrand_real2() <= exp(-deltaE/temp)) then
                mat(i,j) = -mat(i,j)
                newEnergy = newEnergy + deltaE
            end if
        end if

    end do

    
end subroutine monte_carlo_step

subroutine metropolis(mat, width, height, PBCx, PBCy, energy, temp, Niter)
    
    implicit none
    integer, intent(in) :: width, height, PBCx(0: width+1), PBCy(0: height+1), Niter
    integer*2, intent(inout) :: mat(1:width, 1:height)
    real*8, intent(inout) :: energy
    real*8, intent(in) :: temp
    real*8 newEnergy, energ

    integer magne, mag

    integer i, ios

    ! Open the file
    open(unit=10, file="dat/P2-montecarlo-out.dat", iostat=ios)
    if ( ios /= 0 ) stop "Error opening file P2-montecarlo-out.txt"

    write(10, *) "# Monte Carlo simulation of a 2D Ising model"
    write(10, "(a2, a12, 3a14)") "# ", "Iter", "Energy", "Energ Check", "Magnetization"
    do i = 1, Niter
        call monte_carlo_step(mat, width, height, PBCx, PBCy, energy, temp, newEnergy)
        energy = energ(mat, width, height, PBCx, PBCy)
        mag = magne(mat, width, height)
        write(10, "(i14.6, 2f14.1, i14)") i, newEnergy, energy, mag
    end do

    write(*, *) "Data written to dat/P2-montecarlo-out.dat"
    write(*, *) "Final energy: ", energy
    write(*, *) "Final magnetization: ", mag

    ! Close the file
    close(10)

end subroutine metropolis


function magne(mat, width, height) result(sum)

    implicit none
    integer, intent(in) :: width, height
    integer*2, intent(in) :: mat(width,height)

    integer i, j, sum

    sum = 0

    do i = 1, width
        do j = 1, height
            sum = sum + mat(i,j)
        enddo
    enddo
    
end function magne