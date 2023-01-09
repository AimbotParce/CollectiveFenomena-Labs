cols = "L^{1/\nu}t  C/L^{\alpha/\nu}  X/L^{\gamma/\nu} magnetization(abs)/L^{\beta/\nu}"
outNames = "C X magnetization(abs)"

folder = "scaled/"
docPrefix = "averages_L"
docSuffix = ".dat"

folderOut = "figures/"

set terminal png size 1200,700 enhanced fontscale 2
set pointsize 2

xLab = word(cols, 1)
set xlabel xLab

do for [i=2:4] {
    yLab = word(cols, i)
    set ylabel yLab
    set output folderOut . word(outNames, i-1) . ".png"
    plot for [L = 12:72:12] folder . docPrefix . L . docSuffix u 1:i w lp title "L = " . L
}

