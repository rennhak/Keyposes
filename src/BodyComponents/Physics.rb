#!/usr/bin/ruby
#

###
#
# File: Physics.rb
#
######


###
#
# (c) 2009-2011, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       Physics.rb
# @author     Bjoern Rennhak
#
#######


require_relative 'Mathematics.rb'


# The class Physics provides helpful functions to calculate various things needed throughout this project
class Physics # {{{

  def initialize # {{{
    @mathematics = Mathematics.new

  end # of def initialize }}}


  # The function velocity calculates the phyiscal velocity at each point for the data
  #
  # @param    [Array]   data                Accepts array of arrays in the shape of [ [x2,y1,z1], [...], ...]
  # @param    [Integer] points              Determines how many points should be used for the overall velocity calculation
  # @param    [Float]   capturingIntervall  Accepts float, representing the capture intervall of the motion capture equipment
  # @returns  [Array]                       Array containing corresponding velocity values for the frames n and n+1
  def velocity data, points, capturingIntervall = 0.08333 # {{{

    # Pre-condition check {{{
    raise ArgumentError, "The argument data should be of type Array, but it is of (#{data.class.to_s})" unless( data.is_a?( Array ) )
    raise ArgumentError, "The argument points should be of type Integer, but it is of (#{points.class.to_s})" unless( points.is_a?( Integer ) )
    raise ArgumentError, "The argument capturingIntervall should be of type float, but it is of (#{capturingIntervall.class.to_s})" unless( capturingIntervall.is_a?( Float ) )
    raise ArgumentError, "Data must be in the shape [ [x1,y1,z1], [...], ...]" if( data.length == 3 )
    # }}}

    # Main
    result        = []


    all_distances = @mathematics.eucledian_distance_window( data.dup, points ) 

    data.each_index do |i|
      if( i <= (data.length - 2) )
        result[ i ]     = all_distances[ i ].to_f / ( capturingIntervall.to_f * points )
      end
    end

    # Post-condition check
    raise ArgumentError, "Result of this function is supposed to be of type Array, but it is of (#{result.class.to_s})" unless( result.is_a?(Array) )

    result
  end # of def velocity data }}}


  # The function acceleration calculates the phyiscal acceleration at each point for the data
  #
  # @param    [Array]   data                Accepts array of arrays in the shape of [ [x1,y1,z1], ...]
  # @param    [Integer] points              Determines how many points should be used for the overall acceleration calculation
  # @param    [Float]   capturingIntervall  Accepts float, representing the capture intervall of the motion capture equipment
  # @returns  [Array]                       Array containing corresponding acceleration values for the frames n and n+1
  def acceleration data, points, capturingIntervall = 0.08333 # {{{

    # Pre-condition check {{{
    raise ArgumentError, "The argument data should be of type Array, but it is of (#{data.class.to_s})" unless( data.is_a?( Array ) )
    raise ArgumentError, "The argument points should be of type Integer, but it is of (#{points.class.to_s})" unless( points.is_a?( Integer ) )
    raise ArgumentError, "The argument capturingIntervall should be of type float, but it is of (#{capturingIntervall.class.to_s})" unless( capturingIntervall.is_a?( Float ) )
    raise ArgumentError, "Data must be in the shape [ [x1,y1,z1], [...], ...]" if( data.length == 3 )
    # }}}

    # Main
    result        = []
    v             = velocity( data, points, capturingIntervall )

    data.each_index do |i|
      if( i <= (data.length - 2) )
        result[ i ]     = v[i] / ( capturingIntervall.to_f * points )
      end
    end # of data.each_index

    # Post-condition check
    raise ArgumentError, "Result of this function should be of type Array, but is (#{result.class.to_s})" unless( result.is_a?( Array ) )

    result
  end # of def acceleration data }}}


  # The function power calculates the phyiscal power at each point for the data
  #
  # @param    [Array]   data                Accepts array of arrays in the shape of [ [x1,y1,z1], ...]
  # @param    [Float]   mass                Accepts float, representing the mass of the components involved (relative to 100% = full body)
  # @param    [Integer] points              Determines how many points should be used for the overall acceleration calculation
  # @param    [Float]   capturingIntervall  Accepts float, representing the capture intervall of the motion capture equipment
  # @returns  [Array]                       Array containing corresponding power values for the frames n and n+1 
  def power data, mass, points, capturingIntervall = 0.08333 # {{{

    # Pre-condition check {{{
    raise ArgumentError, "The argument data should be of type Array, but it is of (#{data.class.to_s})" unless( data.is_a?( Array ) )
    raise ArgumentError, "The argument mass should be of type Float, but it is of (#{mass.class.to_s})" unless( mass.is_a?( Float ) )
    raise ArgumentError, "The argument points should be of type Integer, but it is of (#{points.class.to_s})" unless( points.is_a?( Integer ) )
    raise ArgumentError, "The argument capturingIntervall should be of type float, but it is of (#{capturingIntervall.class.to_s})" unless( capturingIntervall.is_a?( Float ) )
    raise ArgumentError, "Data must be in the shape [ [x1,y1,z1], [...], ...]" if( data.length == 3 )
    # }}}

    # Main
    result        = []

    a             = acceleration( data.dup, points, capturingIntervall )
    v             = velocity( data.dup, points, capturingIntervall )

    data.each_index do |i|
      if( i <= (data.length - 2) )
        result[ i ]     = mass * a[i] * v[i]
      end
    end # of data.each_index

    # Post-condition check
    raise ArgumentError, "Result of this function should be of type Array, but is (#{result.class.to_s})" unless( result.is_a?( Array ) )

    result
  end # of def power data }}}


  # The function energy calculates the phyiscal energy at each point for the data
  #
  # @param    [Array]   data                Accepts array of arrays in the shape of [ [x1,y1,z1], ...]
  # @param    [Float]   mass                Accepts float, representing the mass of the components involved (relative to 100% = full body)
  # @param    [Integer] points              Determines how many points should be used for the overall acceleration calculation
  # @returns  [Array]                       Array containing corresponding energy values for the frames n and n+1 
  def energy data, mass, points # {{{

    # Pre-condition check {{{
    raise ArgumentError, "The argument data should be of type Array, but it is of (#{data.class.to_s})" unless( data.is_a?( Array ) )
    raise ArgumentError, "The argument mass should be of type Float, but it is of (#{mass.class.to_s})" unless( mass.is_a?( Float ) )
    raise ArgumentError, "The argument points should be of type Integer, but it is of (#{points.class.to_s})" unless( points.is_a?( Integer ) )
    raise ArgumentError, "Data must be in the shape [ [x1,y1,z1], [...], ...]" if( data.length == 3 )
    # }}}

    # Main
    result    = []
    v         = velocity( data.dup, points )

    data.each_index do |i|
      if( i <= (data.length - 2) )
        # Kinetic energy    E_kin = 0.5 * m * v^2
        e_kin = 0.5 * mass * ( v[ i ].to_f ** 2 )
        result[ i ] = e_kin
      end
    end

    # Post-condition check
    raise ArgumentError, "Result of this function should be of type Array, but is (#{result.class.to_s})" unless( result.is_a?( Array ) )

    result
  end # of def energy data }}}



end # of class Physics }}}


# Direct Invocation
if __FILE__ == $0 # {{{

end # of if __FILE__ == $0 }}}
