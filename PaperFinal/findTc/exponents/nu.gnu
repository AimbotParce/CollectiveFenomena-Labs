fileMax = "maximums.dat"
Cvfile = "exponents/fit_log(T_max_C - 2.266)[log(L)].dat" # slope=[[-1.16172582]] intercept=[0.36666913]
Xfile = "exponents/fit_log(T_max_X - 2.266)[log(L)].dat" # slope=[[-1.05836843]] intercept=[0.95203783]

set terminal png size 1200,700 enhanced fontscale 2
set pointsize 2.5
set xlabel "log(L)"
set ylabel "log(T_c^*-T_c)"
set output "figures/nu.png"

set key top right

plot \
    Cvfile using 1:2 with lines title "", \
    Xfile using 1:2 with lines title "", \
    fileMax using (log($1)):(log($2-2.266)):3 with yerrorbars title "Cv" pt 7, \
    fileMax using (log($1)):(log($4-2.266)):5 with yerrorbars title "susceptibilitat" pt 9, \
