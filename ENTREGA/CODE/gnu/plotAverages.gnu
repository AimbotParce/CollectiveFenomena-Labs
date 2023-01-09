# A single gnuplot for everything

folderIn = "dat/averages/"
folderOut = "plots/"

docPrefix = "averages_L"
# nums = "12 24 36 48 60 72"
docSuffix = ".dat"

set terminal png size 1200,700 enhanced fontscale 2
set pointsize 2.5
set xlabel "Temperature [u.r.]"

# This program will generate 8 plots for each L
labels = "Temperatura   Energia   Energia^2   Magnetització   Magnetització^2   Magnetització(abs)   C_v   Susceptibilitat"
fileNames = "temperatura energia energia2 magnetitzacio magnetitzacio2 magnetitzacioAbs cv susceptibilitat"
do for [L = 12:72:12] {
    file = folderIn . docPrefix . L . docSuffix
    do for [i = 1:8:1] {
        # set title word(labels, i)
        set output folderOut . docPrefix . L . "_" . word(fileNames, i) . ".png"
        set ylabel word(labels, i)." [u.r.]"
        plot file using 1:i with linespoints title ""
    }
}

# Then generate 8 plots for each quantity comparing all L

do for [i = 1:8:1] {
    # set title word(labels, i)
    set output folderOut . word(fileNames, i) . ".png"
    set ylabel word(labels, i)." [u.r.]"
    plot for [L = 12:72:12] folderIn . docPrefix . L . docSuffix using 1:i with linespoints title "L = ".L
}