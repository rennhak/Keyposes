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


# Standard includes
require 'gsl'

# Custom includes
require 'Extensions.rb'                                 # Deep_Clone hack

# From MotionX - FIXME: Use MotionX's XYAML interface
require 'ADT.rb'

# Change Namespace
include GSL


###
#
# @class   BodyComponents
# @author  Bjoern Rennhak
# @brief   BodyComponents tries to extract Keyposes based on arms movement via projection from 3D to 2D
# @details 
# @param   file File represents a string of path/filename where the vpm data can be found
#
#######
class BodyComponents # {{{

  def initialize file # {{{
    @file = file

    puts "Loading file..."
    @adt = ADT.new( file )
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

  end # of initialize }}}



  # = getTurningPoints returns a set of values after turning point calculation (B. Rennhak's Method '09)
  # takes four segments ( a,b,c,d - 2 for each line (a+b) (c+d) ) one segment for
  # @param segment1a Name of segment which together with segment1b builds a 3D line
  # @param segment1b Name of segment which together with segment1a builds a 3D line
  # @param segment2a Name of segment which together with segment2b builds a 3D line
  # @param segment2b Name of segment which together with segment2a builds a 3D line
  # @param center Name of segment which is our coordinate center for measurement and projection (3D->2D)
  # @param from Expects a number indicating to start from which time frame
  # @param to Expects a number indicating to end on which time frame
  # @param direction Expects a string of either "xy", "xz" or "yz" (direction of extraction)
  # @returns Array, containing the points after the calculation
  # @warning FIXME: This thing is too slow, speed it up
  def getTurningPoints segment1 = "pt27", segment2 = "relb", segment3 = "pt26", segment4 = "lelb", center = "p30", direction = "xy", from = nil, to = nil # {{{

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
    pt30 = @adt.pt30
    pt27 = @adt.pt27
    pt9  = @adt.relb
    pt26 = @adt.pt26
    pt5  = @adt.lelb

    # Make coords relative to p30 not global -- not normalized
    pt27new           = pt27 - pt30
    pt9new            = pt9  - pt30
    slopeCoordsVars1  = []

    pt26new           = pt26 - pt30
    pt5new            = pt5  - pt30
    slopeCoordsVars2  = []

    [ pt27new.getCoordinates!.zip( pt9new.getCoordinates! ) ].each do |array|
      array.each do |point27Array, point9Array|
        slopeCoordsVars1 << getSlopeForm( point27Array, point9Array, direction )
      end
    end

    [ pt26new.getCoordinates!.zip( pt5new.getCoordinates! ) ].each do |array|
      array.each do |point26Array, point5Array|
        slopeCoordsVars2 << getSlopeForm( point26Array, point5Array, direction )
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

    # get the norms
    normX, normY = 0, 0
    points.each do |p1,p2|
      normX += p1**2
      normY += p2**2
    end

    normX = Math.sqrt(normX)
    normY = Math.sqrt(normY)

    points.each do |p1, p2|

      x = pt30Coords[n].shift
      y = pt30Coords[n].shift
      z = pt30Coords[n].shift


      norm = false

      if( norm )
        final << [ "#{n.to_s}, #{((p1/normX)-x).to_s}, #{((p2/normY)-y).to_s}" ]
      else
        length = Math.sqrt( (x*x) + (y*y) + (z*z) )
        final << [ "#{n.to_s}, #{ ((p1-x)/length).to_s}, #{((p2-y)/length).to_s}" ]
      end

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

  # TODO: We need to abstract all this out of all programs into a own math lib (DRY!!)
  def getNorm x, y, z # {{{
    Math.sqrt( (x*x) + (y*y) + (z*z) )
  end # of def getNorm }}}

  # Distance between Lines and Segments with their Closest Point of Approach
  # http://softsurfer.com/Archive/algorithm_0106/algorithm_0106.htm
  # @param line1_pt0 Segment class
  # @param line1_pt1 Segment
  # @param line2_pt0 Segment
  # @param line2_pt1 Segment
  # Deprec: @returns Array of scalars with the distances between line1(a,b) and line2(c,d)
  # @returns Segment dP which is the new closest point for all frames f
  def distance_of_line_to_line line1_pt0, line1_pt1, line2_pt0, line2_pt1
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

    return dP
  end # of def distance_3D_line_to_line



  # = getTrianglePatch returns a set of values after turning point calculation (B. Rennhak's Method '10)
  # takes four segments ( a,b,c,d - 2 for each line (a+b) (c+d) ) one segment for
  # @param segment1a Name of segment which together with segment1b builds a 3D line
  # @param segment1b Name of segment which together with segment1a builds a 3D line
  # @param segment2a Name of segment which together with segment2b builds a 3D line
  # @param segment2b Name of segment which together with segment2a builds a 3D line
  # @param center Name of segment which is our coordinate center for measurement and projection (3D->2D)
  # @param from Expects a number indicating to start from which time frame
  # @param to Expects a number indicating to end on which time frame
  # @param direction Expects a string of either "xy", "xz" or "yz" (direction of extraction)
  # @returns Array, containing the points after the calculation
  # @warning FIXME: This thing is too slow, speed it up
  def getTrianglePatch segment1 = "pt27", segment2 = "relb", segment3 = "pt26", segment4 = "lelb", center = "p30", direction = "xy", from = nil, to = nil # {{{

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
    pt30 = @adt.pt30
    pt27 = @adt.pt27
    pt9  = @adt.relb
    pt26 = @adt.pt26
    pt5  = @adt.lelb
    ptP  = distance_of_line_to_line( pt9, pt27, pt5, pt26 )

    # Point l1_1 :   pt9  (right elbow)
    # Point l1_2 :   pt27 (right wrist)
    # Point l2_1 :   pt5  (left elbow)
    # Point l2_2 :   pt26 (left wrist)
    # Point P    :   Intersection of L1 & L2 (CPA Approach)

    # Area of triangle:   line0( pt5, pt9 )  line1( pt9, pt27 )   line2( pt5, pt26 )
    arms = pt5.area_of_triangle( pt9, ptP )
    

    # Lower body via Tibia
    # Area of triangle:   line0( pt14, pt20 )   line1( pt20, pt21 )   line2( pt14, pt15  )
    pt14  = @adt.lkne
    pt20  = @adt.rkne
    pt21  = @adt.rank
    pt15  = @adt.lank
    ptP  = distance_of_line_to_line( pt20, pt21, pt14, pt15 )
    legs = pt14.area_of_triangle( pt20, ptP )

    result = []
    [arms, legs].transpose.each do |array|
      arm, leg = *array
      #result << ( arm * leg ) / ( Math.sqrt( (arm*arm) + (leg*leg)) )
      result << ( arm * leg ) # / ( Math.sqrt( (arm*arm) ))
    end
    result


#    [ pt27new.getCoordinates!.zip( pt9new.getCoordinates! ) ].each do |array|
#      array.each do |point27Array, point9Array|
#        slopeCoordsVars1 << getSlopeForm( point27Array, point9Array, direction )
#      end
#    end
#
#    [ pt26new.getCoordinates!.zip( pt5new.getCoordinates! ) ].each do |array|
#      array.each do |point26Array, point5Array|
#        slopeCoordsVars2 << getSlopeForm( point26Array, point5Array, direction )
#      end
#    end 
#
#    points = []
#
#    # Determine the intersection point of the two lines
#    [ slopeCoordsVars1.zip( slopeCoordsVars2 ) ].each do |array|
#      array.each do |line1, line2|  # line1 == [m, t]   --> f(x) y = m*x + t
#        points << getIntersectionPoint( line1, line2 )
#      end
#    end
#
#    pt30Coords = pt30.getCoordinates!
#    pt5Coords  = pt5.getCoordinates!
#    pt9Coords  = pt9.getCoordinates!
#
#    final = []
#    n = 0
#
#    # get the norms
#    normX, normY = 0, 0
#    points.each do |p1,p2|
#      normX += p1**2
#      normY += p2**2
#    end
#
#    normX = Math.sqrt(normX)
#    normY = Math.sqrt(normY)
#
#    points.each do |p1, p2|
#
#      x = pt30Coords[n].shift
#      y = pt30Coords[n].shift
#      z = pt30Coords[n].shift
#
#      pt5_x   = pt5Coords[n].shift
#      pt5_y   = pt5Coords[n].shift
#      pt5_z   = pt5Coords[n].shift
#
#      pt9_x   = pt9Coords[n].shift
#      pt9_y   = pt9Coords[n].shift
#      pt9_z   = pt9Coords[n].shift
#
#      norm = false
#
#      if( norm )
#        # final << [ "#{n.to_s}, #{((p1/normX)-x).to_s}, #{((p2/normY)-y).to_s}" ]
#      else
#        # length = Math.sqrt( (x*x) + (y*y) + (z*z) )
#        # final << [ "#{n.to_s}, #{ ((p1-x)/length).to_s}, #{((p2-y)/length).to_s}" ]
#        
#        a = [ pt5_x / getNorm( pt5_x, pt5_y, pt5_z ), pt5_y / getNorm( pt5_x, pt5_y, pt5_z ) ] # is this projecction ok? Can I just drop z under the table?
#        b = [ pt9_x / getNorm( pt9_x, pt9_y, pt9_z ), pt9_y / getNorm( pt9_x, pt9_y, pt9_z ) ]
#        c = [ p1 / getNorm( p1, p2, 0 ), p2 / getNorm( p1, p2, 0 ) ]    # p1 = x, p2 = y ---> point c on plane ..
#
#
#        # puts "a (#{a.join(", ")}), b (#{b.join(", ")}), c (#{c.join(", ")})"
#        # Using Cartesian coordinates with a general determinant
#        # http://en.wikipedia.org/wiki/Triangle
#        # Area = 0.5 * |  (x_a - x_c) * (y_b - y_a) - (x_a - x_b) * (y_c - y_a) |
#        area = 0.5 * ( ( (a.first - c.first)*(b.last - a.last) ) - ( (a.first - b.first)*(c.last - a.last) ) ).abs
#
#
#        # Three dimansional area of general triangle
#        # Area = 0.5 * | 
#
#        final << [ "#{n.to_s}, #{area.to_s}" ]
    #  end

    #  n += 1
    #end

#    # Modify our array if we want only a certain range
#    if( from.nil? )
#      if( to.nil? )
#        # from && to == nil
#        # do nothing, we have already all resuts
#      else
#        # from == nil ; to != nil
#        # we start from 0 upto to
#        final = eval( "final[0..#{to}]" )
#      end
#    else
#      if( to.nil? )
#        # from != nil ; to == nil
#        final = eval( "final[#{from}..-1]" )
#      else
#        # from && to != nil
#        final = eval( "final[#{from}..#{to}]" )
#      end
#    end
#
    #final

  end # end of getTrianglePatch }}}


  # = maxDensePoints takes 
  def maxDensePoints # {{{

  end # }}}
  

  # = eucleadianDistance takes 
  def eucleadianDistance x1, y1, x2, y2 # {{{
    Math.sqrt( ( (x2 - x1) ** 2 ) + ( (y2 - y1) ** 2  )  )
  end # }}}


  # = getKeyposes takes a given results from getTurningPoints and extracts Keyposes
  # @param tp Parameter needs results from the getTurningPoints function which is an array
  # @param window Parameter needs an integer which defines the size of the eucleadian mean distance sample window. (see paper for reference)
  #               This means that e.g. 20 values around each point n (x,y)  \forall n-(window/2)->n+(window/2) will be taken and then their
  #               distance will be summarized for weighting of point n.
  # @returns Array, with extracted Keyposes information.
  def getKeyposes tp = getTurningPoints( "p26", "relb", "p26", "lelb", "p30", "xy" ), window = 30 # {{{
    # 1.) get tp frames and get approx grad results
    # 2.) calculate eucleadian distance over a mean point of size "window"
    # 3.) calculate dense frames as special
    # 4.) calculate Keyposes and other candidates 
    # 5.) refine Keyposes and get rid of false positives
    

  end # of getKeyposes }}}


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
    s1, s2            = eval( "@adt.#{segment2.to_s}.getCoordinates!" ), eval( "@adt.#{segment2.to_s}.getCoordinates!" )

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


  # = approxGradient is a very simple and naive approximation for a real gradient calculation
  # @param x X-Coordinate of a given point p
  # @param y Y-Coordinate of a given point p
  # @returns Float, rough and naive approximation of a gradient of point p(x,y)
  # @warning FIXME: This method should be substituted by a real derivative calculation
  def approxGradient x, y # {{{
    ( x.to_f + y.to_f**2 )
  end # of approxGradient }}}


  # = getSlopeForm returns a solution of the following:
  #   Two points p1 (x,y,z) and p2 (x2,y2,z2) span a line in 2D space.
  #   The slope form also known as f(x) =>  y = m*x + t 
  #   m = DeltaY / DeltaX  ; where DeltaY is the Y2 - Y1 ("steigung")
  # @param array1 Set of coordinates Point A
  # @param array2 Set of coordinates Point B
  # @param direction String which is either "xy", "xz", "yz"
  # @returns Array, containing m and t for the slope form equasion
  # @warning FIXME: Z coordinate is only neglegted and this needs to be normally compensated
  def getSlopeForm array1, array2, direction = "xy" # {{{
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
  def learn method, code # {{{
      eval <<-EOS
          class << self
              def #{method}; #{code}; end
          end
      EOS
  end # end of learn( method, code ) }}}

  attr_accessor :adt
end # of class BodyComponents }}}


# Direct invocation, for manual testing beside rspec
if __FILE__ == $0 # {{{

  file    = ARGV.first
  bc      = BodyComponents.new( file )
  
  f = File.open( "weigths.csv" ).readlines
  weights = []
  f.each do |l|
    w, i, v = l.split(",")
    v.chomp!
    weights << v.to_f
  end  

  tri = bc.getTrianglePatch
  totalNorm = 0
  tri.each { |area| totalNorm += Math.sqrt( area.to_f * area.to_f )  }
  totalNorm / tri.length

  [tri, weights].transpose.each do |area, weight|
    #puts "Tri: #{area.to_s}   Weight: #{weight.to_s}"
    puts ( area.to_f  ) * weight.to_f
    # puts area.to_f / totalNorm
    # puts area.to_f
  end

  #bc.getTrianglePatch.each do |line|
  #  index, area = line.to_s.split(",")
  #  puts "#{index.to_s}, #{area.to_s}" # if( area.to_i <= 600 )
  #end

end # }}}


# vim=ts:2

