file = "dat/P2-montecarlo-out.dat"

set terminal png 
set xlabel "Iterations"

set output "dat/P2-montecarlo-energy_convergence.png"
set title "Energy convergence"
set ylabel "Energy [r.u.]"
plot file using 1:3 with lines title ""

set output "dat/P2-montecarlo-magnetization_convergence.png"
set title "Magnetization convergence"
set ylabel "Magnetization [r.u.]"
plot file using 1:4 with lines title ""
