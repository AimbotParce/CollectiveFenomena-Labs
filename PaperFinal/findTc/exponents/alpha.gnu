fileMax = "maximums.dat"
fileFit = "exponents/fit_log(maxC)[log(L)].dat" # slope=[[0.39724217]] intercept=[-0.18143107]

set terminal png size 1200,700 enhanced fontscale 2
set pointsize 2.5
set xlabel "log(L)"
set ylabel "log(C_v^{max})"
set output "figures/alpha.png"

set key top right

plot \
    fileFit using 1:2 with lines title "", \
    fileMax using (log($1)):(log($6)) with points title "" pt 7
