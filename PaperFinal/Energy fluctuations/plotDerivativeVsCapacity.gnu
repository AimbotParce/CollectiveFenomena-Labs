file = "energy_derivative_vs_specific_heat.dat"

set terminal png size 1200,700 enhanced fontscale 2
set pointsize 2.5
set xlabel "Temperatura [u.r.]"
set output "energDerivativeVsCv.png"
set ylabel "C_v [u.r.]"

plot file using 1:2 with linespoints title "dE/dT", \
     file using 1:3 with linespoints title "variància"