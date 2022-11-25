set title file
set xlabel "x"
set ylabel "p(x)"
set yrange [0:]

set terminal png
set output "dat/".file.".png"

plot file.".dat" using 1:2 smooth freq with boxes title ""