! Load all the documents from the dat/seedAverages folder. Average data for each file, then average them over the files.
! By Marc Parcerisa

program main

    implicit none
    
    integer :: seedCount, originalSeed, Niter, skipIter, meanEvery
    character(len=30) :: folderName
    namelist /input/ seedCount, originalSeed, Niter, skipIter, meanEvery, folderName

    character(len=100) :: filename
    integer fileCount

    real*8, allocatable, dimension(:) :: energy, energySquared, magne, magneSquared, magneAbs, temperatures
    real*8, allocatable, dimension(:) :: energyAverage,energySquaredAverage, magneAverage, magneSquaredAverage, magneAbsAverage
    real*8, allocatable, dimension(:) :: specificHeat, magneticSusceptibility
    real*8 :: differentTemperatures(1000) ! Different temperatures arbitrarily large
    logical inMetadata, inList
    character(len=100) :: line
    integer lenMetadata, iteration, M, temperatureCount ! temperatureCount is the number of different temperatures
    integer, allocatable, dimension(:) :: temperatureCounters ! How many times each temperature appears
    real*8 E, initTime, finalTime

    integer ios, i, j, count, N
    
    ! Read the input file
    open(unit=10, file="dat/MC2.dat", iostat=ios)
    if ( ios /= 0 ) stop "Error opening file dat/MC2.dat"
    read(10, input)
    close(10)


    write(*,*) "Computing averages for all the documents in the folder"
    write(*,*) "---------------------------------------------------------------"
    write(*,*) "Name: ", name
    ! write(*,*) "Temperature: ", temp
    write(*,*) "Seed count: ", seedCount
    write(*,*) "Original seed: ", originalSeed
    write(*,*) "Iterations: ", Niter
    write(*,*) "Skip iterations: ", skipIter
    write(*,*) "Height: ", height
    write(*,*) "Width: ", width
    write(*,*) "---------------------------------------------------------------"

    call cpu_time(initTime)

    ! List all files in the folder
    ! call system("ls .\dat\seedAverages\ > dat\fileContents.txt")
    ! ON WINDOWS, THIS DOES NOT WORK. I'LL USE PYTHON TO DO IT
    call system("python listFiles.py dat/"//trim(adjustl(folderName))//"/ dat/fileContents.txt")

    open(unit=10, file="dat/fileContents.txt", iostat=ios)
    if ( ios /= 0 ) stop "Error opening file dat/fileContents.txt"
    ! The first line is the number of files
    read(10, '(i5)', iostat=ios) fileCount
    write(*,"(a,i5, a)") "Reading ", fileCount, " files"

    ! Allocate the arrays
    allocate(energy(fileCount), energySquared(fileCount), magne(fileCount), magneSquared(fileCount), magneAbs(fileCount)) 
    allocate(temperatures(fileCount))

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
                ! Read the metadata; if it is the temperature, save it
                if ( index(line, "temperature") > 0 ) then
                    read(line(index(line, "=")+1:), '(f14.1)', iostat=ios) temperatures(i)
                    if (ios /= 0) stop "Error reading file "// trim(filename)
                    ! Check if the temperature is already in the list
                    inList = .false.
                    do j = 1, temperatureCount
                        if ( temperatures(i) == differentTemperatures(j) ) then
                            inList = .true.
                            exit
                        end if
                    end do
                    if ( .not. inList ) then
                        temperatureCount = temperatureCount + 1
                        differentTemperatures(temperatureCount) = temperatures(i)
                    end if
                end if
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
        count = 0
        do j = 1, Niter
            read(11, '(i14, f14.1, i14)', iostat=ios) iteration, E, M
            if (ios /= 0) stop "Error reading file "// trim(filename)

            if ( j > skipIter ) then
                if (mod(j-skipIter, meanEvery) == 0) then
                    energy(i) = energy(i) + E
                    energySquared(i) = energySquared(i) + E**2
                    magne(i) = magne(i) + M
                    magneSquared(i) = magneSquared(i) + M**2
                    magneAbs(i) = magneAbs(i) + abs(M)
                    count = count + 1
                end if
            end if
        end do
        
        energy(i) = energy(i) / count
        energySquared(i) = energySquared(i) / count
        magne(i) = magne(i) / count
        magneSquared(i) = magneSquared(i) / count
        magneAbs(i) = magneAbs(i) / count

        write(*,*) "    Temperature: ", temperatures(i)
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

    ! Allocate the arrays for the averages
    allocate(energyAverage(temperatureCount), energySquaredAverage(temperatureCount), &
             magneAverage(temperatureCount), magneSquaredAverage(temperatureCount), &
             magneAbsAverage(temperatureCount), temperatureCounters(temperatureCount), &
             specificHeat(temperatureCount), magneticSusceptibility(temperatureCount))

    ! Sum all the values for each temperature
    ! Initialize all the arrays to zero
    do i = 1, temperatureCount
        temperatureCounters(i) = 0
        energyAverage(i) = 0.d0
        energySquaredAverage(i) = 0.d0
        magneAverage(i) = 0.d0
        magneSquaredAverage(i) = 0.d0
        magneAbsAverage(i) = 0.d0
    end do
    ! Run for all the documents, and sum the values for each temperature
    do i = 1, fileCount
        ! Find the temperature
        do j = 1, temperatureCount
            if ( temperatures(i) == differentTemperatures(j) ) then
                temperatureCounters(j) = temperatureCounters(j) + 1
                energyAverage(j) = energyAverage(j) + energy(i)
                energySquaredAverage(j) = energySquaredAverage(j) + energySquared(i)
                magneAverage(j) = magneAverage(j) + magne(i)
                magneSquaredAverage(j) = magneSquaredAverage(j) + magneSquared(i)
                magneAbsAverage(j) = magneAbsAverage(j) + magneAbs(i)
            end if
        end do
    end do
    
    ! Divide by the number of documents
    do i = 1, temperatureCount
        energyAverage(i) = energyAverage(i) / temperatureCounters(i)
        energySquaredAverage(i) = energySquaredAverage(i) / temperatureCounters(i)
        magneAverage(i) = magneAverage(i) / temperatureCounters(i)
        magneSquaredAverage(i) = magneSquaredAverage(i) / temperatureCounters(i)
        magneAbsAverage(i) = magneAbsAverage(i) / temperatureCounters(i)

        specificHeat(i) = (energySquaredAverage(i) - energyAverage(i)**2) / differentTemperatures(i)**2
        magneticSusceptibility(i) = (magneSquaredAverage(i) - magneAverage(i)**2) / differentTemperatures(i)
    end do

    ! Print the results
    write(*,*) temperatureCount, " different temperatures found"
    do i = 1, temperatureCount
        write(*,*) "---------------------------------------------------------------"
        write(*,*) "    Temperature: ", differentTemperatures(i)
        write(*,*) "    Number of documents: ", temperatureCounters(i)
        write(*,*) "    Energy: ", energyAverage(i), " +/- ", sqrt(energySquaredAverage(i) - energyAverage(i)**2)
        write(*,*) "    Energy squared: ", energySquaredAverage(i)
        write(*,*) "    Magnetization: ", magneAverage(i), " +/- ", sqrt(magneSquaredAverage(i) - magneAverage(i)**2)
        write(*,*) "    Magnetization squared: ", magneSquaredAverage(i)
        write(*,*) "    Magnetization absolute: ", magneAbsAverage(i)


        write(*,*) "                                   - "

        write(*,*) "    Specific heat: ", specificHeat(i)
        write(*,*) "    Susceptibility: ", magneticSusceptibility(i)

    end do
    write(*,*) "---------------------------------------------------------------"
    call cpu_time(finalTime)
    write(*,*) "Done! Time elapsed: ", finalTime - initTime, " seconds"

    write(*,*) "---------------------------------------------------------------"
    write(*,*) "Writing the results to file"

    open(unit=20, file="dat/averages.dat", iostat=ios)
    if ( ios /= 0 ) stop "Error opening file dat/averages.dat"

    N =  width * height

    write(20, '(8a30)') "Temperature", "Energy", "Energy squared", &
                         "Magnetization", "Magnetization squared", &
                         "Magnetization absolute", "Specific heat", &
                         "Magnetic susceptibility"
    do i = 1, temperatureCount
        write(20, '(8f30.4)') &
            differentTemperatures(i), energyAverage(i)/N, energySquaredAverage(i)/N, &
            magneAverage(i)/N, magneSquaredAverage(i)/N, magneAbsAverage(i)/N, &
            specificHeat(i)/N, magneticSusceptibility(i)/N
    end do

    close(20)

end program main

