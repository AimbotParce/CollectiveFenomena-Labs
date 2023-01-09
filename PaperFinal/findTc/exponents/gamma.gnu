fileMax = "maximums.dat"
fileFit = "exponents/fit_log(maxX)[log(L)].dat"
equat = "y = 1.760 x - 3.080"

set terminal png size 1200,700 enhanced fontscale 2
set pointsize 2.5
set xlabel "log(L)"
set ylabel "log(susc.^{max})"
set output "figures/gamma.png"

set key top left

plot \
    fileFit using 1:2 with lines title equat, \
    fileMax using (log($1)):(log($7)) with points title "" pt 7
