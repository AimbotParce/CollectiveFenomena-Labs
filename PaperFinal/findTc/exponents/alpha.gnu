fileMax = "maximums.dat"
fileFit = "exponents/fit_log(maxC)[log(L)].dat"
equat = "y = 0.269 x - 0.308"

set terminal png size 1200,700 enhanced fontscale 2
set pointsize 2.5
set xlabel "log(L)"
set ylabel "log(C_v^{max})"
set output "figures/alpha.png"

set key top left

plot \
    fileFit using 1:2 with lines title equat, \
    fileMax using (log($1)):(log($6)) with points title "" pt 7
