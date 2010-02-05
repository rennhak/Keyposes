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
require 'Logger.rb'
require 'PCA.rb'
require 'Plotter.rb'
require 'Mathematics.rb'

# Change Namespace
include GSL


# The class Filter can take input data and provide means to filter out noise and outliers from it.
class Filter # {{{

  def initialize options, from, to # {{{
    @options             = options
    @from, @to           = from, to
    @log                 = Logger.new( @options )

    @mathematics         = Mathematics.new
  end # of def initialize }}}


  # The function takes a MotionX ADT Class as input and returns a filtered (smoothed) version of the input data
  # @param    [ADT]     input           ADT Class Object of the MotionX package VPM plugin
  # @param    [Integer] point_window    Integer representing the window size in which the polynomial fitting is applied
  # @param    [Integer] polynom_order   Integer representing the order of the fitting polynomial
  # @returns  [ADT]                     ADT Class Object containing the new smoothed version of the input
  def filter_motion_capture_data input, point_window = 20, polynom_order = 3 # {{{
  # point_window = 10, polynom_order = 5 

    # Pre-condition check {{{
    raise ArgumentError, "Input argument should be of type ADT, but is of type (#{input.class.to_s})" unless( input.is_a?(ADT) )
    raise ArgumentError, "Point window argument should be of type Integer, but is of (#{point_window.class.to_s})" unless( point_window.is_a?( Integer ) )
    raise ArgumentError, "Polynom order argument should be of type Integer, but is of (#{polynom_order.class.to_s})" unless( polynom_order.is_a?( Integer ) )
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

        coordinate_chunks = coordinates % point_window
        coordinate_chunks.each do |cluster|

          # # Lets get a point sample
          # n           = point_window
          # cluster     = []
          # coordinates.each_with_index do |points, index|
          #   cluster << points
          #   break if( index >= n )
          # end

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

            #if( t.length != point_window.to_i )
            #  puts "Not enough points for spline fitting skipping #{t.length.to_s} points for #{s.to_s}"
            #  next
            #end

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

          temp_container += cluster_smooth
        end # of coordinate_chunks.each do |cluster|

        #err_sum = errors.inject(0) { |r,e| r + e }
        #err_final = Math.sqrt( err_sum / ( ( errors.length - 1 ) - 2 ) )
        #puts "standard error of the estimate: #{ (err_final * 100 ).to_s} %"


        #pca.interactive_gnuplot( temp_container.slice( 0..20 ), "%e %e %e\n", %w[X Y Z],  "3d_plot_smooth.gp" )
        #exit

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

    # pca.interactive_gnuplot( input.rkne.getCoordinates!, "%e %e %e\n", %w[X Y Z],  "3d_plot.gp" )
    # pca.interactive_gnuplot( cluster_smooth, "%e %e %e\n", %w[X Y Z],  "3d_plot_smooth.gp" )

    input
  end # of def motion_capture_data_smoothing }}}


end # of class Filter }}}


# Direct Invocation
if __FILE__ == $0 # {{{

end # of if __FILE__ == $0 }}}
