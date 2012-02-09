#!/usr/bin/ruby
#

###
#
# File: Filter.rb
#
######


###
#
# (c) 2009-2011, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       Filter.rb
# @author     Bjoern Rennhak
#
#######


# Standard includes
require 'rubygems'
require 'narray'
require 'gsl'

# Local includes
$:.push('.')
require 'Logger.rb'
require 'PCA.rb'
require 'Plotter.rb'
require 'Mathematics.rb'

# Change Namespace
include GSL


# @class      Class Filter # {{{
# @brief      The class Filter can take input data and provide means to filter out noise and outliers from it.
class Filter


  # @fn       def initialize options, from, to # {{{
  # @brief    Custom constructor for the Filter class
  #
  # @param    [OpenStruct]      options     OpenStruct containing options parsed
  # @param    [Integer]         from        From frame int
  # @param    [Integer]         to          To frame int
  def initialize options = nil, from = nil, to = nil

    # Input verification {{{
    raise ArgumentError, "Options cannot be nil"  if( options.nil? )
    raise ArgumentError, "From cannot be nil"     if( from.nil? )
    raise ArgumentError, "To cannot be nil"       if( to.nil? )
    # }}}

    @options             = options
    @from, @to           = from, to
    @log                 = Logger.new( @options )

    @mathematics         = Mathematics.new
    @plotter             = Plotter.new( from, to )
  end # of def initialize }}}


  # @fn       def filter_motion_capture_data input, point_window = @options.filter_point_window_size, polynom_order = @options.filter_polyomial_order # {{{
  # @brief    The function takes a MotionX ADT Class as input and returns a filtered (smoothed) version of the input data via an overlapping sliding point window that uses a polynomial for fitting
  #
  # @param    [ADT]     input           ADT Class Object of the MotionX package VPM plugin
  # @param    [Integer] point_window    Integer representing the window size in which the polynomial fitting is applied
  # @param    [Integer] polynom_order   Integer representing the order of the fitting polynomial
  #
  # @returns  [ADT]                     ADT Class Object containing the new smoothed version of the input
  def filter_motion_capture_data input, point_window = @options.filter_point_window_size, polynom_order = @options.filter_polyomial_order

    @log.message :success, "Smoothing raw data with Polynomial of the order #{polynom_order.to_s} with a point window of #{point_window.to_s}"

    # Pre-condition check {{{
    raise ArgumentError, "Input argument should be of type ADT, but is of type (#{input.class.to_s})" unless( input.is_a?(ADT) )
    raise ArgumentError, "Point window argument should be of type Integer, but is of (#{point_window.class.to_s})" unless( point_window.is_a?( Integer ) )
    raise ArgumentError, "Polynom order argument should be of type Integer, but is of (#{polynom_order.class.to_s})" unless( polynom_order.is_a?( Integer ) )
    #raise ArgumentError, "Point window number needs to be even, but it is (#{point_window.to_s})" unless( ( point_window % 2 ) == 0 )
    #raise ArgumentError, "Point window divided by 2 needs to be even as well, but it is (#{(point_window/2).to_s})" unless( ( ( (point_window / 2) % 2 ) == 0 ) )
    # }}}

    @log.message :info, "Starting filtering of all relevant motion segments"

    # lets determine which segments we have in adt
    segments        = input.segments + %w[pt24 pt25 pt26 pt27 pt28 pt29 pt30 pt31]
    body            = input.body

    pca             = PCA.new
    # result          = input.dup # we cant deepclone it - why?

    # Why not on all segments? How long?
    # FXIME: This should be provided by MotionX VPM
    # %w[pt27 relb pt26 lelb pt30 rfin lfin rsho lsho rkne pt29 lkne pt28 rank lank rhee lhee rtoe ltoe].each do |
    segments.each do |s|

      # we store our calculated chunks here
      temp_container = []
      errors         = []

      # only process if it exists
      if( segments.include?( s.to_s ) )
        @log.message :info, "Filtering #{s.to_s} segment"

        segment     = eval( "input.#{s.to_s}" )
        coordinates = segment.getCoordinates!

        coordinate_chunks = coordinates % ( point_window / 2 )

        #coordinate_chunks.each_with_index do |cluster, cluster_index|

        while( not coordinate_chunks.empty? )

          # cluster = c1 + c2 since we have point_window / 2
          c1 = coordinate_chunks.shift
          c1_length = c1.length

          c2 = coordinate_chunks.shift
          c2_length = ( c2.nil? ) ? ( 0 ) : ( c2.length )

          cluster = ( c2.nil? ) ? ( c1 ) : ( c1.dup.concat( c2 ) )

          unless( cluster.empty? )
            # determine the piecewise linear from p0 to p1 (eucleadian distance)
            arc_lengths  = []
            cluster.each_index { |index| arc_lengths << @mathematics.eucledian_distance( cluster[index], cluster[index+1] ) unless( (cluster[ index + 1 ]).nil? ) }

            cluster_l           = pca.reshape_data( cluster.dup, true, false )
            x, y, z             = cluster_l.shift, cluster_l.shift, cluster_l.shift

            t_s         = []
            arc_lengths.each_index do |i|
              # t[0] is 0
              if( i == 0 )
                t_s << 0
                next
              end

              # from 2..n
              t_s << t_s[ i - 1 ] + arc_lengths[ i ]
            end

            result_splines = []

            # get independent splines through s1 = [ t(i), x(i) ], s2 =[ t(i), y(i) ], s3 = [ t(i), z(i) ]
            # Should use bsline actually, maybe to wavevy?
            [ [ t_s, x ], [ t_s, y ], [ t_s, z ] ].each do |array|

              t, axis = *array

              # original
              # can we not throw away the last point?
              # if( t.length != axis.length )
              #  t_l, a_l = t.length, axis.length
              #  if( t_l < a_l )
              #    axis.pop
              #  end
              # end

              if( t.length != axis.length )
                t_l, a_l = t.length, axis.length
                if( t_l < a_l )
                  # t << axis.last
                  t << t.last # best guess?
                end
              end

              gsl_t, gsl_axis           = GSL::Vector.alloc( t ), GSL::Vector.alloc( axis )
              coef, err, chisq, status  = GSL::MultiFit::polyfit( gsl_t, gsl_axis, polynom_order )

              # result_splines << [ coef, err, chisq, status ]
              result_splines << coef

              # Standard error estimate
              #err_sum = err.to_na.to_a.inject(0) { |r,e| r + e }
              #err_final = Math.sqrt( err_sum / ( ( err.to_na.to_a.length - 1 ) - 2 ) )
              errors += err.to_na.to_a
              # printf( "Error: %-20s\n", err_final.to_s )
            end

            cluster_smooth  = []
            s1_coef, s2_coef, s3_coef = *result_splines

            t_s.each_index do |i|
              s1_t, s2_t, s3_t = s1_coef.eval( t_s[i] ), s2_coef.eval( t_s[i] ), s3_coef.eval( t_s[i] )

              cluster_smooth << [ s1_t, s2_t, s3_t ]
            end

            x1 = cluster_smooth.shift( c1_length )
            x2 = cluster_smooth.shift( c2_length )

            # temp_container += cluster_smooth
            temp_container += x1
            coordinate_chunks.insert(0, x2 ) 
          else
            # cluster is empty
          end

        end # while
        # end # of coordinate_chunks.each do |cluster|




        #err_sum = errors.inject(0) { |r,e| r + e }
        #err_final = Math.sqrt( err_sum / ( ( errors.length - 1 ) - 2 ) )
        #puts "standard error of the estimate: #{ (err_final * 100 ).to_s} %"


        @log.message :info, "Over-writing new filtered data to output ADT object"

        t_container = pca.reshape_data( temp_container, true, false )

        xtran, ytran, ztran = t_container.shift, t_container.shift, t_container.shift

        # @log.message :warning, "Size changed (bug in filter) - size of frames is now #{xtran.length.to_s} should be #{input.frames.to_s}"
        # @log.message :warning, "Size changed (bug in filter) - size of frames is now #{xtran.length.to_s} "

        eval( "input.#{s.to_s}.xtran = xtran" )
        eval( "input.#{s.to_s}.ytran = ytran" )
        eval( "input.#{s.to_s}.ztran = ztran" )

      end # of if( segments.include?( 
    end # of %w[pt27...


    input
  end # of def motion_capture_data_smoothing }}}


  # @fn       def box_car_filter input, order = 5 # {{{
  # @brief    In order to extract meaningful information easily we utilize a box car or FIR filter known from DSP theory.
  #
  # @param    input   Array containing beat [ [ time, energy value ], ...]
  # @param    order   N is the filter order; an Nth-order filter has (N + 1) terms on the right-hand
  #                   side. The x[n − i] in these terms are commonly referred to as taps, based on the structure of a
  #                   tapped delay line that in many implementations or block diagrams provides the delayed inputs to
  #                   the multiplication operations. One may speak of a "5th order/6-tap filter", for instance.
  #
  # @info     http://en.wikipedia.org/wiki/Finite_impulse_response
  #           htttp://groups.google.com/group/comp.dsp/msg/d0d2324de8451878  
  #
  # @returns  Array, containing time t and beat energy e box car'ed. [ [t0,e0], [t1,e1], ... ]
  def box_car_filter input = nil, order = 5

    # Input verification {{{
    raise ArgumentError, "Input cannot be nil" if( input.nil? )
    raise ArgumentError, "Order cannot be nil" if( order.nil? )
    # }}}

    # y[n] = \sum_{i=0}^{N} b_i x[n - i]
    #  - x[n] is the input signal,
    #  - y[n] is the output signal,
    #  - bi are the filter coefficients, also known as tap weights, that make up the impulse response,
    #  - N is the filter order; an Nth-order filter has (N + 1) terms on the right-hand side.

    y = []

    # split time and energy
    x = input.collect { |a,b| b }

    cnt = 0

    while( not x.empty? )
      
      # take adjacent samples
      old_chunk = x.shift( order )
      chunk     = old_chunk.dup

      # compute average
      average = ( chunk.inject(0) { |b,i| b+i } ) / ( chunk.length )
  
      # push result to array
      y[ cnt ] = average
      cnt += 1
  
      # throw away one sample and repeat
      old_chunk.shift
      x = old_chunk.concat( x )
    end # of while

    # recombine time and FIR result into array of subarrays
    result = ( input.collect { |a,b| a } ).zip( y )
    result

#
#    0.upto( x.length - 1 ) do |n|
#
#      sum = 0
#      0.upto( order ) do |i|
#
#        # moving average filter (boxcar)
#        b = 1 / ( i + 1 )
#
#        sum += ( b * x[n - i] ) unless( 0 < (n - i) )
#
#      end # of 0.upto( order ) do |i|
#
#      y[ n ] = sum
#    end # of 0.upto( x.length ) do |n|
#
#    # recombine time and FIR result into array of subarrays
#    result = ( input.collect { |a,b| a } ).zip( y )
#    result
  end # of def box_car_filter }}}


end # of class Filter }}}


# Direct Invocation (local testing) # {{{
if __FILE__ == $0
end # of if __FILE__ == $0 }}}

# vim:ts=2:tw=100:wm=100
