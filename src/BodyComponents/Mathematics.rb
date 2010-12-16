#!/usr/bin/ruby
#

###
#
# File: Mathematics.rb
#
######


###
#
# (c) 2009-2011, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       Mathematics.rb
# @author     Bjoern Rennhak
#
#######


# Standard includes
require 'rubygems'
require 'narray'
require 'gsl'

# Warning: Including this line will cause everything to break.
# include GSL

#require 'c/c_mathematics'

# The class Mathematics provides helpful functions to calculate various things needed throughout this project
class Mathematics # {{{

  def initialize # {{{
  end # of def initialize }}}


  # @fn       def getNorm x, y, z # {{{
  # @brief    The function determines the simple norm of an input vector given by its coordinates x, y and z.
  #
  # @param    [Numeric]   x   X coordinate of the given vector
  # @param    [Numeric]   y   Y coordinate of the given vector
  # @param    [Numeric]   z   Z coordinate of the given vector
  #
  # @returns  [Numeric]       Result of the norm calculation
  def getNorm x = nil, y = nil, z = nil

    # Pre-condition check {{{
    raise ArgumentError, "X coordinate should be of type numeric, but is of (#{x.class.to_s})" unless( x.is_a?(Numeric) )
    raise ArgumentError, "Y coordinate should be of type numeric, but is of (#{y.class.to_s})" unless( y.is_a?(Numeric) )
    raise ArgumentError, "Z coordinate should be of type numeric, but is of (#{z.class.to_s})" unless( z.is_a?(Numeric) )
    # }}}

    result = Math.sqrt( (x*x) + (y*y) + (z*z) )

    # Post-condition check
    raise ArgumentError, "Result should be of type numeric, but is of (#{result.class.to_s})" unless( result.is_a?(Numeric) )

    result
  end # of def getNorm }}}


  # @fn       def distance_of_line_to_line line1_pt0, line1_pt1, line2_pt0, line2_pt1 # {{{
  # @brief    Distance between Lines and Segments with their Closest Point of Approach
  #
  # @param    [Segment]   line1_pt0   Segment class (MotionX vpm plugin) for line 1 point 0
  # @param    [Segment]   line1_pt1   Segment class (MotionX vpm plugin) for line 1 point 1
  # @param    [Segment]   line2_pt0   Segment class (MotionX vpm plugin) for line 2 point 0
  # @param    [Segment]   line2_pt1   Segment class (MotionX vpm plugin) for line 2 point 1
  #
  # @returns  [Segment]               Segment dP which is the new closest point for all frames f
  #
  # @note     http://softsurfer.com/Archive/algorithm_0106/algorithm_0106.htm
  def distance_of_line_to_line line1_pt0 = nil, line1_pt1 = nil, line2_pt0 = nil, line2_pt1 = nil

    # Pre-condition check {{{
    raise ArgumentError, "The line1_pt0 argument should be of type Segment, but it is (#{line1_pt0.class.to_s})" unless( line1_pt0.is_a?( Segment ) )
    raise ArgumentError, "The line1_pt1 argument should be of type Segment, but it is (#{line1_pt1.class.to_s})" unless( line1_pt0.is_a?( Segment ) )
    raise ArgumentError, "The line2_pt0 argument should be of type Segment, but it is (#{line2_pt0.class.to_s})" unless( line2_pt0.is_a?( Segment ) )
    raise ArgumentError, "The line2_pt1 argument should be of type Segment, but it is (#{line2_pt1.class.to_s})" unless( line2_pt1.is_a?( Segment ) )
    # }}}

    # Main
    # FIXME: Make a line abstration of lines

    # segments class -> u, v, w
    u = line1_pt1 - line1_pt0
    v = line2_pt1 - line2_pt0
    w = line1_pt0 - line2_pt0

    # array of scalars of length frames -> a,b,c,d,e
    a = u.dot_product( u )  # always >=0
    b = u.dot_product( v )
    c = v.dot_product( v )  # always >=0
    d = u.dot_product( w )
    e = v.dot_product( w )

    d = []

    0.upto( a.length - 1 ) { |index| d[index] = ( (a[index] * c[index]) - (b[index] * b[index]) ) } # always >=0
    sc, tc    = [], []  # array of floats

    0.upto( a.length - 1 ) do |index|
      # compute the line parameters of the two closest points
      if( d[index] < 0.00000001 )   # lines almost parallel
        sc[index] = 0.0
        tc[index] = ( b[index] > c[index] ) ? ( d[index] / b[index] ) : ( e[index] / c[index] )  # use largest denominator
      else
        sc[index] = ( ( b[index] * e[index] ) - ( c[index] * d[index] ) ) / d[index]
        tc[index] = ( ( a[index] * e[index] ) - ( b[index] * d[index] ) ) / d[index]
      end # of if( d[index] < 0.00000001 )
    end # of 0.upto

    # get the difference of the two closest points for all frames
    dP  = w + (u*sc) - (v*tc) # L1(sc) - L2(tc)

    # Post-condition check
    raise ArgumentError, "The result of this function should be of type Segment, but it is (#{dP.class.to_s})" unless( dP.is_a?(Segment) )

    dP
  end # of def distance_3D_line_to_line }}}


  # @fn       def eucledian_distance point1, point2 # {{{
  # @brief    The eucledian_distance function takes two points in R^3 (x,y,z) and calculates the distance between them.
  #           You can easily derive this function via Pythagoras formula. P1,P2 \elem R^3
  #
  #           d(P1, P2) = \sqrt{ (x_2 - x_1)^2 + (y_2 - y_1)^2 + (z_2 - z_1)^2 }
  #
  #           Further reading:
  #           http://en.wikipedia.org/wiki/Distance
  #           http://en.wikipedia.org/wiki/Euclidean_distance
  #
  # @param    [Array]   point1  Accepts array containing floats or integers (x,y,z)
  # @param    [Array]   point2  Accepts array containing floats or integers (x,y,z)
  #
  # @returns  [Float]   Float, the distance between point 1 and point 2
  def eucledian_distance point1 = nil, point2 = nil

    # Pre-condition check {{{
    raise Error, "Points can't be nil." if( point1.nil? or point2.nil? )
    raise ArgumentError, "Eucledian distance for nD points for n > 3 is currently not implemented." if( (point1.length > 3) or (point2.length > 3 ) )
    # }}}


    x1, y1, z1 = *point1
    x2, y2, z2 = *point2

    if( z1.nil? and z2.nil? )
      puts "Calculating eucledian_distance for 2D coordinates"
      result = Math.sqrt( ( (x2 - x1) ** 2 ) + ( (y2 - y1) ** 2  )  )
    else
      #puts "Calculating eucledian_distance for 3D coordinates"
      #x = x2 - x1
      #y = y2 - y1
      #z = z2 - z1

      #@power_of_two_lookup_table[x] = x**2 if( @power_of_two_lookup_table[ x ].nil? )
      #@power_of_two_lookup_table[y] = y**2 if( @power_of_two_lookup_table[ y ].nil? )
      #@power_of_two_lookup_table[z] = z**2 if( @power_of_two_lookup_table[ z ].nil? )

      #x = @power_of_two_lookup_table[ x ]
      #y = @power_of_two_lookup_table[ y ]
      #z = @power_of_two_lookup_table[ z ]

      result = Math.sqrt( ((x2-x1)**2) + ((y2-y1)**2) + ((z2-z1)**2) )
      # result = C_mathematics.c_eucledian_distance( x1, y1, z1, x2, y2, z2 )
    end

    # Post-condition check
    raise ArgumentError, "The result of this function should be of type numeric, but it is of (#{result.class.to_s})" unless( result.is_a?(Numeric) )

    result
  end # of def eucledian_distance point1, point2 }}}


  # @fn       def eucledian_distance_window data = nil, points = nil # {{{
  # @brief    The function eucledian_distance_window takes a given dataset (x1,y1,z1;..) and calculates the
  #           eucleadian distance for given points in both directions like a window function. That means that
  #           with e.g. points = 5 ; 5 points before point X and 5 points after X are measured and summed up.
  #
  # @param   [Array]    data      Array of arrays, in the form of [ [x,y,z],[..]...] .
  # @param   [Integer]  points    Accepts integer of how many points before and after should be included in the calculation
  #
  # @returns [Array]              Array, conaining floats. Each index of the array corresponds to the data frame.
  #
  # @todo Refactor this code more nicely.
  def eucledian_distance_window data = nil, points = nil

    # Input verification {{{
    raise ArgumentError, "Data cannot be nil"     if( data.nil? )
    raise ArgumentError, "Points cannot be nil"   if( points.nil? )
    # }}}

    distances = []

    if( data.first.length == 4 )

      puts "WARNING - got data with 4 slots ---------------------"
      puts "WILL PRUNE, but this is a indicator that something bad is happening"

      data.collect! do |array|
        last  = array.last
        new   = array
        if( last.nil? )
          new.pop
        else
          if( last <= 10**-10 )
            new.pop
          end
        end

        new
      end
    end

    raise ArgumentError, "Data has not the right shape should be  [ [x,y,z],[..]...]" if( data.length == 3 )
    raise ArgumentError, "Data has not the right shape should be  [ [x,y,z],[..]...]" unless( data.first.length == 3 )

    d = data

    d.each_index do |index|
      from  = nil
      to    = nil
      sum   = 0

      if( (index.to_i - points.to_i) < 0 ) 
        # we are at the beginning of the frames - just include the first points
        from  = index
        to    = index + points
        ( eval( "#{from.to_s}...#{to.to_s}" ) ).each do |n|
          if( d[n].length == 3 and d[n+1].length == 3 )
            #puts "d[n]: #{d[n].join(", ").to_s}"
            #puts "d[n+1]: #{d[n+1].join(", ").to_s}"
            sum += eucledian_distance( d[n], d[n+1] )
          else
            puts "Data has not the right shape (should be a 3D point) not (from idx: #{from.to_s} to idx: #{to.to_s} -> n: #{n.to_s} n+1: #{(n+1).to_s} -> d[n]: #{d[n].to_s} d[n+1]: #{d[n+1].to_s}"
            #puts "Data has not the right shape (should be a 3D point) not (from idx: #{from.to_s} to idx: #{to.to_s} -> n: #{n.to_s} n+1: #{(n+1).to_s} -> d[n]: #{d[n].join(",").to_s} d[n+1]: #{d[n+1].join(",").to_s}"
            raise ArgumentError, "Error"
          end
        end
        distances[ index ] = sum
        next
      end

      if( (index.to_i + points.to_i > (d.length-1)) )
        # we are at the end of the frames - just include the last points
        from  = index - points
        to    = index
        ( eval( "#{from.to_s}...#{to.to_s}" ) ).each do |n|
          if( d[n].length == 3 and d[n+1].length == 3 )
            #puts "d[n]: #{d[n].join(", ").to_s}"
            #puts "d[n+1]: #{d[n+1].join(", ").to_s}"

            sum += eucledian_distance( d[n], d[n+1] ) 
          else
            puts "Data has not the right shape (should be a 3D point) not (from idx: #{from.to_s} to idx: #{to.to_s} -> n: #{n.to_s} n+1: #{(n+1).to_s} -> d[n]: #{d[n].join(",").to_s} d[n+1]: #{d[n+1].join(",").to_s}"
            raise ArgumentError, "Error"
          end
        end
        distances[ index ] = sum
        next
      end

      from  = index - points
      to    = index + points

      ( eval( "#{from.to_s}...#{to.to_s}" ) ).each do |n| 
        if( d[n].length == 3 and d[n+1].length == 3 )
          #puts "d[n]: #{d[n].join(", ").to_s}"
          #puts "d[n+1]: #{d[n+1].join(", ").to_s}"

          sum += eucledian_distance( d[n], d[n+1] )
        else
            puts "Data has not the right shape (should be a 3D point) not (from idx: #{from.to_s} to idx: #{to.to_s} -> n: #{n.to_s} n+1: #{(n+1).to_s} -> d[n]: #{d[n].join(",").to_s} d[n+1]: #{d[n+1].join(",").to_s}"
            raise ArgumentError, "Error"
        end
      end

      distances[ index ] = sum
    end

    distances
  end # of def eucledian_distance_window data, points }}}


  # @fn       def approxGradient x, y # {{{
  # @brief    The function is a very simple and naive approximation for a real gradient calculation
  #
  # @param    [Float]   x   X-Coordinate of a given point p
  # @param    [Float]   y   Y-Coordinate of a given point p
  # @returns  [Float]       Float, rough and naive approximation of a gradient of point p(x,y)
  #
  # @warning FIXME: This method should be substituted by a real derivative calculation
  def approxGradient x = nil, y = nil

    # Pre-condition check {{{
    raise ArgumentError, "The argument x should be of type float, but it is of (#{x.class.to_s})" unless( x.is_a?(Float) )
    raise ArgumentError, "The argument y should be of type float, but it is of (#{y.class.to_s})" unless( y.is_a?(Float) )
    # }}}

    result = ( x.to_f + y.to_f**2 )

    # Post-condition check
    raise ArgumentError, "The function should return a float, but it is of (#{result.class.to_s})" unless( result.is_a?(Float) )

    result
  end # of approxGradient }}}


  # @fn       def getSlopeForm array1, array2, direction = "xy" # {{{
  # @brief    The function returns a solution of the following:
  #           Two points p1 (x,y,z) and p2 (x2,y2,z2) span a line in 3D space.
  #           One plane is eliminated by zero'ing the factor.
  #           The slope form also known as f(x) =>  y = m*x + t  (2D)
  #           m = DeltaY / DeltaX  ; where DeltaY is the Y2 - Y1 ("steigung/increase")
  #
  # @param    [Array]   array1      Set of coordinates Point A
  # @param    [Array]   array2      Set of coordinates Point B
  # @param    [String]  direction   String which is either "xy", "xz", "yz"
  #
  # @returns  [Array]               Array, containing m and t for the slope form equasion
  #
  # @warning FIXME: Z coordinate is only neglegted and this needs to be normally compensated - use PCA/ICA instead.
  def getSlopeForm array1 = nil, array2 = nil, direction = "xy" # {{{

    # Pre-condition check {{{
    raise ArgumentError, "The argument array1 should be of type array, but it is of (#{array1.class.to_s})" unless( array1.is_a?( Array ) )
    raise ArgumentError, "The argument array2 should be of type array, but it is of (#{array2.class.to_s})" unless( array2.is_a?( Array ) )
    raise ArgumentError, "The argument direction should be of type string, but it is of (#{direction.class.to_s})" unless( direction.is_a?( String ) )
    # }}}

    # Main
    x1, y1, z1      = *array1
    x2, y2, z2      = *array2

    if( direction == "xy" )
      deltaX, deltaY  = ( x2 - x1 ), ( y2 - y1 )
      m               = deltaY / deltaX
      t               = y1 - ( m * x1 )
    end

    if( direction == "xz" )
      deltaX, deltaY  = ( z2 - z1 ), ( x2 - x1 )
      m               = deltaY / deltaX
      t               = y1 - ( m * x1 )
    end

    if( direction == "yz" )
      deltaX, deltaY  = ( z2 - z1 ), ( y2 - y1 )
      m               = deltaY / deltaX
      t               = y1 - ( m * x1 )
    end

    result = [ m, t ]

    # Post-condition check
    raise ArgumentError, "Result of this function should be of type Array, but it is (#{result.class.to_s})" unless( result.is_a?(Array) )

    result
  end # end of getSlopeForm }}}


  # The function returns a solution for the following:
  # Two lines in slope intersection form f1 y = m*x + t  and f2 ...
  # intersection in a point (or not -> the intersection with the origin is returned) and this point is returned.
  #
  # @param    [Array]   array1  Array, with m and t of a line in slope form
  # @param    [Array]   array2  Array, with m and t of a line in slope form
  # @returns  [Array]           Array containing 2D point of intersection
  def getIntersectionPoint array1, array2 # {{{

    # Pre-condition check {{{
    raise ArgumentError, "The argument array1 should be of type array, but it is of (#{array1.class.to_s})" unless( array1.is_a?( Array ) )
    raise ArgumentError, "The argument array2 should be of type array, but it is of (#{array2.class.to_s})" unless( array2.is_a?( Array ) )
    # }}}

    m1, t1 = *array1
    m2, t2 = *array2

    #     m1*x + t1   = m2*x + t2   | -m2*x - t1
    # <=> m1*x - m2*x = t2 - t1
    # <=> (m1-m2)*x   = t2 - t1     | / (m1-m2)
    # <=>         x   = (t2-t1) / (m1-m2)
    x       = ( t2 - t1 ) / ( m1 - m2 )
    y1, y2  = ( m1 * x + t1 ), ( m2 * x + t2 )

    # FIXME: This error occurs due to many decimals after the comma... use sprintf
    # raise ArgumentError, "Y1 and Y2 of the equation has to be same. Something is b0rked. (,#{y1.to_s}' *** ,#{y2.to_s}')" unless y1 == y2

    result = [x,y1]

    # Post-condition check
    raise ArgumentError, "Result of this function should be of type Array, but it is (#{result.class.to_s})" unless( result.is_a?(Array) )

    result
  end # end of getIntersectionPoint }}}


  # The function takes an Array of input and calculates the derivative with the given step size h
  #
  # @param  [Array] input   Array, containing the input of the data which we want the derivative
  # @param  [Float] h       Stepsize h, most of the time you want a small epsilon such as 
  # @return [Array]         
  #
  # http://stackoverflow.com/questions/1559695/implementing-the-derivative-in-c-c
  # The approximation error in (f(x + h) - f(x - h))/2h decreases as h gets smaller, which says you
  # should take h as small as possible. But as h gets smaller, the error from floating point
  # subtraction increases since the numerator requires subtracting nearly equal numbers. If h is too
  # small, you can loose a lot of precision in the subtraction. So in practice you have to pick a
  # not-too-small value of h that minimizes the combination of approximation error and numerical
  # error.
  #
  # As a rule of thumb, you can try h = SQRT(DBL_EPSILON) where DBL_EPSILON is the smallest double
  # precision number e such that 1 + e != e in machine precision. DBL_EPSILON is about 10^-15 so you
  # could use h = 10^-7 or 10^-8.
  #
  # http://www.johndcook.com/NumericalODEStepSize.pdf
  #
  # @note http://en.wikipedia.org/wiki/Numerical_differentiation
  def derivative input, h = 10**(-7) # {{{

    # Pre-condition check # {{{
    raise ArgumentError, "The argument input should be of type Array, but is (#{input.class.to_s})" unless( input.is_a?(Array) )
    raise ArgumentError, "The argument h should be of type Numeric, but is (#{h.class.to_s})" unless( h.is_a?(Numeric) )
    # }}}

    # Main
    derivative      = []
    frames          = []

    # Prepare a GSL Spline
    spline          = GSL::Spline.alloc( "cspline", input.length )

    # Generate frame steps for fitting
    0.upto( input.length - 1 ) { |i| frames << (i) } # i*h

    # Fit a spline to the input data
    spline.init( GSL::Vector.alloc( frames ), GSL::Vector.alloc( input ) )

    # Calculate derivative by numerical approximation
    ( 0..(input.length - 1) ).step( h ) do |step|

      # A simple three-point estimation is to compute the slope of a nearby secant line through the
      # points (x-h,f(x-h)) and (x+h,f(x+h))
      deriv         = ( spline.eval( step.to_f + h ) - spline.eval( step.to_f - h ) ) / ( 2 * h )
      derivative   << deriv if( (step % 1) == 0.0 )
    end

    # Post-condition check
    raise ArgumentError, "The function result should be of type Array, but is (#{derivative.class.to_s})" unless( derivative.is_a?(Array) )

    derivative
  end # of def derivative }}}


  # The function takes 
  def first_derivative_test # {{{
  end # of def first_derivative_test }}}


  # The function takes 
  def second_derivative_test # {{{
  end # of def second_derivative_test }}}


  # The function returns a solution for the following:
  # Given two lines in slope intersection form f1 y = m*x +t and f2...
  # the determinant is ad - bc ; three cases:
  #   -1  := No solution
  #    0  := One
  #    1  := Unlimited (you can invert it)
  def determinat array1, array2 # {{{
    raise NotImplementedError
  end # end of determinat }}}



end # of class Mathematics }}}


# Direct Invocation
if __FILE__ == $0 # {{{
end # of if __FILE__ == $0 }}}

