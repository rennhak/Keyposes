reset

set size 8,8

set ticslevel 0
set font 'Helvetica,60'

set isosample 2, 30
set parametric

set style line 1 lw 3
set style line 2 lt 1 lw 15 lc rgb 'blue'
set style line 3 lt 1 lw 15 lc rgb 'red'
set style line 4 lt 1 lw 15 lc rgb 'green'
set style line 5 lt 1 lw 15 lc rgb 'purple'
set style line 6 lt 1 lw 15 lc rgb 'orange'
set style line 7 lt 1 lw 15 lc rgb 'brown'
set style line 8 lt 1 lw 15 lc rgb '#483D8B'
set style line 9 lt 1 lw 15 lc rgb '#6B8E23'
set style line 10 lt 1 lw 15 lc rgb '#4682B4'
set style line 11 lt 1 lw 15 lc rgb '#66CDAA'
set style line 12 lt 1 lw 15 lc rgb '#FF1493'
set style line 13 lt 1 lw 15 lc rgb '#4B0082'
set style line 14 lt 1 lw 10 lc rgb 'red'

set grid
set border
set pointsize 1.75
set autoscale

set view 15,30,1
set hidden3d

set key outside

set xlabel 'Frames' font "Helvetica,60"
set ylabel 'Components' font "Helvetica,60"
set zlabel 'Normalized Curvature' font "Helvetica,60"

set ytics 1

set yrange [0:13]

set output 'frame.eps'
#set terminal x11 persist
set terminal postscript eps color solid "Helvetica,60"
set title '' font "Helvetica,30"

set multiplot 

splot 'model_04/left/upper_arms/frenet_frame_kappa_plot.gpdata'   using 1:(($1/$1)*1):2   w lines linestyle 2   ti '(1) Left upper arm (Model 4)',\
      'model_04/right/upper_arms/frenet_frame_kappa_plot.gpdata'  using 1:(($1/$1)*2):2   w lines linestyle 3   ti '(2) Right upper arm (Model 4)',\
      'model_04/left/thighs/frenet_frame_kappa_plot.gpdata'       using 1:(($1/$1)*3):2   w lines linestyle 4   ti '(3) Left thigh (Model 4)',\
      'model_04/right/thighs/frenet_frame_kappa_plot.gpdata'      using 1:(($1/$1)*4):2   w lines linestyle 5   ti '(4) Right thigh (Model 4)',\
      'model_08/left/fore_arms/frenet_frame_kappa_plot.gpdata'    using 1:(($1/$1)*5):2   w lines linestyle 6   ti '(5) Left forearm (Model 8)',\
      'model_08/right/fore_arms/frenet_frame_kappa_plot.gpdata'   using 1:(($1/$1)*6):2   w lines linestyle 7   ti '(6) Right forearm (Model 8)',\
      'model_08/left/shanks/frenet_frame_kappa_plot.gpdata'       using 1:(($1/$1)*7):2   w lines linestyle 8   ti '(7) Left shank (Model 8)',\
      'model_08/right/shanks/frenet_frame_kappa_plot.gpdata'      using 1:(($1/$1)*8):2   w lines linestyle 9   ti '(8) Right shank (Model 8)',\
      'model_12/left/hands/frenet_frame_kappa_plot.gpdata'        using 1:(($1/$1)*9):2   w lines linestyle 10  ti '(9) Left hand (Model 12)',\
      'model_12/right/hands/frenet_frame_kappa_plot.gpdata'       using 1:(($1/$1)*10):2  w lines linestyle 11  ti '(10) Right hand (Model 12)',\
      'model_12/left/feet/frenet_frame_kappa_plot.gpdata'         using 1:(($1/$1)*11):2  w lines linestyle 12  ti '(11) Left foot (Model 12)',\
      'model_12/right/feet/frenet_frame_kappa_plot.gpdata'        using 1:(($1/$1)*12):2  w lines linestyle 13  ti '(12) Right foot (Model 12)',\
      'model_12/right/feet/dmps_frenet_frame.gpdata'              using 1:(0):2           w xerrorbars lt 1 pt 7 ps 8 ti 'Keyposes/Turningposes',\
      'line.gpdata' w lines linestyle 14 ti 'Current frame'



unset multiplot

