fileMax = "maximums.dat"
fileFit = "exponents/fit_log(maxX)[log(L)].dat" # slope=[[0.64663938]] intercept=[-0.82365963]

set terminal png size 1200,700 enhanced fontscale 2
set pointsize 2.5
set xlabel "log(L)"
set ylabel "log(susc.^{max})"
set output "figures/gamma.png"

set key top right

plot \
    fileFit using 1:2 with lines title "", \
    fileMax using (log($1)):(log($7)) with points title "" pt 7
