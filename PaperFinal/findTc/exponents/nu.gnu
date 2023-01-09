fileMax = "maximums.dat"
Cvfile = "exponents/fit_log(TcC - 2.266)[log(L)].dat"
Xfile = "exponents/fit_log(TcX - 2.266)[log(L)].dat"

equatCv = "y = -1.160 x + 0.367"
equatX = "y = -1.060 x + 0.952"

set terminal png size 1200,700 enhanced fontscale 2
set pointsize 2.5
set xlabel "log(L)"
set ylabel "log(T_c^*-T_c)"
set output "figures/nu.png"

set key top right

plot \
    fileMax using (log($1)):(log($2-2.266)):3 with yerrorbars title "Usant C_v" pt 7, \
    fileMax using (log($1)):(log($4-2.266)):5 with yerrorbars title "Usant susc." pt 9, \
    Cvfile using 1:2 with lines title equatCv, \
    Xfile using 1:2 with lines title equatX, \
