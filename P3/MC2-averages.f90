! Load all the documents from the dat/seedAverages folder. Average data for each file, then average them over the files.
! By Marc Parcerisa

program main

    implicit none
    
    integer :: seedCount, originalSeed, Niter, skipIter, height, width
    real*8 :: temperature
    character(len=30) :: name
    namelist /input/ name, temperature, seedCount, originalSeed, Niter, skipIter, height, width

    character(len=100) :: filename
    integer fileCount

    real*8, allocatable, dimension(:) :: energy, energySquared, magne, magneSquared, magneAbs
    real*8 :: energyAverage, energySquaredAverage, magneAverage, magneSquaredAverage, magneAbsAverage
    logical inMetadata
    character(len=100) :: line
    integer lenMetadata, iteration, M
    real*8 E

    integer ios, i, j
    
    ! Read the input file
    open(unit=10, file="dat/MC2.dat", iostat=ios)
    if ( ios /= 0 ) stop "Error opening file dat/MC2.dat"

    read(10, input)

    close(10)


    write(*,*) "Computing averages for all the documents in the folder dat/seedAverages"
    write(*,*) "---------------------------------------------------------------"
    write(*,*) "Name: ", name
    write(*,*) "Temperature: ", temperature
    write(*,*) "Seed count: ", seedCount
    write(*,*) "Original seed: ", originalSeed
    write(*,*) "Iterations: ", Niter
    write(*,*) "Skip iterations: ", skipIter
    write(*,*) "Height: ", height
    write(*,*) "Width: ", width
    write(*,*) "---------------------------------------------------------------"

    ! List all files in the folder
    ! call system("ls .\dat\seedAverages\ > dat\fileContents.txt")
    ! ON WINDOWS, THIS DOES NOT WORK. I'LL USE PYTHON TO DO IT
    call system("py listFiles.py dat/seedAverages/ dat/fileContents.txt")

    open(unit=10, file="dat/fileContents.txt", iostat=ios)
    if ( ios /= 0 ) stop "Error opening file dat/fileContents.txt"
    ! The first line is the number of files
    read(10, '(i5)', iostat=ios) fileCount
    write(*,"(a,i5, a)") "Reading ", fileCount, " files"

    ! Allocate the arrays
    allocate(energy(fileCount), energySquared(fileCount), magne(fileCount), magneSquared(fileCount), magneAbs(fileCount))

    ! Read the files one by one, and compute their averages
    do i = 1, fileCount
        read(10, '(a100)', iostat=ios) filename
        if ( ios /= 0 ) stop "Error reading file dat/fileContents.txt"

        write(*,*) "Reading file ", filename

        ! Read the file
        open(unit=11, file=filename, iostat=ios)
        if ( ios /= 0 ) stop "Error opening file "// trim(filename)

        ! Read all the data. Skip the header (starts with #)
        inMetadata = .true.
        lenMetadata = 0
        do while ( inMetadata )
            read(11, '(a)', iostat=ios) line
            if (ios /= 0) stop "Error reading file" // trim(filename)
            ! Eliminate blank spaces at the beginning of the line
            write(line,"(a)") adjustl(line)
            ! Check if we are inside the metadata
            if ( line(1:1) /= '#' ) then
                inMetadata = .false. 
            else 
                lenMetadata = lenMetadata + 1
            end if
        end do
        ! Rewind and advance back to the beginning of the data
        rewind (11)
        do j = 1, lenMetadata
            read(11, '(a)', iostat=ios)
            if (ios /= 0) stop "Error reading file "// trim(filename)
        end do

        energy(i) = 0.d0
        energySquared(i) = 0.d0
        magne(i) = 0.d0
        magneSquared(i) = 0.d0
        magneAbs(i) = 0.d0
        do j = 1, Niter
            read(11, '(i14, f14.1, i14)', iostat=ios) iteration, E, M
            if (ios /= 0) stop "Error reading file "// trim(filename)

            if ( j > skipIter ) then
                energy(i) = energy(i) + E
                energySquared(i) = energySquared(i) + E**2
                magne(i) = magne(i) + M
                magneSquared(i) = magneSquared(i) + M**2
                magneAbs(i) = magneAbs(i) + abs(M)
            end if
        end do

        energy(i) = energy(i) / (Niter - skipIter)
        energySquared(i) = energySquared(i) / (Niter - skipIter)
        magne(i) = magne(i) / (Niter - skipIter)
        magneSquared(i) = magneSquared(i) / (Niter - skipIter)
        magneAbs(i) = magneAbs(i) / (Niter - skipIter)

        write(*,*) "    Energy: ", energy(i)
        write(*,*) "    Energy squared: ", energySquared(i)
        write(*,*) "    Magnetization: ", magne(i)
        write(*,*) "    Magnetization squared: ", magneSquared(i)
        write(*,*) "    Magnetization absolute: ", magneAbs(i)

        close(11)

    end do

    close(10)

    ! Compute the averages
    write(*,*) "---------------------------------------------------------------"
    write(*,*) "Computing the overall averages"

    energyAverage = sum(energy) / fileCount
    energySquaredAverage = sum(energySquared) / fileCount
    magneAverage = sum(magne) / fileCount
    magneSquaredAverage = sum(magneSquared) / fileCount
    magneAbsAverage = sum(magneAbs) / fileCount

    write(*,*) "    Energy: ", energyAverage, " +/- ", sqrt(energySquaredAverage - energyAverage**2)
    write(*,*) "    Energy squared: ", energySquaredAverage
    write(*,*) "    Magnetization: ", magneAverage, " +/- ", sqrt(magneSquaredAverage - magneAverage**2)
    write(*,*) "    Magnetization squared: ", magneSquaredAverage
    write(*,*) "    Magnetization absolute: ", magneAbsAverage


    write(*,*) "                                   - "

    write(*,*) "    Specific heat: ", (energySquaredAverage - energyAverage**2) / (temperature**2)
    write(*,*) "    Susceptibility: ", (magneSquaredAverage - magneAbsAverage**2) / temperature

    write(*,*) "---------------------------------------------------------------"
    write(*,*) "Done!"

end program main

