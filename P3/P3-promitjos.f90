! Càlculs dels valors promig de l'energia, l'energia quadràtica, la magnetització, el seu valor absolut i el seu quadrat
! per partícula

program main

    implicit none

    character(len=100) :: fileName

    integer ios

    call parse_arguments(fileName)

    open(unit=10, file=fileName, iostat=ios)
    if ( ios /= 0 ) stop "Error opening file"

    call read_header()
    



end program main


subroutine parse_arguments(fileName)

    implicit none
    character(len=100), intent(out) :: fileName
    
    integer :: num_args, i
    character(len=100), dimension(:), allocatable :: args
    

    num_args = command_argument_count()
    allocate(args(num_args))
    do i = 1, num_args
        call get_command_argument(i,args(i))
    end do

    ! Set default values
    fileName = "UNDEFINED"

    i = 1
    do while ( i <= num_args )
        if (args(i)(1:1) == '-') then
            if (args(i)(2:2) == 'i') then ! Input file
                fileName = args(i+1)
                i = i + 1
            else
                write(*, *) "Unknown argument ", args(i)
            end if
        end if
        i = i+1
    end do

end subroutine parse_arguments
