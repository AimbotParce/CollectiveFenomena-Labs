! Run the metropolis algorithm for a given temperature (given as an argument)
! All other parameters are read from dat/MC2.dat (This means that temperature-related parameters will be ignored)
! This is done to allow for parallelization of the temperature loop


program main

    implicit none
    
    integer :: seedCount, originalSeed, Niter, skipIter, meanEvery
    character(len=30) :: folderName
    namelist /input/ seedCount, originalSeed, Niter, skipIter, meanEvery, folderName
                     
    real*8 energ, E
    integer*2 genrand_int2
    real*8 timeStart, timeEnd, globalTimeStart, globalTimeEnd, temperature
    character(len=30) :: fileName
    integer *2, allocatable, dimension(:, :) :: S
    integer, allocatable, dimension(:) :: PBCx, PBCy

    integer i, j, k, seed, ios
    character(len=10) :: seedStr, tempStr, heightStr, widthStr ! Used to generate file names

    ! Read the input file
    open(unit=10, file="dat/MC2.dat", iostat=ios)
    if ( ios /= 0 ) stop "Error opening file dat/MC2.dat"
    read(10, input)
    close(10)

    ! Parse the arguments (temperature, height, width)
    call parse_arguments(temperature, height, width)


    ! Check if the folder exists, if not, create it
    ! call system("mkdir dat\"//trim(adjustl(folderName)))
    ! We'll suppose that python already created the folder

    allocate(S(1:width, 1:height), PBCx(0: width+1), PBCy(0: height+1))
    
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


    write(*,*)
    write(*, *) "METROPOLIS ALGORITHM by Marc Parcerisa" 
    write(*,*)

    call cpu_time(globalTimeStart)


    ! Generate a string with the temperature to be used in the file name
    write(tempStr, "(f10.4)") temperature
    write(heightStr, "(i10)") height
    write(widthStr, "(i10)") width
    
    write(*, *) "-------------------------------------"
    write(*, *) "Temperature: ", temperature
    write(*, *) "Original seed: ", originalSeed
    write(*, *) "Number of seeds: ", seedCount
    write(*, *) "Number of iterations: ", Niter
    write(*, *) "Height: ", height
    write(*, *) "Width: ", width
    write(*, *) "Folder name: ", trim(adjustl(folderName))
    write(*, *) "-------------------------------------"
    
    write(*, *) "Runing metropolis algorithm over all the seeds..."
    write(*, *) "-------------------------------------"

    do seed = originalSeed, originalSeed + seedCount - 1

        call cpu_time(timeStart)

        write(seedStr, "(i10)") seed
        fileName = trim(adjustl(folderName))//"/T"//trim(adjustl(tempStr))//"_H"//trim(adjustl(heightStr))// \&
                 & "_W"//trim(adjustl(widthStr))//"_S"//trim(adjustl(seedStr))//".dat"
                 
        open(unit=10, file="dat/"//trim(adjustl(folderName))//"/"//fileName, iostat=ios)
        if ( ios /= 0 ) stop "Error opening file dat/"//trim(adjustl(folderName))//"/"//fileName

        ! Write information both on the header of the file, and on the terminal
        write(10, *) "# temperature = ", temperature
        write(10, *) "# seed = ", seed
        write(10, *) "# Niter = ", Niter
        write(10, *) "# skipIter = ", skipIter
        write(10, *) "# height = ", height
        write(10, *) "# width = ", width
        write(10, *) "#"

        write(*, *) "# Seed: ", seed
        write(*, *) "# File name: ", fileName
        
        ! Generate a random spin array
        call init_genrand(seed)
        do i = 1, width
        do j = 1, height
            S(i,j) = genrand_int2()
        enddo
        enddo

        call metropolis(S, width, height, PBCx, PBCy, E, temperature, Niter, 10)

        close(10)

        call cpu_time(timeEnd)
        write(*, "(a, f10.4, a)") "     Done! Time elapsed: ", timeEnd - timeStart, " seconds"
        write(*, *) "-------------------------------------"

    end do
    call cpu_time(globalTimeEnd)
    write(*, *) "-------------------------------------"
    write(*, *) "Program finished!"
    write(*, "(a, f10.4, a)") "Total time elapsed: ", globalTimeEnd - globalTimeStart, " seconds"
    write(*, *) "-------------------------------------"
end program main

subroutine parse_arguments(temperature, height, width)

    implicit none
    real*8, intent(out) :: temperature
    integer, intent(out) :: height, width
    
    integer :: num_args, i
    character(len=100), dimension(:), allocatable :: args
    

    num_args = command_argument_count()
    allocate(args(num_args))
    do i = 1, num_args
        call get_command_argument(i,args(i))
    end do

    ! Set default value
    temperature = 0.d0
    height = 0
    width = 0

    i = 1
    do while ( i <= num_args )
        if (args(i)(1:1) == '-') then
            if (args(i)(2:2) == 't') then ! Temperature
                read(args(i+1), *) temperature
                i = i + 1
            else if (args(i)(2:2) == 'h') then ! Height
                read(args(i+1), *) height
                i = i + 1
            else if (args(i)(2:2) == 'w') then ! Width
                read(args(i+1), *) width
                i = i + 1
            else
                write(*, *) "Unknown argument ", args(i)
            end if
        end if
        i = i+1
    end do

    deallocate(args)

    if (temperature == 0.d0) stop "Temperature not specified"
    if (height == 0) stop "Height not specified"
    if (width == 0) stop "Width not specified"

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

subroutine monte_carlo_step(mat, width, height, PBCx, PBCy, energy, temperature)

    implicit none
    integer, intent(in) :: width, height, PBCx(0: width+1), PBCy(0: height+1)
    integer*2, intent(inout) :: mat(1:width, 1:height)
    real*8, intent(in) :: energy, temperature
    real*8 deltaE, genrand_real2

    integer :: randPoint, i, j, k
    real*8 :: expo(-8: 8)

    do i = -8, 8
        expo(i) = exp(-i/temperature)
    end do

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
        else
            if (genrand_real2() <= expo(int(deltaE))) then
                mat(i,j) = -mat(i,j)
            end if
        end if

    end do

    
end subroutine monte_carlo_step

subroutine metropolis(mat, width, height, PBCx, PBCy, energy, temperature, Niter, fileUnit)
    
    implicit none
    integer, intent(in) :: width, height, PBCx(0: width+1), PBCy(0: height+1), Niter
    integer*2, intent(inout) :: mat(1:width, 1:height)
    real*8, intent(inout) :: energy
    real*8, intent(in) :: temperature
    real*8 energ
    integer fileUnit

    character(len=40) fmt
    integer magne, mag

    integer i, ios

    write(fileUnit, "(a2, a12, 3a14)") "# ", "Iter", "Energy", "Energ Check", "Magnetization"
    do i = 1, Niter
        call monte_carlo_step(mat, width, height, PBCx, PBCy, energy, temperature)
        energy = energ(mat, width, height, PBCx, PBCy)
        mag = magne(mat, width, height)
        write(fileUnit, "(i14.6, 1f14.1, i14)") i, energy, mag
    end do

    write(*, *) "    Final energy: ", energy
    write(*, *) "    Final magnetization: ", mag

end subroutine metropolis

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