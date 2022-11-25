# L should be defined as a parameter in the terminal

file = "dat/config.conf"
symbsize = 1.0

set size square

set xlabel "x"
set ylabel "y"

set xrange [-.5: L-0.5]
set yrange [-.5: L-0.5]

set terminal png
set output "dat/P1-config.png"
set pm3d map
unset colorbox

set palette gray

plot file matrix with image

