# Montecarlo simulation for an Ising model
### By Marc Parcerisa


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
