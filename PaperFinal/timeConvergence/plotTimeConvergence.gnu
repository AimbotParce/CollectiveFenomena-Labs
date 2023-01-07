tempStrings = "1.5  2.0  2.3  2.7  3.0"

set terminal png size 1200,700 enhanced fontscale 2
set pointsize 2.5
set xlabel "Iteracions"
set key outside bottom

# Energy plot
set output "energyConvergence.png"
set ylabel "Energia [u.r.]"

plot for [i=1:5] "T".word(tempStrings, i).".norm" using 1:2 every ::::2999 with lines lw 2 title "T = ".word(tempStrings,i)

# Magnetization plot
set output "magnetizationConvergence.png"
set ylabel "Magnetització [u.r.]"

set xlabel "Centenars d'iteracions"
plot for [i=1:5] "T".word(tempStrings, i).".norm" using ($1/100):3 every ::::9999 with lines lw 2 title "T = ".word(tempStrings,i)