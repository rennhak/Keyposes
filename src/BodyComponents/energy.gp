reset
set xtics 1
set mxtics 0
set yrange [0:1]
set style line 1 lw 3
set grid
set border
set pointsize 3
set xlabel 'Eigenvalues (Descending order)'
set ylabel 'Accumulation of Energy ( 0 <= e <= 1 )'
set autoscale
set font 'arial'
set key left box
set output
set terminal x11 persist
plot '-' w lines lw 2
1.000000e+00 9.038779e-01
2.000000e+00 9.780155e-01
3.000000e+00 9.780155e-01
