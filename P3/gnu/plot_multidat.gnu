# files= "f1 f2 f3 ..."

set terminal png
set xlabel "Iterations"

set key outside

set output "dat/P3-multiple-energy-convergence.png"
set title "Energy convergence"
set ylabel "Energy [r.u.]"
plot for [file in files] "dat/".file using 1:3 with lines title file

set output "dat/P3-multiple-magnetization-convergence.png"
set title "Magnetization convergence"
set ylabel "Magnetization [r.u.]"
plot for [file in files] "dat/".file using 1:4 with lines title file
