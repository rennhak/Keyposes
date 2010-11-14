#!/usr/bin/ruby
#


# = Libraries: Mathematics
require 'gsl'
require 'rbgsl'
require 'narray'

# = Libraries: Plotting
require 'rubygems'
require 'gnuplot'
require 'gsl/gnuplot'



# = The class PCA provides the functionality of calculating the Principle Component Analysis for given vectors.
#   For details please see here: http://en.wikipedia.org/wiki/Principal_component_analysis
#
#   Ruby Library Dependencies: GSL, NArray
#
class PCA # {{{

  # = Initialize function for the PCA class 
  def initialize # {{{

    # Simple lookup table to speed up the factorials calculation. Starts with index 0, 0!=1, 1!=1, 2!=2 etc.
    @factorials = [ 1, 1, 2, 6, 24, 120, 720 ]

  end # of def initialize }}}


  # = The mean function calculates the average or mean of the input set
  #   \bar{X} = \frac{\sum^{n}_{i=1}{X_i}}{n}
  #
  # @param set Array of elements of type int or float
  # @returns float of mean value
  def mean set # {{{
    m = 0.0
    set.each { |i| m += i.to_f }
    m / set.length.to_f
  end # of def mean }}}


  # = The standard_devation function calcualtes SD or the mathematical standard deviation
  #   "A measure of how spread out the data is"
  #   "The average distance from the mean of the data set to a point"
  #   s = \sqrt{ \frac{ \sum^{n}_{i=1}{ (X_i - X^{-})^2 }  }{ (n-1) }  }
  #   Standard deviation over a population of n-1
  #
  #   @param set Array of elements of type int or float
  #   @returns float of standard_deviation
  def standard_deviation set # {{{
    divisor    = 0.0
    x_bar      = mean( set ) # mean of the input set

    set.each_with_index { |x, n| divisor += ( x.to_f - x_bar ) ** 2 }

    sd         = divisor.to_f / ( set.length - 1 )
  end # }}}


  # = The function variance calcualtes the variance of a given set
  def variance set # {{{
    standard_deviation( set ) ** 2
  end # of def variance }}}


  # = Measures the difference between two dimensions (data sets)
  def covariance set1, set2, in_english = false # {{{
    x_bar, y_bar  = mean( set1 ), mean( set2 )
    divisor       = 0.0

    0.upto( set1.length ) do |i|

      xx          = set1[i].to_f - x_bar
      yy          = set2[i].to_f - y_bar
      compl       = xx * yy

      divisor    += compl
    end

    cov           = divisor.to_f / ( set1.length - 1 )

    if( in_english )
      output      = "Both dimensions "

      output     += "increase with each other."                           if( cov > 0  )
      output     += "are independent of each other."                      if( cov == 0 )
      output     += "don't corrolate. One increases the other decreases." if( cov < 0  )

      puts output
    end

    cov
  end # of def covariance }}}


  # = Calculates the factorial of a given number n
  # see e.g. http://en.wikipedia.org/wiki/Factorial
  # Iterative solution with lookup table.
  #
  # FIXME: Recursive solution seems faster according to http://rosettacode.org/wiki/Factorial
  #
  # @warn Works only with integers
  def factorial n # {{{
    #
    # e.g. 5! = 5 * 4 * 3 * 2 * 1 = 120
    #      0! = 1
    #      1! = 1
    #      2! = 1 * 2 = 2
    #      3! = 1 * 2 * 3 = 6
    #      6! = 720
    #      7! = 5040
    #      8! = 40320

    result = 1

    # n = starts with 1..n
    # Naive implementation with lookup table for speedup (@factorials) .. starts with 0..n-1
    if( @factorials[ n ].nil? )

      1.upto(n) do |i|
        result          *= i.to_i
        @factorials[n]   = result
      end

    else
      # we can do an lookup
      result             = @factorials[ n ].to_i
    end # of if( @factorials[ n ].nil? )

    result
  end # }}}


  # = Calculates how many covarance values are calculatable in a given matrix with n dimensions
  # e.g. (3 dimensional data set x,y,z) -> cov(x,y), cov(x,z), cov(y,z)
  # cov_values = \frac{n!}{(n-2)! * 2}
  #
  # @param n Rank of the nxn matrix.
  # @returns How many covarance values are calculatable of a give nxn matrix.
  def how_many_covariance_values? n # {{{
    cov_values = factorial( n ) / ( factorial(n-2) * 2 )
  end # of def how_many_covariance_values? dimensions }}}


  # = The function covariance_matrix creates a said matrix from a given arbitrary input of nxn matrix
  # see page 8 in the pdf
  # input: e.g. [ [1,2,3], [2,3,4], [5,6,7] ]
  # shape: n x n
  #
  # Depends: Ruby GSL
  #
  # @param input Accepts a GSL::Matrix type where each column is one dimension and each row is a data set
  # @returns Covariance matrix of the type GSL::Matrix with the rank nxn
  def covariance_matrix input # {{{

    #         | a1 b1 c1 d1 |
    # input = | a2 b2 c2 d2 |   <- Input of 4 dimensional data with each 3 values
    #         | a3 b3 c3 d3 |

    # Since x denotes the input dimensions (n) our covariance matrix will be of rank n x n
    y, x    = input.shape      # determine rank

    # puts "covariance_matrix -> input size #{input.shape.join(", ").to_s}"

    result  = GSL::Matrix.alloc( x, x )

    # Fill the covariance matrix according to the schema of page 8
    0.upto( x-1 ) do |i|
      0.upto( x-1 ) do |j|
        #puts "i: #{i.to_s} j: #{j.to_s}"
        result[i,j] = covariance( input.column(i).to_a, input.column(j).to_a )
        #puts "Result: #{result[i,j].to_s}"
      end # 0.upto( x-1 ) do |j|
    end # of 0.upto( x-1 ) do |i|

    result
  end # def covmatrix }}}


  # = The function substract_mean will ajust the data to be useable for PCA. This is done by
  # substracting the mean of the set so that the mean of the new set is zero
  #
  # @param set Accepts array containing floats or integers
  # @returns Array, containing the adjusted set where each element has been substracted with the mean of the set
  def substract_mean set # {{{
    m       = mean( set )
    result  = set.collect { |n| n-m }
    # new_m   = mean( result )
    result
  end # of def substract_mean set }}}

  # = The function add_mean will ajust the data to be useable for restoring PCA processed data. This is done by
  # adding back the mean of the set.
  #
  # @param set Accepts array containing floats or integers
  # @returns Array, containing the adjusted set where each element has been substracted with the mean of the set
  def add_mean set # {{{
    m       = mean( set )
    result  = set.collect { |n| n+m }
    result
  end # of def add_mean set }}}

  def add_original_mean orignal_set, transformed_set # {{{
    m       = mean( orignal_set )
    result  = transformed_set.collect { |n| n+m }
    result
  end # of def add_mean set }}}

  # = Graph creates a plot and dumps it to the defined file of the arguments provided
  def graph x, y, filename = "/tmp/graph.png" # {{{
    GSL::graph([ x, y ], "-T png -C -X 'X-Values' -Y 'Y-Values' -L 'Data' -S 2 -m 0 --page-size a4 > #{filename.to_s}") 
  end # of def graph }}}

  # = Function pca takes input of arbitrary numbers (array containing arrays) and does a PCA extraction of the required dimensions
  # @param input Array of arrays. Each sub-array contains integers or floats. e.g. [ [x1, x2, x3,...], [y1,y2,y3,....], [z1,z2,....]] 
  # @param reduce_dimensions Integer, number of dimension which to reduce from the original. Resulting dimensions are n-p in total (n = orign. dimensions, p = dimensions to reduce).
  # @returns An array containing "Array of arrays" with data as first, eigen_values as second and finally eigen_vectors as last element.
  def do_pca input, reduce_dimensions # {{{

    original                      = input.dup

    # puts "do_pca -> Size of input #{original.size.to_s}"

    # substract mean from input data
    input.collect! { |subarray| substract_mean( subarray ) }

    # puts "input:"
    # p input 

    # Convert the subarrys into a GSL matrix
    matrix                        = GSL::Matrix.alloc( *input ).transpose

    # puts "Matrix:"
    # p matrix
    # Determine the covariance matrix from the mean reduced input
    cov_matrix                    = covariance_matrix( matrix )

    # p cov_matrix

    # puts "do_pca -> Size of covariance matrix #{cov_matrix.size.to_s}"
    # puts "do_pca -> Doing eigne system calculation"
    # Extract eigen-values and -vectors via GSL
    eigen_values, eigen_vectors   = cov_matrix.eigen_symmv

    # p eigen_values
    # p eigen_vectors

    # puts "do_pca -> Sorting eigen values and vectors now"
    # Sort in-place the eigen-vectors or importance (most to least)
    GSL::Eigen.symmv_sort eigen_values, eigen_vectors, GSL::Eigen::SORT_VAL_DESC

    #eigen_values.to_a.each_index do |i|
    #  printf "l = %.3f\n", eigen_values.get(i)
    #  eigen_vectors.get_col(i).printf "%.3f"
    #  puts
    #end

    # Calculate the finaldata with all eigenvectors
    if( reduce_dimensions <= 0 )
      #puts "Using all dimensions"
      row_feature_vector            = eigen_vectors
    else
      # reduce 1 or more
      if( eigen_vectors.size.first <= reduce_dimensions )
        raise ArgumentError, "You cannot reduce the dimensions of the eigen vector matrix by #{reduce_dimensions.to_s} because the matrix is only of size #{eigen_vectors.size.join(",").to_s}."
      else
        #puts "Reducing dimension by #{reduce_dimensions.to_s}"
        x_size, y_size                = eigen_vectors.size
        y_size                       -= reduce_dimensions

        row_feature_vector            = GSL::Matrix.alloc( x_size, y_size )
        0.upto( y_size-1 ) { |y| row_feature_vector.set_col( y, eigen_vectors.get_col(y) ) }

      end # of if( eigen_vectors.size.first <= reduce_dimensions )
    end # of if( reduce_dimensions <= 0 )

    row_feature_vector = row_feature_vector.transpose

    row_data_adjust               = matrix.transpose
    final_data                    = row_feature_vector * row_data_adjust
    row_original_data             = row_feature_vector.transpose * final_data

    # Split matrix into subarrays again and add back the substracted mean
    result                        = []
    0.upto( row_original_data.size.first - 1 ) do |n|
      array = row_original_data[n].to_a
      add_original_mean( original[n], array )
      result << array
    end

    [ result, eigen_values, eigen_vectors ]
  end # of def do_pca }}}


  # = The function array_of_arrays_to_eigensystem converts the external data structure of type "array of arrays" to a eigensystem (GSL)
  # @param data Array of arrays. Each sub-array contains integers or floats.
  # @returns Array containing as first element the extracted and eigen values and as second (and last) element the corresponding eigen vectors
  def array_of_arrays_to_eigensystem data, sort = true
    # Convert the subarrys into a GSL matrix
    matrix                        = GSL::Matrix.alloc( *data ).transpose
    cov_matrix                    = covariance_matrix( matrix )
    #p cov_matrix
    # Extract eigen-values and -vectors via GSL
    eigen_values, eigen_vectors   = cov_matrix.eigen_symmv

    if( sort )
      # Sort in-place the eigen-vectors or importance (most to least)
      GSL::Eigen.symmv_sort eigen_values, eigen_vectors, GSL::Eigen::SORT_VAL_DESC
    end

     #eigen_values.to_a.each_index do |i|
     #  printf "l = %.3f\n", eigen_values.get(i)
     #  eigen_vectors.get_col(i).printf "%.3f"
     #  puts
     #end
    [ eigen_values, eigen_vectors ]
  end


  # = The function covariance_matrix_gnuplot plots the cov. matrix of given data to a gnuplot script file.
  # @param data Array of arrays. Each sub-array contains integers or floats.
  # @param filename Accepts string which represents the full path (absolute) with filename and extension (e.g. /tmp/file.ext) of where to store the gnuplot script.
  def covariance_matrix_gnuplot data, filename = "/tmp/tmp.plot.gp" # {{{
    eigen_values, eigen_vectors = array_of_arrays_to_eigensystem( data ) 

    File.open( filename.to_s, "w" ) do |f|
      f.write( "reset\n" )
      #f.write( "set ticslevel 0\n" )
      f.write( "set xtics 1\n" )
      f.write( "set mxtics 0\n" )
      f.write( "set style line 1 lw 3\n" )
      f.write( "set grid\n" )
      f.write( "set border\n" )
      f.write( "set pointsize 3\n" )

      f.write( "set xlabel 'Eigenvalue (Descending order)'\n" )
      f.write( "set ylabel 'Energy'\n" )
      f.write( "set autoscale\n" )
      f.write( "set font 'arial'\n" )
      # f.write( "set key left box\n" )
      f.write( "set output\n" )
      f.write( "set terminal x11 persist\n" )

      f.write( "plot '-' w line lw 2\n" )

      eigen_values.to_a.each_index do |i|
        content = sprintf( "%e %e\n", (i + 1).to_s, eigen_values.get( i ) )
        f.write( content )
      end
    end # of File.open
  end # of def interactive_gnuplot }}}


  # = The function normalize takes any input array containing floats/integers and normalizes them between a desired range
  # @param data Accepts an array containing floats or integers of which to normalize to new_min and new_max
  # @param new_min Accepts an integer or float as lower boundary for the normalization (inclusive)
  # @param new_max Accepts an integer or float as upper boundary for the normalization (inclusive)
  # @returns Array containing the newly normalized data
  #
  # Inspired by http://stackoverflow.com/questions/695084/how-do-i-normalize-an-image
  def normalize data, new_min = 0, new_max = 1, old_min = nil, old_max = nil # {{{
    old_min, old_max  = data.min, data.max if( old_min.nil?  && old_max.nil? ) 
    old_range         = old_max - old_min

    new_range         = new_max.to_f - new_min.to_f

    # ymin + (x-xmin) * (yrange.to_f / xrange) 

    data.collect! do |n|
      # where in the old scale is this value (0...1)
      scale   = ( n - old_min ) / old_range

      # place this scale in the new range
      new_value = ( new_range.to_f * scale ) + new_min
    end

    data
  end # def normalize data, new_min = 0, new_max = 1 }}}
 

  # = The function transform_basis changes the data from a standard basis to a basis with the prinicipal components as u,v,w
  #   "Change of basis to principal axis"
  # 
  # @param pca_result Output from the do_pca function - the pca transformed data
  # @param eigen_values Output from the do_pca function - the extracted eigen_values of the pca input data
  # @param eigen_vectors Output from the do_pca function - the extracted eigen_vectors (principle components) of the pca processed data
  # @returns Array of arrays - Transformed data to the new principle component based basis ready for use with the gnuplot functions.
  def transform_basis pca_result, eigen_values, eigen_vectors # {{{

    # establish identity matrix "C"
    original_basis          = GSL::Matrix.identity( eigen_vectors.size1 )

    # create matrix with all eigen_vectors and invert it
    new_basis               = eigen_vectors             # "D"
    new_basis_inv           = eigen_vectors.invert      # "D^{-1}"

    # T = D^{-1} * C 
    transformation_matrix   = new_basis_inv * original_basis

    # Transform data
    result_final            = ( transformation_matrix * GSL::Matrix.alloc( *pca_result ) )

    # You could verify that this is correct by =>  T^{-1} * result_final = result
    result_final            = result_final.to_na.to_a

    
    result_final
  end # of def transform_basis }}}


  # = The function clean_data looks through the data after pca and pc basis transform and trys to clean out the [0,0,0...]'s everywhere.
  #   The 0's are created due to numerical errors which are 10^{-15} etc.
  #
  # @param transform_basis_result Array of arrays - Output of the transform_basis function.
  # @param result_dimensions Accepts Integer with the amount of desired output dimensions (e.g. 3 for a 3D plot (even if e.g. Z coords are zero). or 2 for 2D plot)
  # @returns Array of arrays - Cleaned up data where 0 vectors have been removed.
  def clean_data transform_basis_result, result_dimensions # {{{

    # Cleanup data from the very small values 10^{-15} etc. (numerical errors)
    transform_basis_result.collect! do |array| 
      array.collect! { |i| ( i.abs <= 10**-12 ) ? ( nil ) : ( i ) }
      array
    end

    # Check desired output dimensions size and e.g. create an empty z field
    if( result_dimensions == 3 ) # we want 3D even if z's are all 0.0
      new    = []
      0.upto( transform_basis_result[2].length - 1 ) { |n| new << 0.0 }

      zero = transform_basis_result[2]
      zero.compact!
      transform_basis_result[2] = new if( zero.empty? )
    end

    # purge nil's and delete empty arrays
    transform_basis_result.collect!   { |x| x.compact }
    transform_basis_result.delete_if  { |x| x.empty? }

    transform_basis_result
  end # of def clean_data }}}



  # = The function reshape_data takes input of the long or the short form and reshapes it into the other
  #   long form:   [ [x1,x2,x3,...], [y1,y2,y3,....], [z1,z2,z3,....] ] 
  #   short form:  [ [x1,y1,z1], [x2,y2,z2], [x3,y3,z3],.... ]
  #  
  # @param to_long   Accepts Boolean
  # @param to_short  Accepts Boolean
  # @returns Array in the shape as described in the function description
  def reshape_data data, to_long, to_short # {{{
    raise ArgumentError, "Not both equal true allowed" if( to_long and to_short )
    raise ArgumentError, "Not both equal false allowed" if( not to_long and not to_short )
    raise ArgumentError, "Not both equal nil allowed" if( to_long.nil? and to_short.nil? )

    result = []

    if( to_long )
      # we expect data to be in short form
      result << []
      result << []
      result << []

      data.each do |x,y,z|
        result[0] << x
        result[1] << y
        result[2] << z
      end
    end

    if( to_short )
      # we expect data to be in long form
      tmp = data.shift
      result = tmp.zip( *data )
    end

    result
  end # of def reshape_data }}}


  # = The function eigenvalue_energy_gnuplot plots the accumulated energy of all eigenvalues to a gnuplot script.
  # @param data Array of arrays. Each sub-array contains integers or floats.
  # @param filename Accepts string which represents the full path (absolute) with filename and extension (e.g. /tmp/file.ext) of where to store the gnuplot script.
  def eigenvalue_energy_gnuplot data, filename = "/tmp/tmp.plot.gp" # {{{

    eigen_values, eigen_vectors = array_of_arrays_to_eigensystem( data ) 

    File.open( filename.to_s, "w" ) do |f|
      f.write( "reset\n" )
      f.write( "set xtics 1\n" )
      f.write( "set mxtics 0\n" )
      # f.write( "set ytics 0.1\n" )
      f.write( "set yrange [0:1]\n" )
      f.write( "set style line 1 lw 3\n" )
      f.write( "set grid\n" )
      f.write( "set border\n" )
      f.write( "set pointsize 3\n" )

      f.write( "set xlabel 'Eigenvalues (Descending order)'\n" )
      f.write( "set ylabel 'Accumulation of Energy ( 0 <= e <= 1 )'\n" )
      f.write( "set autoscale\n" )
      f.write( "set font 'arial'\n" )
      f.write( "set key left box\n" )
      f.write( "set output\n" )
      f.write( "set terminal x11 persist\n" )

      # f.write( "plot '-' w steps lw 2\n" )
      f.write( "plot '-' w lines lw 2\n" )

      # TODO: ERROR, the sum values for the energy don't add up to 1 but just slightly below due to
      # the 0-1 normalization. This is not correct. - FIXME
      # Normalize the data between 0 and 1 BUT make sure the total sum of the elements in the array is 1
      sum_of_evn  = eigen_values.to_a.dup.inject() { |result, element| result + element }
      evn         = normalize( eigen_values.to_a, 0, 1, eigen_values.to_a.min, sum_of_evn )

      sum = 0
      evn.each_index do |i|
        sum += evn[ i ]
        content = sprintf( "%e %e\n", (i + 1).to_s, sum.to_s )
        f.write( content )
      end
    end # of File.open
  end # of def interactive_gnuplot }}}


  # = The function interactive_gnuplot opens an X11 window in persist mode to view the data with the mouse.
  # @param data Accepts array of arrays. Each subarray is filled with integers or floats (needs to be uniform/of same length)
  #             Expects the data to be of form: [ [x1, y1, z1], [x2, y2, z2], ....]
  # @param data_printf Accepts a formatting instruction like printf does, e.g. "%e, %e, %e\n" etc.
  # @param labels Accepts an array containing strings with the labels for each subarray of data, e.g. %w[Foo Bar Baz]
  # @param filename Accepts string which represents the full path (absolute) with filename and extension (e.g. /tmp/file.ext)
  def interactive_gnuplot data, data_printf, labels, filename = "/tmp/tmp.plot.gp", eigen_values = nil, eigen_vectors = nil # {{{

    File.open( filename.to_s, "w" ) do |f|
      f.write( "reset\n" )
      f.write( "set ticslevel 0\n" )
      f.write( "set mxtics 2\n" )
      f.write( "set mytics 2\n" )
      f.write( "set style line 1 lw 3\n" )
      f.write( "set grid\n" )
      f.write( "set border\n" )
      f.write( "set pointsize 1\n" )

      f.write( "set xlabel '#{labels.shift.to_s}'\n" )
      f.write( "set ylabel '#{labels.shift.to_s}'\n" ) if( labels.length != 0 )
      f.write( "set zlabel '#{labels.shift.to_s}'\n" ) if( labels.length != 0 )
      f.write( "set autoscale\n" )
      f.write( "set font 'arial'\n" )
      f.write( "set key left box\n" )
      f.write( "set hidden3d\n" )
      f.write( "set output\n" )
      f.write( "set terminal x11 persist\n" )
      f.write( "set title 'Graph'\n" )

      unless( eigen_values.nil? and eigen_vectors.nil? )
        # Add information about PC axis
        # set arrow 1 from  1.9,-1.0 to 2.01,1.8
        0.upto( eigen_vectors.size1 - 1 ) do |n|
          i          = (eigen_values.to_na.to_a)[n]
          x1, y1, z1 = eigen_vectors.get_col( n ).to_a
          x2, y2, z2 = (x1*i), (y1*i), (z1*i)
          #f.write( "set arrow #{(n+1).to_s} from #{x1},#{y1},#{z1} to #{x2},#{y2},#{z2}\n" )
        end

        #f.write( "set arrow 1 from \n" )
      end


      f.write( "splot '-' w linespoints lt 1 pt 6\n" )

      # TODO: Rewrite - this is too messy
      # Construct data array call string. We have -> data (array of arrays) but we want -> data[0][i], ... etc.
      d = []

      0.upto( data.length - 1 ) { |n| d << "data[#{n.to_s}][i]" }

      data.each do |array|
        #data.first.each_index do |i|
        #  nd = d.collect{|item| eval( item ).to_f }
        #  content = sprintf( data_printf.to_s, *nd ) 
        #  f.write( content )
        #end # of data.first.each_index

        f.write( array.join( " " ) + "\n" )
      end # of data.each do |array|

    end # of File.open
  end # of def interactive_gnuplot }}}

end # of class PCA }}}


# Direct invocation
if __FILE__ == $0 # {{{

   pca = PCA.new

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
#
#  m = GSL::Matrix.alloc( pupils_study_hours, marks_pupils_got ).transpose
#  # n = GSL::Matrix.alloc( pupils_study_hours, marks_pupils_got_inv ).transpose
#  # p pca.covariance( pupils_study_hours, marks_pupils_got, true )
#  # p pca.covariance_matrix( m )
#  # p pca.covariance_matrix( n )
#
#  # test data of page 8
#  a1 = [ 10, 39, 19, 23, 28 ]
#  a2 = [ 43, 13, 32, 21, 20 ]
#  a  = GSL::Matrix.alloc( a1, a2 ).transpose
#
#  b1 = [ 1, -1, 4 ]
#  b2 = [ 2, 1, 3  ]
#  b3 = [ 1, 3, -1 ]
#  b  = GSL::Matrix.alloc( b1, b2, b3 ).transpose
#
#  # 0.upto(100).each { |n|  p pca.factorial( n ) } 
#  # p pca.how_many_covariance_values?( 3 )
#  # p pca.covariance_matrix( b )
#
#  # Check if GSL is sane with example from page 11
#  c1 = [ 3, 0, 1 ]
#  c2 = [ -4, 1, 2 ]
#  c3 = [ -6, 0, -2 ]
#  c  = GSL::Matrix.alloc( c1, c2, c3 )
#  # eigen_values, eigen_vectors = c.eigen_symmv
#  # p eigen_values
#  # p eigen_vectors 
#
  # === PCA example
  x = [2.5, 0.5, 2.2, 1.9, 3.1, 2.3, 2.0, 1.0, 1.5, 1.1 ]
  y = [2.4, 0.7, 2.9, 2.2, 3.0, 2.7, 1.6, 1.1, 1.6, 0.9 ]
  z = [1.0, 5.7, 1.9, 22.2, 31.0, 22.7, 0.6, 5.1, 1.0, 1.9 ]
#  z = [0,   0,   0,   0,   0,   0,   0,   0,   0,   0]

  #pca.covariance_matrix_gnuplot( [x,y], "cov.gp" )
  #pca.eigenvalue_energy_gnuplot( [x,y], "energy.gp" )


  # Change Basis to new Principal Axis
  # http://www.khanacademy.org/video/lin-alg--changing-coordinate-systems-to-help-find-a-transformation-matrix?playlist=Linear%20Algebra

###  input                                 = [x, y, z]
###  result, eigen_values, eigen_vectors   = pca.do_pca( input, 1 )
###  result_final                          = pca.transform_basis( result, eigen_values, eigen_vectors )
###
###  pca.interactive_gnuplot( pca.reshape_data( result_final, false, true ), "%e %e %e\n", %w[PC1 PC2 PC3],  "plot.gp", eigen_values, eigen_vectors )
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
#  age     = [  8, 10,  6, 11,  8,  7, 10,  9, 10,  6, 12,  9 ]
#  weight  = [ 64, 71, 53, 67, 55, 58, 77, 57, 56, 51, 76, 68 ]
#  height  = [ 57, 59, 49, 62, 51, 50, 55, 48, 42, 42, 61, 57 ]
#
#  new = pca.do_pca( [ age, weight, height ], 0 )
 
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


