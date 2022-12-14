! Run the metropolis algorithm for different temperatures

program main

    implicit none
    integer :: width, height, Niter
    integer :: seeds(5) = (/ 10300, 1002, 14303, 12041, 12356 /)
    character(len=20) :: filenames(size(seeds, dim=1)), fmt
    character(len=20*size(seeds)) :: allfilenames
    character(len=150) :: command
    real*8 :: T

    integer i

    call parse_arguments(width, height, Niter, T)

    ! Compile the P3-exercici-1.f90 file
    call system("gfortran -O3 .\mt19937ar.o .\P3-exercici-1.f90 -o .\execs\P3-exercici-1.exe")

    do i = 1, size(seeds, dim=1)
        write(filenames(i), "(A, i0.5, A)") "P3-S-", seeds(i), ".dat"

        write(command, "(a, i2, a, i2, a, i5, a, f5.3, 3a, i5)") ".\execs\P3-exercici-1.exe -l ", width, " ", height, &
                        " -n ", Niter, " -t ", T, " -o ", filenames(i), " -s ", seeds(i)
        call system(command)
    end do


    write(fmt, "(a, i5, a)") "(", size(seeds), "a)"
    write(allfilenames, fmt) filenames
    call system('gnuplot -e "files='//"'"//allfilenames//"'"//'; name='//"'"//"seed"//"'"//'" ./gnu/plot_multidat.gnu')

    

end program main



subroutine parse_arguments(width, height, Niter, T)

    implicit none
    integer, intent(out) :: width, height, Niter
    real*8, intent(out) :: T
    
    integer :: num_args, i
    character(len=30), dimension(:), allocatable :: args
    
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
            if (args(i)(2:2) == 'l') then
                read(args(i+1), "(i3)") width
                read(args(i+2), "(i3)") height
                i = i + 2 ! Skip the next two arguments
            ! Check if the argument is -n
            else if (args(i)(2:2) == 'n') then
                read(args(i+1), "(i5)") Niter
                i = i + 1 ! Skip the next argument
            ! Check if the argument is -t
            else if (args(i)(2:2) == 't') then
                read(args(i+1), "(f8.1)") T
                i = i + 1 ! Skip the next argument
            else
                write(*, *) "Unknown argument ", args(i)
            end if
        end if

        i = i+1
    end do


end subroutine parse_arguments