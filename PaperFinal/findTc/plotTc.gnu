fileMax = "maximums.dat"
fileFit = "fitC.dat"

set terminal png size 1200,700 enhanced fontscale 2
set pointsize 2.5
set xlabel "1/L [espins^{-1}]"
set ylabel "Temperatura crítica [u.r.]"
set output "temperaturaCritica.png"

set key top left

plot fileMax using (1/$1):2:3 with yerrorbars title "C_v", \
     fileMax using (1/$1):4:5 with yerrorbars title "susceptibilitat", \
     fileFit using 1:2 with lines title "", \
     fileFit using 1:3 with lines title ""


     