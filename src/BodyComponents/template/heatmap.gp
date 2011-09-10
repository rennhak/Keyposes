reset

set size 5,5
set ticslevel 0
set font 'Helvetica,60'

set isosample 2, 30
set parametric

set style line 1 lw 3
set style line 2 palette lt 1 lw 240
set style line 3 palette lt 1 lw 240
set style line 4 palette lt 1 lw 240
set style line 5 palette lt 1 lw 240
set style line 6 palette lt 1 lw 240
set style line 7 palette lt 1 lw 240
set style line 8 palette lt 1 lw 240
set style line 9 palette lt 1 lw 240
set style line 10 palette  lt 1 lw 240
set style line 11 palette  lt 1 lw 240
set style line 12 palette  lt 1 lw 240
set style line 13 palette  lt 1 lw 240
set style line 14 lt 1 lw 10 lc rgb 'red'


dx = 0.3 # Thickness of the walls
set border 1+2+4+8+16+32+64+256+512


set grid
set border
set pointsize 1.75
set autoscale

set key outside

set xlabel 'Frames' font "Helvetica,60"
set ylabel 'Components' font "Helvetica,60"
set zlabel 'Normalized Curvature' font "Helvetica,60"

set ytics 1

set yrange [0:13]

#set view 70, 20, 1, 1
#set samples 51, 51
#set hidden3d offset 1 trianglepattern 3 undefined 1 altdiagonal bentover

# set palette rgbformulae 33,13,10
set palette rgbformulae 22,12,-32
#set palette defined (0 "green", 0.2 "blue", 0.4 "orange", 0.6 "brown", 0.8 "yellow", 1 "red")

set output 'frame.eps'
#set terminal x11 persist
set terminal postscript eps color solid "Helvetica,60"
set title '' font "Helvetica,30"


set view map 
set multiplot 


splot 'model_04/left/upper_arms/frenet_frame_kappa_plot.gpdata'   using 1:(1):2   w lines linestyle 2   ti '(1) Left upper arm (Model 4)',\
      'model_04/right/upper_arms/frenet_frame_kappa_plot.gpdata'  using 1:(2):2   w lines linestyle 3   ti '(2) Right upper arm (Model 4)',\
      'model_04/left/thighs/frenet_frame_kappa_plot.gpdata'      using 1:(3):2    w lines linestyle 4   ti '(3) Left thigh (Model 4)',\
      'model_04/right/thighs/frenet_frame_kappa_plot.gpdata'     using 1:(4):2    w lines linestyle 5   ti '(4) Right thigh (Model 4)',\
      'model_08/left/fore_arms/frenet_frame_kappa_plot.gpdata'   using 1:(5):2    w lines linestyle 6   ti '(5) Left forearm (Model 8)',\
      'model_08/right/fore_arms/frenet_frame_kappa_plot.gpdata'  using 1:(6):2    w lines linestyle 7   ti '(6) Right forearm (Model 8)',\
      'model_08/left/shanks/frenet_frame_kappa_plot.gpdata'      using 1:(7):2    w lines linestyle 8   ti '(7) Left shank (Model 8)',\
      'model_08/right/shanks/frenet_frame_kappa_plot.gpdata'     using 1:(8):2    w lines linestyle 9   ti '(8) Right shank (Model 8)',\
      'model_12/left/hands/frenet_frame_kappa_plot.gpdata'       using 1:(9):2    w lines linestyle 10  ti '(9) Left hand (Model 12)',\
      'model_12/right/hands/frenet_frame_kappa_plot.gpdata'      using 1:(10):2   w lines linestyle 11  ti '(10) Right hand (Model 12)',\
      'model_12/left/feet/frenet_frame_kappa_plot.gpdata'        using 1:(11):2   w lines linestyle 12  ti '(11) Left foot (Model 12)',\
      'model_12/right/feet/frenet_frame_kappa_plot.gpdata'       using 1:(12):2   w lines linestyle 13  ti '(12) Right foot (Model 12)',\
      'model_12/right/feet/dmps_frenet_frame.gpdata' w xerrorbars lt 1 pt 7 ps 8 ti 'Keyposes/Turningposes',\
      'line.gpdata' w lines linestyle 14 ti 'Current frame'

# set xrange [0:900]
# set yrange [0:11]
# set zrange [0:1]
# set trange [1:10]
# 
# #reset
# unset border
# unset xtics
# unset ytics 
# unset key 
# 
# set xlabel ""
# set ylabel ""
# set zlabel ""
# 
# set view map
# 
# const=1
# plot const,t,const

unset multiplot

