#!/usr/bin/ruby
#


# = Libraries
require 'gsl'
require 'rbgsl'
require 'narray'


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
  # @param input Array of arrays. Each sub-array contains integers or floats.
  # @param reduce_dimensions Integer, number of dimension which to reduce from the original. Resulting dimensions are n-p in total (n = orign. dimensions, p = dimensions to reduce).
  # @returns Array of arrays. Returns the dimensionaly reduced data.
  def do_pca input, reduce_dimensions # {{{

    original                      = input.dup

    # substract mean from input data
    input.collect! { |subarray| substract_mean( subarray ) }

    # Convert the subarrys into a GSL matrix
    matrix                        = GSL::Matrix.alloc( *input ).transpose

    # Determine the covariance matrix from the mean reduced input
    cov_matrix                    = covariance_matrix( matrix )

    # Extract eigen-values and -vectors via GSL
    eigen_values, eigen_vectors   = cov_matrix.eigen_symmv

    # Sort in-place the eigen-vectors or importance (most to least)
    GSL::Eigen.symmv_sort eigen_values, eigen_vectors, GSL::Eigen::SORT_VAL_DESC

    # eigen_values.to_a.each_index do |i|
    #   printf "l = %.3f\n", eigen_values.get(i)
    #   eigen_vectors.get_col(i).printf "%.3f"
    #   puts
    # end

    # Calculate the finaldata with all eigenvectors
    if( reduce_dimensions <= 0 )
      row_feature_vector            = eigen_vectors
    else
      # reduce 1 or more
      if( eigen_vectors.size.first <= reduce_dimensions )
        raise ArgumentError, "You cannot reduce the dimensions of the eigen vector matrix by #{reduce_dimensions.to_s} because the matrix is only of size #{eigen_vectors.size.join(",").to_s}."
      else
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

    result
  end # of def do_pca }}}

end # of class PCA }}}


# Direct invocation
if __FILE__ == $0 # {{{

  pca = PCA.new

  # test of example page 4
  x1 = [1, 2, 4, 6, 12, 15, 25, 45, 68, 67, 65, 98]
  x2 = [0, 8, 12, 20]
  x3 = [8, 9, 11, 12]

  # p pca.mean x2
  # p pca.standard_deviation x2
  # p pca.variance x3
  # p pca.covariance x3, x2

  # covariance dictates that pupils_study_hours and marks_pupils_got should be positive (both
  # increase) -- should be negative with marks_pupils_got2
  # page 8
  pupils_study_hours      = [9,  15, 25, 14, 10, 18, 0,  16, 5,  19, 16, 20]
  marks_pupils_got        = [39, 56, 93, 61, 50, 75, 32, 85, 42, 70, 66, 80]
  marks_pupils_got_inv    = [59, 39, 13, 38, 50, 20, 90, 32, 80, 10, 16, 0]     # lets assume the more hours they study the worse their marks

  m = GSL::Matrix.alloc( pupils_study_hours, marks_pupils_got ).transpose
  # n = GSL::Matrix.alloc( pupils_study_hours, marks_pupils_got_inv ).transpose
  # p pca.covariance( pupils_study_hours, marks_pupils_got, true )
  # p pca.covariance_matrix( m )
  # p pca.covariance_matrix( n )

  # test data of page 8
  a1 = [ 10, 39, 19, 23, 28 ]
  a2 = [ 43, 13, 32, 21, 20 ]
  a  = GSL::Matrix.alloc( a1, a2 ).transpose

  b1 = [ 1, -1, 4 ]
  b2 = [ 2, 1, 3  ]
  b3 = [ 1, 3, -1 ]
  b  = GSL::Matrix.alloc( b1, b2, b3 ).transpose

  # 0.upto(100).each { |n|  p pca.factorial( n ) } 
  # p pca.how_many_covariance_values?( 3 )
  # p pca.covariance_matrix( b )

  # Check if GSL is sane with example from page 11
  c1 = [ 3, 0, 1 ]
  c2 = [ -4, 1, 2 ]
  c3 = [ -6, 0, -2 ]
  c  = GSL::Matrix.alloc( c1, c2, c3 )
  # eigen_values, eigen_vectors = c.eigen_symmv
  # p eigen_values
  # p eigen_vectors 

  # === PCA example
  x = [2.5, 0.5, 2.2, 1.9, 3.1, 2.3, 2.0, 1.0, 1.5, 1.1 ]
  y = [2.4, 0.7, 2.9, 2.2, 3.0, 2.7, 1.6, 1.1, 1.6, 0.9 ]

  new = pca.do_pca( [ x, y ], 1 )
  pca.graph( GSL::Vector.alloc(x), GSL::Vector.alloc(y)      , "graph.png" )
  pca.graph( GSL::Vector.alloc(new.first), GSL::Vector.alloc(new.last), "graph2.png" )


end # of if __FILE__ == $0 }}}


