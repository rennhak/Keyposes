#!/usr/bin/ruby
#


require '../PCA.rb'


# Direct invocation
if __FILE__ == $0 # {{{

#   pca = PCA.new

#  # test of example page 4
#  x1 = [1, 2, 4, 6, 12, 15, 25, 45, 68, 67, 65, 98]
#  x2 = [0, 8, 12, 20]
#  x3 = [8, 9, 11, 12]
#
#  # p pca.mean x2
#  # p pca.standard_deviation x2
#  # p pca.variance x3
#  # p pca.covariance x3, x2
#
#  # covariance dictates that pupils_study_hours and marks_pupils_got should be positive (both
#  # increase) -- should be negative with marks_pupils_got2
#  # page 8
#  pupils_study_hours      = [9,  15, 25, 14, 10, 18, 0,  16, 5,  19, 16, 20]
#  marks_pupils_got        = [39, 56, 93, 61, 50, 75, 32, 85, 42, 70, 66, 80]
#  marks_pupils_got_inv    = [59, 39, 13, 38, 50, 20, 90, 32, 80, 10, 16, 0]     # lets assume the more hours they study the worse their marks


  # m = GSL::Matrix.alloc( pupils_study_hours, marks_pupils_got ).transpose
   #m = GSL::Matrix.alloc( pupils_study_hours, marks_pupils_got_inv ).transpose
   # p pca.covariance( pupils_study_hours, marks_pupils_got, true )
   #p pca.covariance_matrix( m )
#  # p pca.covariance_matrix( n )
#
#  # test data of page 8
#  a1 = [ 10, 39, 19, 23, 28 ]
#  a2 = [ 43, 13, 32, 21, 20 ]
#  a  = GSL::Matrix.alloc( a1, a2 ).transpose
#
  #b1 = [ 1, -1, 4 ]
  #b2 = [ 2, 1, 3  ]
  #b3 = [ 1, 3, -1 ]
  # b  = GSL::Matrix.alloc( b1, b2, b3 ).transpose

 
#  # 0.upto(100).each { |n|  p pca.factorial( n ) } 
#  # p pca.how_many_covariance_values?( 3 )
#  # p pca.covariance_matrix( b )
#
#  # Check if GSL is sane with example from page 11
  #c1 = [ 3, 0, 1 ]
  #c2 = [ -4, 1, 2 ]
  #c3 = [ -6, 0, -2 ]
  #c  = GSL::Matrix.alloc( c1, c2, c3 )
  #eigen_values, eigen_vectors = c.eigen_symmv
  #p eigen_values
  #p eigen_vectors 
#
  # === PCA example
#  x = [2.5, 0.5, 2.2, 1.9, 3.1, 2.3, 2.0, 1.0, 1.5, 1.1 ]
#  y = [2.4, 0.7, 2.9, 2.2, 3.0, 2.7, 1.6, 1.1, 1.6, 0.9 ]
#  z = [1.0, 5.7, 1.9, 22.2, 31.0, 22.7, 0.6, 5.1, 1.0, 1.9 ]
#  z = [0,   0,   0,   0,   0,   0,   0,   0,   0,   0]


  #pca.covariance_matrix_gnuplot( [x,y], "cov.gp" )
  #pca.eigenvalue_energy_gnuplot( [x,y], "energy.gp" )


  # Change Basis to new Principal Axis
  # http://www.khanacademy.org/video/lin-alg--changing-coordinate-systems-to-help-find-a-transformation-matrix?playlist=Linear%20Algebra

  #input                                 = [x, y, z]
  #result, eigen_values, eigen_vectors   = pca.do_pca( input, 1 )
  #result_final                          = pca.transform_basis( result, eigen_values, eigen_vectors )

###
  #pca.interactive_gnuplot( pca.reshape_data( result_final, false, true ), "%e %e %e\n", %w[PC1 PC2 PC3],  "plot.gp", eigen_values, eigen_vectors )
###
#  #pca.graph( GSL::Vector.alloc(x), GSL::Vector.alloc(y)      , "graph.png" )
#  #pca.graph( GSL::Vector.alloc(new.first), GSL::Vector.alloc(new.last), "graph2.png" )
#
#  #pca.interactive_gnuplot( [x,y,z], "%e %e %e\n", %w[X Y Z], "plot1.gp" )
#  #pca.interactive_gnuplot( [new[0], new[1], z], "%e %e %e\n", %w[X Y Z], "plot2.gp" )
#
#  #exit
#
#  # Using www.miislita.com/information-retrieval-tutorial/pca-spca-tutorial.pdf to demonstrate that
#  # doPCA works as expected
#  # http://docs.google.com/viewer?a=v&q=cache:rsPO4yD6T40J:www.miislita.com/information-retrieval-tutorial/pca-spca-tutorial.pdf+PCA+example&hl=en&pid=bl&srcid=ADGEEShfP_ke-gMSOF1Ab9vwPiGTgk75e9u186SDGvLLE6fvS8HkDFGAQt3qE3RHWkJm7moEu7--MDg5AGPOOk2oaRLTK_haAe8IvcmxTGgFN_8IV-UW3JA6bDuHfwVi9RSCK_WwZjT_&sig=AHIEtbSXlE4I4iFiwkSkoD2pBr1eNKuuyQ
#
  #age     = [  8, 10,  6, 11,  8,  7, 10,  9, 10,  6, 12,  9 ]
  #weight  = [ 64, 71, 53, 67, 55, 58, 77, 57, 56, 51, 76, 68 ]
  #height  = [ 57, 59, 49, 62, 51, 50, 55, 48, 42, 42, 61, 57 ]
#
  #new = pca.do_pca( [ age, weight, height ], 0 )
  #pca.covariance_matrix_gnuplot( [age,weight,height], "cov.gp" )
  #pca.eigenvalue_energy_gnuplot( [age,weight,height], "energy.gp" )
#  pca.covariance_matrix_gnuplot( new, "cov.gp" )
#  pca.eigenvalue_energy_gnuplot( new, "energy.gp" )

  #
##
#  IO.popen("gnuplot -persist -raise", "w") do |io|
#    io.printf( "reset\n" )
#    # io.printf( "set xtics 1\n" )
#    io.printf( "set ticslevel 0\n" )
#    #io.printf( "set xtics auto\n" )
#    io.printf( "set style line 1 lw 3\n" )
#    io.printf( "set grid\n" )
#    io.printf( "set border\n" )
#    io.printf( "set pointsize 3\n" )
#    io.printf( "set xlabel 'Age'\n" )
#    io.printf( "set ylabel 'Weight'\n" )
#    io.printf( "set zlabel 'Height'\n" )
#    io.printf( "set autoscale\n" )
#    io.printf( "set font 'arial'\n" )
#    io.printf( "set key left box\n" )
#    io.printf( "set hidden3d\n" )
#    io.printf( "set output\n" )
#    io.printf( "set terminal x11\n" )
#    # io.printf( "set term\n" )
#    # io.printf( "\n" )
#    
#    io.print("splot '-' w line\n")
#    age.each_index do |i|
#      io.printf( "%e %e 0, %e 0 %e, 0 %e %e\n", age[i], i.to_s, i.to_s, height[i], weight[i], i.to_s )
#      #io.printf( "\n" ) if( (i % 5) == 0 )
#    end
#    io.print("e\n")
#    io.flush
#  end

#  pca.interactive_gnuplot( [age, weight, height], "%e %e %e\n", %w[Age Weight Height],  "plot.gp" )
#
#  pca.interactive_gnuplot( new, "%e %e %e\n", %w[P1 P2 P3],  "plot2.gp" )
#
#  `gnuplot 'plot.gp' -`

end # of if __FILE__ == $0 }}}


