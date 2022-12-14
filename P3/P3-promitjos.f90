! Càlculs dels valors promig de l'energia, l'energia quadràtica, la magnetització, el seu valor absolut i el seu quadrat
! per partícula

program main

    implicit none

    character(len=100) :: fileName

    integer width, height, iterations
    real*8 temperature

    integer ios, i, j

    call parse_arguments(fileName)

    open(unit=10, file=fileName, iostat=ios)
    if ( ios /= 0 ) stop "Error opening file"

    call read_header(10, width, height, iterations, temperature)

    write(*,*) "width = ", width
    write(*,*) "height = ", height
    write(*,*) "iterations = ", iterations
    write(*,*) "temperature = ", temperature

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

subroutine read_header(fileUnit, width, height, iterations, temperature)

    implicit none
    integer, intent(in) :: fileUnit
    integer, intent(out) :: width, height, iterations
    real*8, intent(out) :: temperature

    character(len=300) :: line
    character(len=500) :: stringdata
    character(len=40), dimension(:, :), allocatable :: tokens
    integer ios, i, j, num_tokens, last, pointr, find
    logical :: inDict, searching

    ! Read lines one by one until we find '{' or '}', join them in a single string
    inDict = .false.
    stringdata = ''
    searching = .true.
    num_tokens = 0 ! I'll use this to count how many lines I have to advance
    do while ( searching )
        read(fileUnit, '(a)', iostat=ios) line
        if (ios /= 0) stop "Error reading file"

        ! Eliminate blank spaces at the beginning of the line
        write(line,"(a)") adjustl(line)

        ! Check if we are inside the metadata
        if ( line(1:1) /= '#' ) then
            searching = .false.
        else
            num_tokens = num_tokens + 1
            do i = 1, len_trim(line)
                if ( line(i:i) == '}' ) inDict = .false.
                if ( inDict .and. line(i:i) /= ' ' ) write(stringdata, "(2a)") trim(stringdata), line(i:i)
                if ( line(i:i) == '{' ) inDict = .true.
            end do
        end if
    end do
    
    ! Rewind and advance back to the beginning of the data
    rewind (fileUnit)
    do i = 1, num_tokens
        read(fileUnit, '(a)', iostat=ios)
        if (ios /= 0) stop "Error reading file"
    end do


    ! Compute the number of tokens
    num_tokens = 0
    do i = 1, len_trim(line)
        if (line(i:i) == ':') num_tokens = num_tokens + 1
    end do

    allocate(tokens(num_tokens, 2))

    ! Read the tokens
    last = 1
    pointr = 1
    write(*,*) stringdata, len_trim(stringdata)
    do i = 1, len_trim(stringdata)
        write(*,*) "TEST", i
        if (stringdata(i:i) == ':') then
            tokens(pointr, 1) = adjustl(stringdata(last:i-1))
            last = i+1
        else if (stringdata(i:i) == ',') then
            tokens(pointr, 2) = adjustl(stringdata(last:i-1))
            last = i+1
            pointr = pointr + 1
        end if
    end do


    ! Read the values
    read(tokens(find(num_tokens, tokens,"width"), 2), "(i40)") width
    read(tokens(find(num_tokens, tokens,"height"), 2), "(i40)") height
    read(tokens(find(num_tokens, tokens,"iterations"), 2), "(i40)") iterations
    read(tokens(find(num_tokens, tokens,"temperature"), 2), "(f5.3)") temperature
    
end subroutine read_header

function find(n, tokens, key) result(index)

    implicit none
    integer, intent(in) :: n
    character(len=40), intent(in) :: tokens(n, 2)
    character(len=*), intent(in) :: key

    integer :: index

    integer i

    do i = 1, n
        if ( trim(tokens(i, 1)) == trim(key) ) then
            index = i
            return
        end if
    end do

    index = -1
    
end function find
