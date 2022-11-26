# Montecarlo simulation for an Ising model
### By Marc Parcerisa

Compile and run on windows with:

`
gfortran -O3 .\mt19937ar.o .\P2-exercici-1.f90 -o .\execs\P2-exercici-1.exe; .\execs\P2-exercici-1.exe -s 48 48 -n 3000 -t 1.3
`

If you just want to run it, do it with:

` .\execs\P2-exercici-1.exe -s <width> <height> -n <iterations> -t <temperature>`

Default is (if you don't specify any values):

` .\execs\P2-exercici-1.exe -s 48 48 -n 3000 -t 1.3`
