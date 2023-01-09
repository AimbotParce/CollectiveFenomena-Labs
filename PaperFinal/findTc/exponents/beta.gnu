fileMax = "maximums.dat"
fitC = "exponents/fit_log(magabs_Tc_C)[log(L)].dat"
fitX = "exponents/fit_log(magabs_Tc_X)[log(L)].dat"

equatCv = "y = -0.098 x - 0.184"
equatX = "y = -0.106 x - 0.376"

set terminal png size 1200,700 enhanced fontscale 2
set pointsize 2.5
set xlabel "log(L)"
set ylabel "log(<|{m}|>_{crit})"
set output "figures/beta.png"

set key top right

plot \
    fileMax using (log($1)):(log($8)) with points title "Usant max(C_v)" pt 7, \
    fileMax using (log($1)):(log($9)) with points title "Usant max(susc.)" pt 9, \
    fitC using 1:2 with lines title equatCv, \
    fitX using 1:2 with lines title equatX
