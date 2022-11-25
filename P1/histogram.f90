module histogram_mod

    implicit none
    public
    
    contains

    subroutine equidist(a, b, nValors, taula)
    ! Retorna a <taula> una llista de <ordreN + 1> valors equidistants entre x=a i x=b.
        implicit none
        integer nValors, k
        double precision a, b, taula(nValors), h
        
        h = (b-a)/(nValors - 1)
        do k = 1, nValors
            taula(k) = a + (k-1)*h
        end do
        return

    end subroutine equidist


    subroutine count_data(nDat, boxCount, xData, partitions, xCount)
    ! Compta el nombre de punts en xData dintre de <x_i> i <x_i+1> a les particions.
    ! Retorna una llista de mida <boxCount> amb el recompte.
        implicit none
        integer boxCount, nDat, k, listPosition
        integer, dimension(boxCount) :: xCount
        double precision xData(nDat), partitions(boxCount+1)

        ! Inicialitzem xCount:
        do k = 1, boxCount
            xCount(k) = 0
        end do

        ! Bàsicament programem un sistema de búsca dins d'una llista, hem de trobar el valor
        ! xData(k) dins la llista partitions(boxCount+1).
        ! Ja que no sabem la mida de xData ni de partitions, caldrà programar algun mètode
        ! una mica més rebuscat però que permeti agilitzar el programa, que enlloc de tenir un
        ! temps d'execució de O(nDat * boxCount) en tingui un menor.
        do k = 1, nDat
            ! Obtenim la posició de x dins la llista partitions
            call search_in_sorted_list(boxCount+1, partitions, xData(k), listPosition)
            ! I sumem 1 al compte del seu interval corresponent
            if ( listPosition .eq. 0 ) cycle ! Si search_in_sorted_list ha donat error (ha trobat
            ! un punt fora dels límits) llavors no guardem res.
            xCount(listPosition) = xCount(listPosition) + 1
        end do
        return

    end subroutine count_data


    subroutine search_in_sorted_list(listSize, list, x, listPointer)
    ! Situa el punt x entre dos punts de la llista (ordenada) list, de mida listSize.
    ! Retorna la posició en la llista <listPointer>. X estarà entre list(listPointer) i
    ! list(listPointer + 1). Per fer-ho, guarda un apuntador cap a una posició (inicialment la
    ! meitat) de la llista list. Va movent l'apuntador fent salts de mida N/(2^k) on k és la
    ! iteració en què estem i N la mida de la llista, compara el valor de la llista en aquell
    ! punt amb el valor de la x que intentem situar, i escull la direcció del següent salt en
    ! funció d'això.
    ! Aquest mètode permet reduir el temps de cerca de O(N) a O(log2(N))
        implicit none
        integer listSize, listPointer, jump, niter ! Guardarem el nombre d'iteracions
        double precision list(listSize), x
        
        if ( x .gt. list(listSize) .or. x .lt. list(1)) then
            print * , "Warning in search_in_sorted_list: Given X is out of bounds."
            listPointer = 0 ! Retornem zero com a codi d'error
            return
        end if

        niter = 0
        jump = listSize/2 ! Comencem fent salts de la meitat de la mida de la llista. Es integer
        listPointer = jump ! Inicialitzem l'apuntador amb el qual buscarem a la llista
        do while ( niter .le. listSize/2 ) ! Aquest mètode en cap cas hauria de superar N/2 iteracions
                
            if ( x .ge. list(listPointer) .and. x .le. list(listPointer + 1) ) then
                ! Si hem trobat ja l'interval al qual x pertany, parem tot
                return
            end if

            jump = jump/2
            if ( jump .eq. 0 ) jump = 1 ! Assegurem-nos que seguim fent salts en iterar

            niter = niter + 1
            if ( x .ge. list(listPointer) ) then
                listPointer = listPointer + jump
                cycle
            end if
            listPointer = listPointer - jump
        end do

        ! Si el mètode ha fet massa iteracions:
        print * , "Error in search_in_sorted_list: Reached iteration limit."
        return

    end subroutine search_in_sorted_list


    subroutine histogram(nDat, xData, x0, x1, boxCount, graphName)
    ! Retorna les dades per a construir un histograma de les dades <xData(nDat)> amb <boxCount>
    ! caixes. Retorna llistes de mida <boxCount> amb les dades de la x central de la caixa
    ! (<histogramX>), l'altura de la barra (<histogramHeight>), l'error en l'estimació de l'altura
    ! (<heightError>) i la mida de les caixes (<boxSize>).
        implicit none
        integer nDat, boxCount, k
        ! Inputs
        double precision, dimension(nDat) :: xData
        ! Outputs
        double precision, dimension(boxCount) :: histogramX, histogramHeight, heightError, boxSize
        ! Variables
        double precision h, x0, x1, partitions(boxCount+1), Nk, wk
        integer, dimension(boxCount) :: countList
        character(len=*), intent(in) :: graphName

        ! Per si de cas no es donessin x0 i x1
        ! call find_min(nDat, xData, x0)
        ! call find_max(nDat, xData, x1)
        h = (x1 - x0)/boxCount

        ! Creem ara la llista de particions, que ens permetria després comptar el nombre de x 
        ! dins de cada partició de forma còmoda. Això cal en cas que les caixes de l'histograma
        ! no siguin equidistants, cas que no es donarà en aquesta subrutina de moment, però que
        ! en el futur podria donar-se. Veure més endavant quan comptem les xData.
        call equidist(x0, x1, boxCount+1, partitions)

        ! Ara comptem quants punts en xData hi ha en cada interval.
        ! Hi ha dues formes de fer-ho. La ràpida és calcular la k a què correspon cada x en xDat
        ! a partir de la mida de la caixa, però per això cal saber amb seguretat que totes les
        ! caixes tenen la mateixa mida. No obstant, sabem que no té per què. Doncs, ens programem
        ! la subrutina count_data(), aquesta necessita que li donem, a part de la llista de dades,
        ! una llista de intervals en x, que guardi en concret els límits d'aquests.
        ! Per exemple, dividint l'interval X en [0, 2] en dos intervals, tindriem les caixes
        ! x=0.5 i x=1.5 amb mida h=1; doncs, la llista partitions seria la llista [0, 1, 2].
        call count_data(nDat, boxCount, xData, partitions, countList)

        ! Per acabar, calculem totes les dades que retornarem per a fer l'histograma
        do k = 1, boxCount
            histogramX(k) = (partitions(k+1) + partitions(k))/2 ! Ja preveiem que les particions
            ! no siguin equidistants
            boxSize(k) = partitions(k+1) - partitions(k)
            Nk = dble(countList(k))
            wk = boxSize(k)
            histogramHeight(k) = Nk / nDat / wk
            heightError(k) = 1.d0/wk/sqrt(dble(nDat)) * sqrt(Nk/nDat * (1.d0 - Nk/nDat))
        end do

        ! Ara crearem la imatge de l'histograma
        call draw_histogram(boxCount, histogramX, histogramHeight, heightError, boxSize, graphName)
        return

    end subroutine histogram


    subroutine draw_histogram(nbox, histX, histHeight, histErr, boxSize, graphName)

        implicit none
        integer, intent(in) :: nbox
        double precision, dimension(nbox), intent(in) :: histX, histHeight, histErr, boxSize
        character(len=*), intent(in) :: graphName

        character(len=1), parameter :: sq = "'" ! Per a poder printejar single quotes
        character(len=len(graphName)+4) :: fileName
        character(len=len(graphName)+100) gnuCommand ! Voldrem passar dades a gnuplot
        character(len=len(fileName)+9) :: winCommand ! Per a borrar l'arxiu temporal fileName
        character(len=len(fileName)+5) :: linuxCommand
        integer k

        write(fileName, "(2a)") graphName, ".dat"
        open(20, file = fileName)

        do k = 1, nbox
            write(20, "(4f20.14)") histX(k), histHeight(k), histErr(k), boxSize(k)
        end do

        close(20)

        ! I dibuixem la gràfica
        write(gnuCommand, "(6a)")'gnuplot -e "file=', sq, graphName, sq, '" "gnu\histogram.gnu"'
        call system(gnuCommand)

        write(winCommand,"(3a)") 'del /f "',fileName,'"' ! Atenció: només funciona a windows
        write(linuxCommand,"(3a)") 'rm "', fileName,'"' ! Atenció: només funciona a linux

        ! Si s'executarà el programa en linux, cal canviar <winCommand> per <linuxCommand>
        call system(winCommand)

        return

    end subroutine draw_histogram

end module histogram_mod