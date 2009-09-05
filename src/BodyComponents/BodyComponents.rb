#!/usr/bin/ruby
#

###
#
# File: BodyComponents.rb
#
######


###
#
# (c) 2009, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       BodyComponents.rb
# @author     Bjoern Rennhak
# @since      Fri Jul  3 05:23:16 JST 2009
# @version    0.0.1
# @copyright  See COPYRIGHT file for details.
#
#######

# Deep_Clone hack
require 'Extensions.rb'

# From MotionX - FIXME: Use MotionX's XYAML interface
require 'ADT.rb'



###
#
# @class   BodyComponents
# @author  Bjoern Rennhak
# @brief   BodyComponents tries to extract Keyposes based on arms movement via projection from 3D to 2D
# @details 
# @param   file File represents a string of path/filename where the vpm data can be found
#
#######
class BodyComponents
  def initialize file
    @file = file

    puts "Loading file..."
    vpm = ADT.new( file )
    puts "Finished loading file..."

    ## b0rked! Singleton methods - but where??! (?? http://doc.okkez.net/191/view/method/Object/i/initialize_copy )
    ## Speedup by loading a Marshalled object from /tmp/ if previously run
    #if File.exist?( "/tmp/BodyComponents_Marshall_VPM_Data.tmp" )
    #  puts "Loading Marshal dump I found in /tmp/BodyComponents_Marshall_VPM_Data.tmp for speedup"
    #  vpm = Marshal.load( File.read("/tmp/BodyComponents_Marshall_VPM_Data.tmp").readlines.to_s )
    #else
    #  vpm   = ADT.new( file )
    #  x = vpm.deep_clone.to_s

    #  puts "Creating Marshal dump for later speedups (/tmp/BodyComponents_Marshall_VPM_Data.tmp)"
    #  o = Marshal.dump( x )
    #  File.open( "/tmp/BodyComponents_Marshall_VPM_Data.tmp", File::CREAT|File::TRUNC|File::RDWR, 0644) { |f| f.write( o.to_s ) }
    #end


    # p vpm.segments
    # See shiratori thesis page 132


    # === Get Midpoint coordinates of Left and Right arm where coord xWRB and xWRA
    # --- Right arm 
    relb = vpm.relb # elbow

    rwrb = vpm.rwrb # hand joint but NOT middle point
    rwra = vpm.rwra # hand joint but NOT middle point

    coordsRWRB = rwrb.getCoordinates!
    coordsRWRA = rwra.getCoordinates!

    puts "RWRC Calculation (RWRC = RWRA - RWRB)" 
    rwrc = Array.new

    [ coordsRWRB, coordsRWRA ].transpose.each do |array1, array2|
      rwrc << midPointOfTwoCoordinates( array1, array2 )
    end

    puts "RWRC Length -> #{rwrc.length.to_s}"

    # --- Left arm
    lelb = vpm.lelb # elbow

    lwrb = vpm.lwrb # hand joint but NOT middle point
    lwra = vpm.lwra # hand joint but NOT middle point

    coordsLWRB = lwrb.getCoordinates!
    coordsLWRA = lwra.getCoordinates!

    puts "LWRC Calculation (LWRC = LWRA - LWRB)" 
    lwrc = Array.new

    [ coordsLWRB, coordsLWRA ].transpose.each do |array1, array2|
      lwrc << midPointOfTwoCoordinates( array1, array2 )
    end

    puts "LWRC Length -> #{lwrc.length.to_s}"

    # === Generate line through elbow and xWRC
    # y = m*x + t
    # puts "Generate line RIGHT ARM"
    # p relb.getCoordinates!.first
    # p rwrc.first

    # first frame center of mass
    # centerOfMass(   )
    pt25 = ( pt4  + pt8 ) / 2
    pt28 = ( pt12 + pt13 ) / 2
    pt29 = ( pt18 + pt19 ) / 2
    pt30 = ( pt28 + pt28 ) / 2
    pt31 = ( pt25 + ( 2 * pt30 ) ) / 3

  end

  # = The function midPointOfTwoCoordinates bascially just averages two given coordinates and returns a new 3D coordinate which is the mid point of both.
  # @params array1 Array1 is an array with three floats
  # @params array2 Array2 is an array with three floats
  # @returns Returns an array with a new set of x,y,z coords
  def midPointOfTwoCoordinates array1, array2
    x1, y1, z1 = *array1
    x2, y2, z2 = *array2

    x = ( x1 + x2 ) / 2
    y = ( y1 + y2 ) / 2
    z = ( z1 + z2 ) / 2

    return [ x, y, z ]
  end


  # = Determine the center of mass from a given set of coords
  def centerOfMass

  end


  # == Dynamical method creation at run-time
  # @param method Takes the method header definition
  # @param code Takes the body of the method
  def learn method, code
      eval <<-EOS
          class << self
              def #{method}; #{code}; end
          end
      EOS
  end



  attr_accessor :vpm
  # attr_reader 
  # attr_writer
end


# Direct invocation, for manual testing beside rspec
if __FILE__ == $0
  b = BodyComponents.new( "../../sample/Aizu_Female.vpm" )
  

end


# vim=ts:2

