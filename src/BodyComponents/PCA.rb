#!/usr/bin/ruby
#

###
#
# File: PCA.rb
#
######


###
#
# (c) 2009-2011, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       PCA.rb
# @author     Bjoern Rennhak
#
#######


require 'rubygems'

# Libraries: Mathematics
require 'gsl'
require 'narray'

# Libraries: Plotting
require 'gnuplot'


# The class PCA provides the functionality of calculating the Principle Component Analysis for given vectors.
# For details please see here: http://en.wikipedia.org/wiki/Principal_component_analysis
class PCA # {{{

  # Initialize function for the PCA class 
  def initialize # {{{

    # Simple lookup table to speed up the factorials calculation. Starts with index 0, 0!=1, 1!=1, 2!=2 etc.
    @factorials = [ 1, 1, 2, 6, 24, 120, 720 ]

  end # of def initialize }}}


  # The mean function calculates the average or mean of the input set \bar{X} = \frac{\sum^{n}_{i=1}{X_i}}{n}
  #
  # @param    [Array] set   Set of elements of type int or float in the form of an Array
  # @returns  [Float]       Returns the mean value as a float
  def mean set # {{{

    # Pre-condition {{{
    raise ArgumentError, "Input should be of type Array" unless( set.is_a?(Array) )
    set.each_with_index do |element, i| 
      raise ArgumentError, "Array contents should only be of type numeric, but it is (#{element.class.to_s}) at index #{i.to_s} (contents: '#{element.to_s}')" unless( element.is_a?(Numeric) )
    end
    # }}}


    # Main
    m = 0.0
    set.each { |i| m += i.to_f }
    result = m / set.length.to_f


    # Post-condition
    raise ArgumentError, "Value should be of type float but it is #{result.class.to_s}" unless( result.is_a?(Float) )

    result
  end # of def meanz }}}


  # The standard_devation function calcualtes SD or the mathematical standard deviation
  # "A measure of how spread out the data is"
  # "The average distance from the mean of the data set to a point"
  # s = \sqrt{ \frac{ \sum^{n}_{i=1}{ (X_i - X^{-})^2 }  }{ (n-1) }  }
  # Standard deviation over a population of n-1
  #
  # @param    [Array] set   Set of elements of type int or float as an Array
  # @returns  [Float]       Returns the standard deviation as a float
  def standard_deviation set # {{{

    # Pre-condition {{{
    raise ArgumentError, "Input should be of type Array" unless( set.is_a?(Array) )
    set.each_with_index do |element, i| 
      raise ArgumentError, "Array contents should only be of type numeric, but it is (#{element.class.to_s}) at index #{i.to_s} (contents: '#{element.to_s}')" unless( element.is_a?(Numeric) )
    end
    # }}}


    # Main
    divisor    = 0.0

    # mean of the input set
    x_bar      = mean( set ) 

    set.each_with_index { |x, n| divisor += ( x.to_f - x_bar ) ** 2 }

    sd         = divisor.to_f / ( set.length - 1 )


    # Post-condition
    raise ArgumentError, "Value should be of type float but it is #{sd.class.to_s}" unless( sd.is_a?(Float) )

    sd
  end # of def standard_deviation }}}


  # The function calcualtes the variance of a given set
  #
  # @param    [Array] set   Set of elements of type int or float as an Array
  # @returns  [Float]       Returns the standard deviation as a float 
  def variance set # {{{

    # Pre-condition {{{
    raise ArgumentError, "Input should be of type Array" unless( set.is_a?(Array) )
    set.each_with_index do |element, i| 
      raise ArgumentError, "Array contents should only be of type numeric, but it is (#{element.class.to_s}) at index #{i.to_s} (contents: '#{element.to_s}')" unless( element.is_a?(Numeric) )
    end
    # }}}

    # Main
    variance = standard_deviation( set ) ** 2

    # Post-condition
    raise ArgumentError, "Value should be of type float but it is #{variance.class.to_s}" unless( variance.is_a?(Float) )

    variance
  end # of def variancze }}}


  # Measures the difference between two dimensions (data sets)
  #
  # @param    [Array]   set1          Set of elements of type int or float as an Array
  # @param    [Array]   set2          Set of elements of type int or float as an Array
  # @param    [Boolean] in_english    If true, the result will be expressed in normal english (STDOUT) and as a number (return of function)
  # @returns  [Float]                 Covariance expressed as a float value
  def covariance set1, set2, in_english = false # {{{

    # Pre-condition {{{
    [set1, set2].each do |set|
      raise ArgumentError, "Input should be of type Array" unless( set.is_a?(Array) )
      set.each_with_index do |element, i|
        raise ArgumentError, "Array contents should only be of type numeric, but it is (#{element.class.to_s}) at index #{i.to_s} (contents: '#{element.to_s}')" unless( element.is_a?(Numeric) )
      end
    end
    # }}}


    # Main
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


    # Post-condition
    raise ArgumentError, "Value should be of type float but it is #{cov.class.to_s}" unless( cov.is_a?(Float) )

    cov
  end # of def covariance }}}


  # Calculates the factorial of a given number n
  # see e.g. http://en.wikipedia.org/wiki/Factorial
  # Iterative solution with lookup table.
  #
  # @param    [Integer] n   Requires an input in the form of an integer
  # @return   [Integer]     Result of factorial calculation
  # @note Recursive solution seems faster according to http://rosettacode.org/wiki/Factorial
  # @warn Works only with integers
  def factorial n # {{{

    # Pre-condition
    raise ArgumentError, "Input should be of type Numeric, but is of (#{n.class.to_s})" unless( n.is_a?(Numeric) )


    # Main

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


    # Post-condition
    raise ArgumentError, "Output should be of type Numeric, but is of (#{result.class.to_s})" unless( result.is_a?(Numeric) )

    result
  end # }}}


  # Calculates how many covarance values are calculatable in a given matrix with n dimensions
  # e.g. (3 dimensional data set x,y,z) -> cov(x,y), cov(x,z), cov(y,z)
  # cov_values = \frac{n!}{(n-2)! * 2}
  #
  # @param    [Integer] n   Rank of the nxn matrix.
  # @returns  [Integer]     How many covarance values are calculatable of a give nxn matrix.
  def how_many_covariance_values? n # {{{

    # Pre-condition
    raise ArgumentError, "Input should be of type integer" unless( n.is_a?(Integer) )

    # Main
    cov_values = factorial( n ) / ( factorial(n-2) * 2 )

    # Post-condition
    raise ArgumentError, "Result should be of type integer" unless( cov_values.is_a?( Integer ) )

    cov_values
  end # of def how_many_covariance_values? dimensions }}}


  # The function covariance_matrix creates a said matrix from a given arbitrary input of nxn matrix
  # see page 8 in the example pdf
  # input: e.g. [ [1,2,3], [2,3,4], [5,6,7] ]
  # shape: n x n
  #
  # @param    [GSL::Matrix] input   Accepts a GSL::Matrix type where each column is one dimension and each row is a data set
  # @returns  [GSL::Matrix]         Covariance matrix of the type GSL::Matrix with the rank nxn
  def covariance_matrix input # {{{

    # Pre-condition check
    raise ArgumentError, "Input should be of type GSL::Matrix, but it is (#{input.class.to_s})" unless( input.is_a?( GSL::Matrix ) )

    # Main

    #         | a1 b1 c1 d1 |
    # input = | a2 b2 c2 d2 |   <- Input of 4 dimensional data with each 3 values
    #         | a3 b3 c3 d3 |

    # Since x denotes the input dimensions (n) our covariance matrix will be of rank n x n
    y, x    = input.shape      # determine rank

    result  = GSL::Matrix.alloc( x, x )

    # Fill the covariance matrix according to the schema of pdf page 8
    0.upto( x-1 ) do |i|
      0.upto( x-1 ) do |j|
        result[i,j] = covariance( input.column(i).to_a, input.column(j).to_a )
      end # 0.upto( x-1 ) do |j|
    end # of 0.upto( x-1 ) do |i|


    # Post-condition check
    raise ArgumentError, "Result should be of type GSL::Matrix, but it is (#{result.class.to_s})" unless( result.is_a?( GSL::Matrix ) )

    result
  end # def covmatrix }}}


  # The function substract_mean will ajust the data to be useable for PCA. This is done by
  # substracting the mean of the set so that the mean of the new set is zero
  #
  # @param    [Array] set   Array containing floats or integers
  # @returns  [Array]       Result containing the adjusted set where each element has been substracted with the mean of the set
  def substract_mean set # {{{

    # Pre-condition {{{
    raise ArgumentError, "Input should be of type Array" unless( set.is_a?(Array) )
    set.each_with_index do |element, i| 
      raise ArgumentError, "Array contents should only be of type numeric, but it is (#{element.class.to_s}) at index #{i.to_s} (contents: '#{element.to_s}')" unless( element.is_a?(Numeric) )
    end
    # }}}

    # Main
    m       = mean( set )
    result  = set.collect { |n| n-m }

    # Post-condition check {{{
    raise ArgumentError, "Output should be of type Array" unless( result.is_a?( Array ) )
    result.each_with_index do |element, i| 
      raise ArgumentError, "Array contents should only be of type numeric, but it is (#{element.class.to_s}) at index #{i.to_s} (contents: '#{element.to_s}')" unless( element.is_a?(Numeric) )
    end
    # }}}

    result
  end # of def substract_mean set }}}


  # The function add_mean will ajust the data to be useable for restoring PCA processed data. This is done by
  # adding back the mean of the set.
  #
  # @param    [Array] set   Accepts array containing floats or integers
  # @returns  [Array]       Result containing the adjusted set where each element has been substracted with the mean of the set
  def add_mean set # {{{

    # Pre-condition {{{
    raise ArgumentError, "Input should be of type Array" unless( set.is_a?(Array) )
    set.each_with_index do |element, i| 
      raise ArgumentError, "Array contents should only be of type numeric, but it is (#{element.class.to_s}) at index #{i.to_s} (contents: '#{element.to_s}')" unless( element.is_a?(Numeric) )
    end
    # }}}

    # Main
    m       = mean( set )
    result  = set.collect { |n| n+m }

    # Post-condition check {{{
    raise ArgumentError, "Output should be of type Array" unless( result.is_a?( Array ) )
    result.each_with_index do |element, i| 
      raise ArgumentError, "Array contents should only be of type numeric, but it is (#{element.class.to_s}) at index #{i.to_s} (contents: '#{element.to_s}')" unless( element.is_a?(Numeric) )
    end
    # }}}

    result
  end # of def add_mean set }}}


  # The function adds the original mean to the previously transformed set back
  #
  # @param    [Array] orignal_set       Set accepts an Array containing floats or integers
  # @param    [Array] transformed_set   Set accepts an Array containing floats or integers
  # @returns  [Array]                   Result containing the ajusted set where each element has been added with the mean of the original set
  def add_original_mean orignal_set, transformed_set # {{{

    # Pre-condition {{{
    [orignal_set, transformed_set].each do |set|
      raise ArgumentError, "Input should be of type Array" unless( set.is_a?(Array) )
      set.each_with_index do |element, i| 
        raise ArgumentError, "Array contents should only be of type numeric, but it is (#{element.class.to_s}) at index #{i.to_s} (contents: '#{element.to_s}')" unless( element.is_a?(Numeric) )
      end
    end
    # }}}

    # Main
    m       = mean( orignal_set )
    result  = transformed_set.collect { |n| n+m }

    # Post-condition check {{{
    raise ArgumentError, "Output should be of type Array" unless( result.is_a?( Array ) )
    result.each_with_index do |element, i| 
      raise ArgumentError, "Array contents should only be of type numeric, but it is (#{element.class.to_s}) at index #{i.to_s} (contents: '#{element.to_s}')" unless( element.is_a?(Numeric) )
    end
    # }}}

    result
  end # of def add_mean set }}}


  # Function pca takes input of arbitrary numbers (array containing arrays) and does a PCA extraction of the required dimensions
  #
  # @param    [Array]   input               Input is array of arrays. Each sub-array contains integers or floats. e.g. [ [x1, x2, x3,...], [y1,y2,y3,....], [z1,z2,....]] 
  # @param    [Integer] reduce_dimensions   Integer, number of dimension which to reduce from the original. Resulting dimensions are n-p in total (n = orign. dimensions, p = dimensions to reduce).
  # @returns  [Array]                       An array containing "Array of arrays" with data as first, eigen_values as second and finally eigen_vectors as last element, e.g. [ Array, GSL::Eigen::EigenVectors, GSL::Eigen:EigenVectors ] 
  def do_pca input, reduce_dimensions # {{{

    # Pre-condition check {{{
    raise ArgumentError, "Data needs to be of the shape [ [x1,x2,..xn], [y1,y2,..yn], [z1,z2,...zn] ] but it is has ( #{input.length.to_s} ) elements" unless( input.length == 3 )
    input.each { |array| raise ArgumentError, "Data contained in the subarrays may not be nil" if( array.include?( nil ) ) }
    raise ArgumentError, "Reduce dimensions needs to be of type integer" unless( reduce_dimensions.is_a?( Integer ) )
    # }}}

    original                        = input.dup

    # substract mean from input data
    input.collect! { |subarray| substract_mean( subarray ) }


    # Convert the subarrys into a GSL matrix
    matrix                          = GSL::Matrix.alloc( *input ).transpose

    # Determine the covariance matrix from the mean reduced input
    cov_matrix                      = covariance_matrix( matrix )

    # Extract eigen-values and -vectors via GSL
    eigen_values, eigen_vectors     = cov_matrix.eigen_symmv

    # Sort in-place the eigen-vectors or importance (most to least)
    GSL::Eigen.symmv_sort eigen_values, eigen_vectors, GSL::Eigen::SORT_VAL_DESC

    # Calculate the finaldata with all eigenvectors
    if( reduce_dimensions <= 0 )
      row_feature_vector            = eigen_vectors
    else
      # reduce 1 or more
      if( eigen_vectors.size.first <= reduce_dimensions )
        raise ArgumentError, "You cannot reduce the dimensions of the eigen vector matrix by #{reduce_dimensions.to_s} because the matrix is only of size #{eigen_vectors.size.join(",").to_s}."
      else
        x_size, y_size              = eigen_vectors.size
        y_size                     -= reduce_dimensions

        row_feature_vector          = GSL::Matrix.alloc( x_size, y_size )
        0.upto( y_size-1 ) { |y| row_feature_vector.set_col( y, eigen_vectors.get_col(y) ) }
      end # of if( eigen_vectors.size.first <= reduce_dimensions )
    end # of if( reduce_dimensions <= 0 )

    row_feature_vector              = row_feature_vector.transpose

    row_data_adjust                 = matrix.transpose
    final_data                      = row_feature_vector * row_data_adjust
    row_original_data               = row_feature_vector.transpose * final_data

    # Split matrix into subarrays again and add back the substracted mean
    result                          = []

    row_cnt                         = 0
    row_original_data.each_row do |row|
      tmp                           = row.to_a
      add_original_mean( original[row_cnt], tmp )
      result << tmp
      row_cnt                      += 1
    end

    # Post-condition check {{{
    raise ArgumentError, "Result variable should be of type Array, but is (#{result.class.to_s})" unless( result.is_a?(Array) )
    raise ArgumentError, "Eigen values variable should be of type GSL::Eigen::EigenValues, but is (#{eigen_values.class.to_s})" unless( eigen_values.is_a?(GSL::Eigen::EigenValues) )
    raise ArgumentError, "Eigen vectors variable should be of type GSL::Eigen::EigenVectors, but is (#{eigen_vectors.class.to_s})" unless( eigen_vectors.is_a?(GSL::Eigen::EigenVectors) )
    # }}}

    [ result, eigen_values, eigen_vectors ]
  end # of def do_pca }}}


  # The function array_of_arrays_to_eigensystem converts the external data structure of type "array of arrays" to a eigensystem (GSL)
  #
  # @param    [Array]   data  Array of arrays. Each sub-array contains integers or floats
  # @param    [Boolean] sort  If true, the eigen vectors will get sorted according to the power of the eigen values
  # @returns  [Array]         Array containing as first element the extracted and eigen values and as second (and last) element the corresponding eigen vectors
  def array_of_arrays_to_eigensystem data, sort = true # {{{

    # Pre-condition {{{
    raise ArgumentError, "Data argument should be of type Array" unless( data.is_a?( Array ) )
    raise ArgumentError, "The sort argument needs to be of type boolean" unless( sort.is_a?(Boolean) )
    # }}}

    # Convert the subarrys into a GSL matrix
    matrix                        = GSL::Matrix.alloc( *data ).transpose
    cov_matrix                    = covariance_matrix( matrix )

    # Extract eigen-values and -vectors via GSL
    eigen_values, eigen_vectors   = cov_matrix.eigen_symmv

    if( sort )
      # Sort in-place the eigen-vectors or importance (most to least)
      GSL::Eigen.symmv_sort eigen_values, eigen_vectors, GSL::Eigen::SORT_VAL_DESC
    end

    # Post-condition check {{{
    raise ArgumentError, "Eigen values variable should be of type GSL::Eigen::EigenValues, but is (#{eigen_values.class.to_s})" unless( eigen_values.is_a?(GSL::Eigen::EigenValues) )
    raise ArgumentError, "Eigen vectors variable should be of type GSL::Eigen::EigenVectors, but is (#{eigen_vectors.class.to_s})" unless( eigen_vectors.is_a?(GSL::Eigen::EigenVectors) )
    # }}}

    [ eigen_values, eigen_vectors ]
  end # }}}


  # The function normalize takes any input array containing floats/integers and normalizes them between a desired range
  #
  # @param    [Array]   data    Accepts an array containing floats or integers of which to normalize to new_min and new_max
  # @param    [Numeric] new_min Accepts an integer or float as lower boundary for the normalization (inclusive)
  # @param    [Numeric] new_max Accepts an integer or float as upper boundary for the normalization (inclusive)
  # @returns  [Array]           containing the newly normalized data
  # @note Inspired by http://stackoverflow.com/questions/695084/how-do-i-normalize-an-image
  def normalize data, new_min = 0, new_max = 1, old_min = nil, old_max = nil # {{{


    # Pre-condition check {{{
    raise ArgumentError, "Input should be of type Array" unless( data.is_a?(Array) )
    data.each_with_index do |element, i| 
      raise ArgumentError, "Array contents should only be of type numeric, but it is (#{element.class.to_s}) at index #{i.to_s} (contents: '#{element.to_s}')" unless( element.is_a?(Numeric) )
    end
    raise ArgumentError, "The variable new_min should be of type numeric, but is of (#{new_min.class.to_s})" unless( new_min.is_a?(Numeric) )
    raise ArgumentError, "The variable new_max should be of type numeric, but is of (#{new_max.class.to_s})" unless( new_max.is_a?(Numeric) )
    # }}}

    old_min, old_max  = data.min, data.max if( old_min.nil?  && old_max.nil? ) 
    old_range         = old_max - old_min

    new_range         = new_max.to_f - new_min.to_f

    # ymin + (x-xmin) * (yrange.to_f / xrange) 
    data.collect! do |n|
      # where in the old scale is this value (0...1)
      scale           = ( n - old_min ) / old_range

      # place this scale in the new range
      new_value = ( new_range.to_f * scale ) + new_min
    end # of data.collect!

    # Post-condition check {{{
    raise ArgumentError, "Result should be of type Array" unless( data.is_a?(Array) )
    # }}}

    data
  end # def normalize data, new_min = 0, new_max = 1 }}}


  # The function transform_basis changes the data from a standard basis to a basis with the prinicipal components as u,v,w
  # "Change of basis to principal axis"
  #
  # @param    [Array]                    pca_result    Output from the do_pca function - the pca transformed data
  # @param    [GSL::Eigen::EigenValues]  eigen_values  Output from the do_pca function - the extracted eigen_values of the pca input data
  # @param    [GSL::Eigen::EigenVectors] eigen_vectors Output from the do_pca function - the extracted eigen_vectors (principle components) of the pca processed data
  # @returns  [Array]                                  Array of arrays - Transformed data to the new principle component based basis ready for use with the gnuplot functions.
  def transform_basis pca_result, eigen_values, eigen_vectors # {{{

    # Pre-condition check {{{
    raise ArgumentError, "Result variable should be of type Array, but is (#{pca_result.class.to_s})" unless( pca_result.is_a?(Array) )
    raise ArgumentError, "Eigen values variable should be of type GSL::Eigen::EigenValues, but is (#{eigen_values.class.to_s})" unless( eigen_values.is_a?(GSL::Eigen::EigenValues) )
    raise ArgumentError, "Eigen vectors variable should be of type GSL::Eigen::EigenVectors, but is (#{eigen_vectors.class.to_s})" unless( eigen_vectors.is_a?(GSL::Eigen::EigenVectors) )
    # }}}

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

    # Post-condition check
    raise ArgumentError, "Result should be of type Array, but is of (#{result_final.class.to_s})" unless( result_final.is_a?(Array) )

    result_final
  end # of def transform_basis }}}


  # The function clean_data looks through the data after pca and pc basis transform and trys to clean out the [0,0,0...]'s everywhere.
  # The 0's are created due to numerical errors which are 10^{-15} etc.
  #
  # @param    [Array]   transform_basis_result  Array of arrays - Output of the transform_basis function.
  # @param    [Integer] result_dimensions       Accepts Integer with the amount of desired output dimensions (e.g. 3 for a 3D plot (even if e.g. Z coords are zero). or 2 for 2D plot)
  # @returns  [Array]                           Array of arrays - Cleaned up data where 0 vectors have been removed.
  def clean_data transform_basis_result, result_dimensions # {{{

    # Pre-condition check {{{
    raise ArgumentError, "transform_basis_result should be of type Array, but is of (#{transform_basis_result.class.to_s})" unless( transform_basis_result.is_a?(Array) )
    raise ArgumentError, "result_dimensions should be of type integer, but is of (#{result_dimensions.class.to_s})" unless( result_dimensions.is_a?(Integer) )
    raise ArgumentError, "clean_data functions currently just supports dimensions below or including 3" unless( result_dimensions <= 3 )
    # }}}

    # Cleanup data from the very small values 10^{-15} etc. (numerical errors)
    transform_basis_result.collect! do |array| 
      array.collect! { |i| ( i.abs <= 10**-12 ) ? ( nil ) : ( i ) }
      array
    end # of transform_basis_result.collect!

    # Check desired output dimensions size and e.g. create an empty z field
    if( result_dimensions == 3 ) # we want 3D even if z's are all 0.0
      new    = []
      0.upto( transform_basis_result[2].length - 1 ) { |n| new << 0.0 }

      zero = transform_basis_result[2]
      zero.compact!
      transform_basis_result[2] = new if( zero.empty? )
    end # of if( result_dimensions == 3 )

    # purge nil's and delete empty arrays
    transform_basis_result.collect!   { |x| x.compact }
    transform_basis_result.delete_if  { |x| x.empty? }

    # Post-condition check
    raise ArgumentError, "transform_basis_result should be of type Array, but is of (#{transform_basis_result.class.to_s})" unless( transform_basis_result.is_a?(Array) )

    transform_basis_result
  end # of def clean_data }}}


  # The function reshape_data takes input of the long or the short form and reshapes it into the other
  # long form:   [ [x1,x2,x3,...], [y1,y2,y3,....], [z1,z2,z3,....] ] 
  # short form:  [ [x1,y1,z1], [x2,y2,z2], [x3,y3,z3],.... ]
  #
  # @param    [Array]    data      Array of arrays in different configuration depending on the way we want to handle the reshape.
  # @param    [Boolean]  to_long   If true, we convert "short type" arrays to "long type" arrays
  # @param    [Boolean]  to_short  If true, we convert "long type" arrays to "short type" arrays
  # @returns  [Array]              Array in the shape as described in the function description
  def reshape_data data, to_long, to_short # {{{

    # Pre-condition check {{{
    raise ArgumentError, "Not both equal true allowed" if( to_long and to_short )
    raise ArgumentError, "Not both equal false allowed" if( not to_long and not to_short )
    raise ArgumentError, "Not both equal nil allowed" if( to_long.nil? and to_short.nil? )

    if( to_long )
      raise ArgumentError, "We expect the data to be in short form [ [x1,y1,z1], [x2,y2,z2], [x3,y3,z3],.... ], but it is in long form [ [x1,x2,x3,...], [y1,y2,y3,....], [z1,z2,z3,....] ]" unless( data.first.length == 3 )
    end

    if( to_short )
      raise ArgumentError, "We expect the data to be in long form [ [x1,x2,x3,...], [y1,y2,y3,....], [z1,z2,z3,....] ], but it is in short form [ [x1,y1,z1], [x2,y2,z2], [x3,y3,z3],.... ]" unless( data.length == 3 )
    end
    # }}}

    # Main
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

    # Post-condition check {{{
    if( to_long )
      raise ArgumentError, "We expect the result to be in long form [ [x1,x2,x3,...], [y1,y2,y3,....], [z1,z2,z3,....] ], but it is not." unless( result.length == 3 )
    end

    if( to_short )
      raise ArgumentError, "We expect the data to be in short form [ [x1,y1,z1], [x2,y2,z2], [x3,y3,z3],.... ], but it is not." unless( result.first.length == 3 )
    end
    # }}}

    result
  end # of def reshape_data }}}

end # of class PCA }}}


# Direct invocation
if __FILE__ == $0 # {{{
end # of if __FILE__ == $0 }}}

