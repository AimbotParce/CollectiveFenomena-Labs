# Montecarlo simulation for an Ising model
### By Marc Parcerisa

Compile and run on windows with:

`
gfortran -O3 .\mt19937ar.o .\P3-exercici-1.f90 -o .\execs\P3-exercici-1.exe; .\execs\P3-exercici-1.exe -s 48 48 -n 3000 -t 1.3 -o P3-montecarlo-out.dat -g
`

If you just want to run it, do it with:

`
.\execs\P2-exercici-1.exe -s <width> <height> -n <iterations> -t <temperature> -o <filename> -g
`

(`-g` stands that you want graphs to be generated)

Default is (if you don't specify any values):

`
.\execs\P2-exercici-1.exe -s 48 48 -n 3000 -t 1.3 -o P3-montecarlo-out.dat -g
`
