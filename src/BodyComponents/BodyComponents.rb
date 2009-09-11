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

  end



  # = getTurningPoints returns a set of values after turning point calculation (B. Rennhak's Method '09)
  # takes four segments ( a,b,c,d - 2 for each line (a+b) (c+d) ) one segment for
  # @param segment1a Name of segment which together with segment1b builds a 3D line
  # @param segment1b Name of segment which together with segment1a builds a 3D line
  # @param segment2a Name of segment which together with segment2b builds a 3D line
  # @param segment2b Name of segment which together with segment2a builds a 3D line
  # @param center Name of segment which is our coordinate center for measurement and projection (3D->2D)
  # @param from Expects a number indicating to start from which time frame
  # @param to Expects a number indicating to end on which time frame
  # @returns Array, containing the points after the calculation
  # @warning FIXME: This thing is too slow, speed it up
  def getTurningPoints segment1 = "pt27", segment2 = "relb", segment3 = "pt26", segment4 = "lelb", center = "p30", from = nil, to = nil # {{{

    #####
    #
    # Reference case
    # e.g. S. Kudoh Thesis, Page 109, VPM File used "Aizu_Female.vpm"
    #
    # Center of Coordinate System:  p30
    # Right Arm:                    p27 and p9 ("relb")
    # Left Arm:                     p26 and p5 ("lelb")
    #
    ###########

    # Easy handling
    pt30 = @pt30
    pt27 = @pt27
    pt9  = @relb
    pt26 = @pt26
    pt5  = @lelb

    # Make coords relative to p30 not global -- not normalized
    pt27new           = pt27 - pt30
    pt9new            = pt9  - pt30
    slopeCoordsVars1  = []

    pt26new           = pt26 - pt30
    pt5new            = pt5  - pt30
    slopeCoordsVars2  = []

    [ pt27new.getCoordinates!.zip( pt9new.getCoordinates! ) ].each do |array|
      array.each do |point27Array, point9Array|
        slopeCoordsVars1 << getSlopeForm( point27Array, point9Array )
      end
    end

    [ pt26new.getCoordinates!.zip( pt5new.getCoordinates! ) ].each do |array|
      array.each do |point26Array, point5Array|
        slopeCoordsVars2 << getSlopeForm( point26Array, point5Array )
      end
    end 

    points = []

    # Determine the intersection point of the two lines
    [ slopeCoordsVars1.zip( slopeCoordsVars2 ) ].each do |array|
      array.each do |line1, line2|  # line1 == [m, t]   --> f(x) y = m*x + t
        points << getIntersectionPoint( line1, line2 )
      end
    end

    pt30Coords = pt30.getCoordinates!
    final = []
    n = 0
    points.each do |p1, p2|

      x = pt30Coords[n].shift
      y = pt30Coords[n].shift
      z = pt30Coords[n].shift

      length = Math.sqrt( (x*x) + (y*y) + (z*z) )

      final << [ "#{n.to_s}, #{ ((p1-x)/length).to_s}, #{((p2-y)/length).to_s}" ]

      n += 1
    end

    # Modify our array if we want only a certain range
    if( from.nil? )
      if( to.nil? )
        # from && to == nil
        # do nothing, we have already all resuts
      else
        # from == nil ; to != nil
        # we start from 0 upto to
        final = eval( "final[0..#{to}]" )
      end
    else
      if( to.nil? )
        # from != nil ; to == nil
        final = eval( "final[#{from}..-1]" )
      else
        # from && to != nil
        final = eval( "final[#{from}..#{to}]" )
      end
    end

    final
  end # end of getTurningPoints }}}




  # = getPhi takes two segements and performs a simple golden ratio calculation for each coordinate pair
  #   A good reference would be \varphi = \frac{1 + \sqrt{5}}{2} \approx 1.61803339 \ldots
  # @param segment1 Expects a valid segment name, e.g. rwft
  # @param segment1 Expects a valid segment name, e.g. lwft
  # @returns Hash, containing reference Phi, calculated Phi from the segments and the difference, e.g. "[ 1.61803339.., 1.59112447, 0.2... ]"
  def getPhi segment1, segment2, frame = nil # {{{
    results                      = {}
    xtranPhi, ytranPhi, ztranPhi = [], [], []

    # calculate a reference phi
    results[ "phi" ]  = ( ( 1 + Math.sqrt(5) ) / 2 )

    # get Coordinate Arrays, e.g. [ [ ..., ..., ... ], [ ... ], ... ]
    s1, s2            = eval( "@#{segment1.to_s}.getCoordinates!" ), eval( "@#{segment2.to_s}.getCoordinates!" )

    # push all x, y and z values to the subarrays in #{$x}tranPhi
    s1.each_with_index { |array, index| x, y, z = *array ; %w[x y z].each { |var| eval( "#{var.to_s}tranPhi << [ #{var} ]" ) } }
    s2.each_with_index { |array, index| x, y, z = *array ; %w[x y z].each { |var| eval( "#{var.to_s}tranPhi[#{index}] << #{var}" ) } }

    # calculate phi for each timeframe
    xtranPhi.collect! { |a, b| ( ( a + b ) / a ) }
    ytranPhi.collect! { |a, b| ( ( a + b ) / a ) }
    ztranPhi.collect! { |a, b| ( ( a + b ) / a ) }

    results[ "xtranPhi" ] = ( frame.nil? ) ? ( xtranPhi ) : ( xtranPhi[ frame ] )
    results[ "ytranPhi" ] = ( frame.nil? ) ? ( ytranPhi ) : ( ytranPhi[ frame ] )
    results[ "ztranPhi" ] = ( frame.nil? ) ? ( ztranPhi ) : ( ztranPhi[ frame ] )

    results
  end # end of getPhi }}}


  # = getSlopeForm returns a solution of the following:
  #   Two points p1 (x,y,z) and p2 (x2,y2,z2) span a line in 2D space.
  #   The slope form also known as f(x) =>  y = m*x + t 
  #   m = DeltaY / DeltaX  ; where DeltaY is the Y2 - Y1 ("steigung")
  # @param array1 Set of coordinates Point A
  # @param array2 Set of coordinates Point B
  # @returns Array, containing m and t for the slope form equasion
  # @warning FIXME: Z coordinate is only neglegted and this needs to be normally compensated
  def getSlopeForm array1, array2 # {{{
    x1, y1, z1      = *array1
    x2, y2, z2      = *array2

    deltaX, deltaY  = ( x2 - x1 ), ( y2 - y1 )
    m               = deltaY / deltaX
    t               = y1 - ( m * x1 )

    [ m, t ]
  end # end of getSlopeForm }}}


  # = getIntersectionPoint returns a solution for the following:
  #   Two lines in slope intersection form f1 y = m*x + t  and f2 ...
  #   intersection in a point (or not -> the intersection with the origin is returned) and this point is returned.
  # @param array1 Array, with m and t of a line in slope form
  # @param array2 Array, with m and t of a line in slope form
  # @returns Array containing 2D point of intersection
  def getIntersectionPoint array1, array2 # {{{
    m1, t1 = *array1
    m2, t2 = *array2

    #     m1*x + t1   = m2*x + t2   | -m2*x - t1
    # <=> m1*x - m2*x = t2 - t1
    # <=> (m1-m2)*x   = t2 - t1     | / (m1-m2)
    # <=>         x   = (t2-t1) / (m1-m2)
    x       = ( t2 - t1 ) / ( m1 - m2 )
    y1, y2  = ( m1 * x + t1 ), ( m2 * x + t2 )

    # FIXME: This error occurs due to many decimals after the comma... use sprintf
    # FIXME: Assertion
    # raise ArgumentError, "Y1 and Y2 of the equasion has to be same. Something is b0rked. (,#{y1.to_s}' *** ,#{y2.to_s}')" unless y1 == y2

    [x,y1]
  end # end of getIntersectionPoint }}}


  # = determinat returns a solution for the following:
  #   Given two lines in slope intersection form f1 y = m*x +t and f2...
  #   the determinant is ad - bc ; three cases:
  #   -1  := No solution
  #    0  := One
  #    1  := Unlimited (you can invert it)
  def determinat array1, array2 # {{{
    # FIXME write a class for matrix functionality
  end # end of determinat }}}





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
end


# Direct invocation, for manual testing beside rspec
if __FILE__ == $0

  file  = ARGV.first
  bc    = BodyComponents.new( file )



#  adt     = ADT.new( "../sample/Aizu_Female.vpm" )
#  points  = adt.getTurningPoints( "p27", "relb", "p26", "lelb", "p30")
#  ret     = adt.writeCSV( "/tmp/results.csv", points )

#  adt     = ADT.new( "../sample/Jongara.vpm" )
#  points  = adt.getTurningPoints( "p27", "relb", "p26", "lelb", "p30", 1400, 1500 )
#  values = []
#  points.each do |string|
#    index, x, y = *(string.to_s.gsub(" ","").split(","))
#    index   = index.to_i
#    x       = x.to_f
#    y       = y.to_f
#
#    values << [index,x,y]
#  end
#
#  results = []
#  i = 0
#  threshhold = 1
#
#  # If the frame i we are in is a twisting point we set a 1 if not 0
#  values.each do |array|
#    index, x, y = array.shift, array.shift, array.shift
#    index   = index.to_i
#    x       = x.to_f
#    y       = y.to_f
#
#    if( values.length >= (i+2) )    # only get values in the range of our array
#      thisX = x
#      thisY = y
#
#      x2 = ((values[ i+1 ].to_s.gsub(" ","").split(","))[1]).to_f
#      y2 = ((values[ i+1 ].to_s.gsub(" ","").split(","))[2]).to_f
#
#      x3 = ((values[ i+2 ].to_s.gsub(" ","").split(","))[1]).to_f
#      y3 = ((values[ i+2 ].to_s.gsub(" ","").split(","))[2]).to_f
#
#
#      finalX = (x+x2+x3)/3.0
#      finalY = (y+y2+y3)/3.0
#
#      if( (finalX or finalY) >= threshhold )
#        results << 1
#      else
#        results << 0
#      end
#    else
#      # push a 0
#      results << 0
#    end
#
#    i += 1
#  end
#
#
#  #
#  # 1.) Ruby19
#  # 2.) RubyProf
#  # 3.) Tuning
#  #
#
##  results.each_with_index { |r, i| puts "#{i.to_s}  -> #{r.to_s}" }
#
#  #ret     = adt.writeCSV( "/tmp/results.csv", points )
#
#
#  # = PHI Calculation
#  # x = adt.getPhi( "pt24", "pt30", 10 )["ytranPhi"]
#  # p x = adt.getPhi( "pt26", "lsho", 10 )
#  # @results = []
#  # if( x.is_a?(Numeric) )
#  #   p x
#  # else
#  #   x.each_with_index { |val, index| @results << "#{index},#{( 1.61803398874989 - val ).abs}\n" }
#  #   File.open( "/tmp/foo", "w" ) { |f| f.write( "x,y\n" ); f.write( @results.to_s ) }
#  # end
#
## end # end of if __FILE__ == $0
#
#

end


# vim=ts:2

