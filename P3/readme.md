# About this lab's main scripts

Program `MC2.f90` writes a large amount of files into dat/seedAverages, which `MC2-averages.f90` reads and computes their overall averages.

The latter script makes use of a python script (`listFiles.py`), which lists the files on the given directory and outputs a list of them into the given output. Usage:

`
py listFiles.py <directory> <outputFile>
`

To run the programs, a set of parameters are needed, which can be defined on the dat/MC2.dat file. Once they are defined, run the scripts with:

`
execs\MC2.exe
`

The program will display at the beginning the parameters that are being used for the simulation. Check they are correct. Then run:

`
execs\MC2-averages.exe
`

It will also read the parameters from the `dat/MC2.dat` file, and then detect all the data in the `dat/seedAverages/` folder. The averages and other results will be displayed at the end of the program's output.




# About other documents

## For the P3-temperature-convergence.f90 script

Compile and run on windows with:

`
gfortran -O3 .\P3-temperature-convergence.f90 -o .\execs\P3-temperature-convergence.exe; ./execs/P3-temperature-convergence.exe -l 48 48 -n 3000 -s 12345
`

## For the P3-seed-convergence.f90 script

Compile and run on windows with

`
gfortran -O3 .\P3-seed-convergence.f90 -o .\execs\P3-seed-convergence.exe; ./execs/P3-seed-convergence.exe -l 48 48 -n 3000 -t 1.3
`

## For the P3-promitjos.f90 script

Compile and run on windows with

`
gfortran -O3 .\P3-promitjos.f90 -o .\execs\P3-promitjos.exe; .\execs\P3-promitjos.exe -i .\dat\P3-T-1.500.dat
`

## For the P3-exercici-1.f90 script

Compile and run on windows with:

`
gfortran -O3 .\mt19937ar.o .\P3-exercici-1.f90 -o .\execs\P3-exercici-1.exe; .\execs\P3-exercici-1.exe -l 48 48 -n 3000 -t 1.3 -o P3-montecarlo-out.dat -g
`

If you just want to run it, do it with:

`
.\execs\P2-exercici-1.exe -l <width> <height> -n <iterations> -t <temperature> -o <filename> -g
`

(`-g` stands that you want graphs to be generated)

Default is (if you don't specify any values):

`
.\execs\P2-exercici-1.exe -l 48 48 -n 3000 -t 1.3 -o P3-montecarlo-out.dat -g
`
