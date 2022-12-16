program main

    implicit none
    


    integer :: seedCount, originalSeed, Niter, skipIter, height, width, numTemperature
    real*8 :: temperature, finalTemperature
    character(len=30) :: name
    namelist /input/ name, temperature, finalTemperature, numTemperature, seedCount, originalSeed, Niter, skipIter, height, width

    real*8 energ, E
    integer*2 genrand_int2
    real*8 timeStart, timeEnd, globalTimeStart, globalTimeEnd, temp, dtemp
    character(len=30) :: fileName
    integer *2, allocatable, dimension(:, :) :: S
    integer, allocatable, dimension(:) :: PBCx, PBCy

    integer i, j, k, seed, ios
    character(len=10) :: seedStr, tempStr

    ! Read the input file
    open(unit=10, file="dat/MC2.dat", iostat=ios)
    if ( ios /= 0 ) stop "Error opening file dat/MC2.dat"

    read(10, input)

    close(10)
    

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


    write(*, *) "Metropolis algorithm by Marc Parcerisa" 
    write(*, *) "-------------------------------------"
    write(*, *) "Name: ", name
    write(*, *) "Temperature: ", temperature
    write(*, *) "Original seed: ", originalSeed
    write(*, *) "Number of seeds: ", seedCount
    write(*, *) "Number of iterations: ", Niter
    write(*, *) "Number of iterations to skip: ", skipIter
    write(*, *) "Height: ", height
    write(*, *) "Width: ", width
    write(*, *) "-------------------------------------"

    call cpu_time(globalTimeStart)

    dtemp = (finalTemperature - temperature)/real(numTemperature, 8)
    do k = 1, numTemperature
        temp = temperature + real(k-1, 8)*dtemp
    do seed = originalSeed, originalSeed + seedCount - 1

        call cpu_time(timeStart)

        write(seedStr, "(i10)") seed
        write(tempStr, "(f10.4)") temp
        fileName = trim(name)//"_"//trim(adjustl(tempStr))//"_"//trim(adjustl(seedStr))//".dat"
        open(unit=10, file="dat/seedAverages/"//fileName, iostat=ios)
        if ( ios /= 0 ) stop "Error opening file dat/seedAverages/"//fileName

        ! write(10, *) "# { temperature:", temperature, "seed:", seed, "Niter:", Niter, "skipIter:", skipIter, "height:", &
        !             & height, "width:", width, "}"
        write(10, *) "# temperature = ", temp
        write(10, *) "# seed = ", seed
        write(10, *) "# Niter = ", Niter
        write(10, *) "# skipIter = ", skipIter
        write(10, *) "# height = ", height
        write(10, *) "# width = ", width
        write(10, *) "#"

        write(*, *) "Runing metropolis algorithm with seed ", seed
        ! Generate a random spin array
        call init_genrand(seed)
        do i = 1, width
            do j = 1, height
                S(i,j) = genrand_int2()
            enddo
        enddo

        call metropolis(S, width, height, PBCx, PBCy, E, temp, Niter, 10)

        close(10)

        call cpu_time(timeEnd)
        write(*, "(a, f10.4, a)") "    Done! Time elapsed: ", timeEnd - timeStart, " seconds"

    end do
    end do
    call cpu_time(globalTimeEnd)
    write(*, "(a, f10.4, a)") "Total time elapsed: ", globalTimeEnd - globalTimeStart, " seconds"
end program main


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
    real*8 :: expo(-8: 8)

    do i = -8, 8
        expo(i) = exp(-i/temp)
    end do

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
            if (genrand_real2() <= expo(int(deltaE))) then
                mat(i,j) = -mat(i,j)
                newEnergy = newEnergy + deltaE
            end if
        end if

    end do

    
end subroutine monte_carlo_step

subroutine metropolis(mat, width, height, PBCx, PBCy, energy, temp, Niter, fileUnit)
    
    implicit none
    integer, intent(in) :: width, height, PBCx(0: width+1), PBCy(0: height+1), Niter
    integer*2, intent(inout) :: mat(1:width, 1:height)
    real*8, intent(inout) :: energy
    real*8, intent(in) :: temp
    real*8 newEnergy, energ
    integer fileUnit

    character(len=40) fmt
    integer magne, mag

    integer i, ios


    write(fileUnit, "(a2, a12, 3a14)") "# ", "Iter", "Energy", "Energ Check", "Magnetization"
    do i = 1, Niter
        call monte_carlo_step(mat, width, height, PBCx, PBCy, energy, temp, newEnergy)
        energy = energ(mat, width, height, PBCx, PBCy)
        mag = magne(mat, width, height)
        write(fileUnit, "(i14.6, 1f14.1, i14)") i, energy, mag
    end do

    write(*, *) "    Final energy: ", energy
    write(*, *) "    Final magnetization: ", mag


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