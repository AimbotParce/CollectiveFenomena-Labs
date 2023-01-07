! Load all the documents from the dat/seedAverages folder. Average data for each file, then average them over the files.
! By Marc Parcerisa

program main

    implicit none
    
    ! Data from MC2.dat
    integer :: seedCount, originalSeed, Niter, skipIter, meanEvery
    character(len=30) :: folderName
    namelist /input/ seedCount, originalSeed, Niter, skipIter, meanEvery, folderName

    ! File from which we'll read data (taken from python script listFiles.py)
    character(len=100) :: fileName

    ! Allocatable data, will store all of this data for each file
    integer fileCount
    real*8, allocatable, dimension(:) :: energy, energySquared, magne, magneSquared, magneAbs, temperature
    integer, allocatable, dimension(:) :: systemSize

    ! Allocatable data, will store the averages for each temperature, for each system size.
    integer count
    real*8, allocatable, dimension(:, :) :: energyAverage,energySquaredAverage, magneAverage, magneSquaredAverage, magneAbsAverage
    real*8, allocatable, dimension(:, :) :: specificHeat, magneticSusceptibility
    integer, allocatable, dimension(:, :) :: multiDimCounter
    integer Sindex, Tindex ! Indexes we have to use to store the data in the right place in the arrays
    ! multiDimCounter is a counter for the number of times we have computed the averages for each temperature and system size.
    ! Should be the same as seedCount, but I don't trust the user (myself) not to change the number of seeds in the input file
    ! in the middle of the computation (I've done it before, and it's a pain to debug).
    
    ! Store the different temperatures and system sizes that appear in the files, so we can compute the averages
    ! for each temperature and system size
    ! temperatureCount is the number of different temperatures that appear in the files
    ! systemSizeCount is the number of different system sizes that appear in the files
    ! We suppose that all the geometries (width x height) share the same temperature distribution,
    ! and viceversa, every temperature was computed for all geometries.
    integer :: temperatureCount, systemSizeCount
    integer :: allSystemSizes(1000) 
    real*8 :: allTemperatures(1000)

    ! Variables to manage metadata
    character(len=100) :: line
    logical inMetadata, inList
    integer lenMetadata

    ! Variables to read from the data in the file
    integer iteration, M
    real*8 E

    ! Time control
    real*8 initTime, finalTime

    ! Other variables such as counters and iterators
    integer ios, i, j, k, N
    
    ! Read the input file
    open(unit=10, file="dat/MC2.dat", iostat=ios)
    if ( ios /= 0 ) stop "Error opening file dat/MC2.dat"
    read(10, input)
    close(10)


    write(*,*) "Computing averages for all the documents in the folder"
    write(*,*) "---------------------------------------------------------------"
    ! write(*,*) "Temperature: ", temp
    write(*,*) "Iterations: ", Niter
    write(*,*) "Skip iterations: ", skipIter
    write(*,*) "---------------------------------------------------------------"

    call cpu_time(initTime)

    ! List all files in the folder
    ! call system("ls .\dat\seedAverages\ > dat\fileContents.txt")
    ! ON WINDOWS, THIS DOES NOT WORK. I'LL USE PYTHON TO DO IT
    call system("python lib\listFiles.py dat/"//trim(adjustl(folderName))//"/ dat/fileContents.txt")

    open(unit=10, file="dat/fileContents.txt", iostat=ios)
    if ( ios /= 0 ) stop "Error opening file dat/fileContents.txt"
    ! The first line is the number of files that are in the folder
    read(10, '(i5)', iostat=ios) fileCount
    write(*,"(a,i5, a)") "Reading ", fileCount, " files"

    ! Allocate the 
    allocate(temperature(fileCount), systemSize(fileCount))
    ! Also we will not allocate seed, as we really don't care about it to compute the averages.
    allocate(energy(fileCount), energySquared(fileCount), magne(fileCount), magneSquared(fileCount), magneAbs(fileCount)) 

    ! Read the files one by one, and compute their averages
    do i = 1, fileCount
        read(10, '(a100)', iostat=ios) fileName
        if ( ios /= 0 ) stop "Error reading file dat/fileContents.txt"

        write(*,*) "Reading file ", fileName

        ! Read the file
        open(unit=11, file=fileName, iostat=ios)
        if ( ios /= 0 ) stop "Error opening file "// trim(fileName)

        ! Read all the metadata from the file (We've saved it with # at the beginning of the line)
        ! We will save the temperature and the system size
        inMetadata = .true. ! State variable to know if we are inside the metadata
        lenMetadata = 0 ! How many lines of metadata we have read, so we can rewind the file and go back to the beginning of the data
        do while ( inMetadata )
            read(11, '(a)', iostat=ios) line
            if (ios /= 0) stop "Error reading file" // trim(fileName)

            ! Eliminate blank spaces at the beginning of the line
            write(line,"(a)") adjustl(line)

            ! Check we didn't reach the end of the metadata
            if ( line(1:1) /= '#' ) then
                inMetadata = .false. 
            else 
                lenMetadata = lenMetadata + 1
                ! Read the metadata; if you encounter a temperature or a system size, save it
                if ( index(line, "temperature") > 0 ) then
                    read(line(index(line, "=")+1:), '(f14.1)', iostat=ios) temperature(i)
                    if (ios /= 0) stop "Error reading file "// trim(filename)

                    ! Check if the temperature is already in the list
                    inList = .false.
                    do j = 1, temperatureCount
                        if ( temperature(i) == allTemperatures(j) ) then
                            inList = .true.
                            exit
                        end if
                    end do
                    if ( .not. inList ) then ! If it is not in the list, add it
                        temperatureCount = temperatureCount + 1
                        allTemperatures(temperatureCount) = temperature(i)
                    end if
                else if ( index(line, "height") > 0 ) then
                    read(line(index(line, "=")+1:), '(i13)', iostat=ios) systemSize(i)
                    if (ios /= 0) stop "Error reading file "// trim(filename)

                    ! Check if the system size is already in the list
                    inList = .false.
                    do j = 1, systemSizeCount
                        if ( systemSize(i) == allSystemSizes(j) ) then
                            inList = .true.
                            exit
                        end if
                    end do
                    if ( .not. inList ) then ! If it is not in the list, add it
                        systemSizeCount = systemSizeCount + 1
                        allSystemSizes(systemSizeCount) = systemSize(i)
                    end if
                end if
            end if
        end do
        ! Rewind back to the beginning, and then advance to the end of the metadata (beginning of actual data)
        rewind (11)
        do j = 1, lenMetadata
            read(11, '(a)', iostat=ios)
            if (ios /= 0) stop "Error reading file "// trim(filename)
        end do

        ! Compute the averages for this file
        energy(i) = 0.d0
        energySquared(i) = 0.d0
        magne(i) = 0.d0
        magneSquared(i) = 0.d0
        magneAbs(i) = 0.d0
        count = 0
        do j = 1, Niter
            read(11, '(i14, f14.1, i14)', iostat=ios) iteration, E, M
            if (ios /= 0) stop "Error reading file "// trim(filename)

            if ( j > skipIter ) then ! Do not take into account the first skipIter iterations
                if (mod(j-skipIter, meanEvery) == 0) then ! Only mean every meanEvery iterations
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

        write(*,*) "    Temperature: ", temperature(i)
        write(*,*) "    System size: ", systemSize(i)
        write(*,*) "    Energy: ", energy(i)
        write(*,*) "    Energy squared: ", energySquared(i)
        write(*,*) "    Variance: ", energySquared(i) - energy(i)**2
        write(*,*) "    Magnetization: ", magne(i)
        write(*,*) "    Magnetization squared: ", magneSquared(i)
        write(*,*) "    Variance: ", magneSquared(i) - magne(i)**2
        write(*,*) "    Magnetization absolute: ", magneAbs(i)

        close(11)

    end do

    close(10)

    ! Compute the averages
    write(*,*) "---------------------------------------------------------------"
    write(*,*) "Computing the overall averages"

    ! Allocate the arrays for the averages (alocate first energyAverage, then the rest with the same shape)
    allocate(energyAverage(systemSizeCount, temperatureCount))
    allocate(energySquaredAverage, magneAverage, magneSquaredAverage, magneAbsAverage, &
            specificHeat, magneticSusceptibility, mold=energyAverage)
    allocate(multiDimCounter(systemSizeCount, temperatureCount))

    ! Sum all the values for each temperature and system size
    ! Initialize all the arrays to zero
    multiDimCounter = 0
    energyAverage = 0.d0
    energySquaredAverage = 0.d0
    magneAverage = 0.d0
    magneSquaredAverage = 0.d0
    magneAbsAverage = 0.d0

    ! Run for all the documents, find which of the temperatures and system sizes they have, and add the values
    ! to the corresponding arrays
    do i = 1, fileCount
        Tindex = -1
        Sindex = -1 ! Initialize to -1, so that if they are not found, the program will stop
        ! Find the systemSize and temperature of the current document
        do j = 1, systemSizeCount
            if ( systemSize(i) == allSystemSizes(j) ) then
                Sindex = j
                exit
            end if
        end do
        do j = 1, temperatureCount
            if ( temperature(i) == allTemperatures(j) ) then
                Tindex = j
                exit
            end if
        end do
        if ( Sindex == -1 .or. Tindex == -1 ) stop "Error: system size or temperature not found"
        ! ^ This should be impossible, since all temperatures in all files should have been taken into account
        multiDimCounter(Sindex, Tindex) = multiDimCounter(Sindex, Tindex) + 1
        energyAverage(Sindex, Tindex) = energyAverage(Sindex, Tindex) + energy(i)
        energySquaredAverage(Sindex, Tindex) = energySquaredAverage(Sindex, Tindex) + energySquared(i)
        magneAverage(Sindex, Tindex) = magneAverage(Sindex, Tindex) + magne(i)
        magneSquaredAverage(Sindex, Tindex) = magneSquaredAverage(Sindex, Tindex) + magneSquared(i)
        magneAbsAverage(Sindex, Tindex) = magneAbsAverage(Sindex, Tindex) + magneAbs(i)
    end do
    
    ! Divide by the number of documents for each temperature and system size
    do i = 1, systemSizeCount
    do j = 1, temperatureCount
        energyAverage(i, j) = energyAverage(i, j) / multiDimCounter(i, j)
        energySquaredAverage(i, j) = energySquaredAverage(i, j) / multiDimCounter(i, j)
        magneAverage(i, j) = magneAverage(i, j) / multiDimCounter(i, j)
        magneSquaredAverage(i, j) = magneSquaredAverage(i, j) / multiDimCounter(i, j)
        magneAbsAverage(i, j) = magneAbsAverage(i, j) / multiDimCounter(i, j)

        specificHeat(i, j) = (energySquaredAverage(i, j) - energyAverage(i, j)**2) / allTemperatures(j)**2
        magneticSusceptibility(i, j) = (magneSquaredAverage(i, j) - magneAverage(i, j)**2) / allTemperatures(j)
    end do
    end do

    ! Print the results
    write(*,*) temperatureCount, " different temperatures found"
    write(*,*) systemSizeCount, " different system sizes found"
    do i = 1, systemSizeCount
    do j = 1, temperatureCount
        write(*,*) "---------------------------------------------------------------"
        write(*,*) "    System size: ", allSystemSizes(i)
        write(*,*) "    Temperature: ", allTemperatures(j)
        write(*,*) "    Number of documents: ", multiDimCounter(i, j)
        write(*,*) "    Energy: ", energyAverage(i, j), " +/- ", sqrt(energySquaredAverage(i, j) - energyAverage(i, j)**2)
        write(*,*) "    Energy squared: ", energySquaredAverage(i, j)
        write(*,*) "    Magnetization: ", magneAverage(i, j), " +/- ", sqrt(magneSquaredAverage(i, j) - magneAverage(i, j)**2)
        write(*,*) "    Magnetization squared: ", magneSquaredAverage(i, j)
        write(*,*) "    Magnetization absolute: ", magneAbsAverage(i, j)

        write(*,*) "                                   - "

        write(*,*) "    Specific heat: ", specificHeat(i, j)
        write(*,*) "    Susceptibility: ", magneticSusceptibility(i, j)
    end do
    end do

    write(*,*) "---------------------------------------------------------------"
    call cpu_time(finalTime)
    write(*,*) "Done! Time elapsed: ", finalTime - initTime, " seconds"
    write(*,*) "---------------------------------------------------------------"

    write(*,*) "Writing the results to files"

    do i = 1, systemSizeCount
        ! Open the file
        write(fileName, *) allSystemSizes(i) ! Reuse the fileName variable
        open(unit=10, file="dat/averages/averages_L"//trim(fileName)//".dat", iostat=ios)
        if ( ios /= 0 ) stop "Error opening file dat/averages/averages_<size>.dat"

        write(10, '(8a30)') "Temperature", "Energy", "Energy squared", &
                             "Magnetization", "Magnetization squared", &
                             "Magnetization absolute", "Specific heat", &
                             "Magnetic susceptibility"
        N = allSystemSizes(i)**2
        do j = 1, temperatureCount
            write(10, '(8f30.4)') &
                allTemperatures(j), energyAverage(i, j)/N, energySquaredAverage(i, j)/N**2, &
                magneAverage(i, j)/N, magneSquaredAverage(i, j)/N**2, magneAbsAverage(i, j)/N, &
                specificHeat(i, j)/N, magneticSusceptibility(i, j)/N
        end do

        close(10)
    end do

end program main

