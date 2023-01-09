fileMax = "maximums.dat"
fitC = "exponents/fit_log(critMagabsC)[log(L)].dat" # slope=[[-0.09819695]] intercept=[-0.18389357]
fitX = "exponents/fit_log(critMagabsX)[log(L)].dat" # slope=[[-0.10647096]] intercept=[-0.37647197]

set terminal png size 1200,700 enhanced fontscale 2
set pointsize 2.5
set xlabel "log(L)"
set ylabel "log(<|{m}|>_{crit})"
set output "figures/beta.png"

set key top right

plot \
    fitC using 1:2 with lines title "", \
    fitX using 1:2 with lines title "", \
    fileMax using (log($1)):(log($8)) with points title "Usant max(C_v)" pt 7, \
    fileMax using (log($1)):(log($9)) with points title "Usant max(susc.)" pt 9
