file = "dat/averages.dat"

folder = "plots/"

set terminal png
set xlabel "Temperature [r.u.]"

labels = "Temperature   Energy   Energy-squared   Magnetization   Magnetization-squared   Magnetization-absolute   Specific-heat   Magnetic-susceptibility"

do for [i = 1:8:1] {
    set title word(labels, i)
    set output folder . word(labels, i) . ".png"
    set ylabel word(labels, i)." [r.u.]"
    plot file u 1:i w l title ""

}