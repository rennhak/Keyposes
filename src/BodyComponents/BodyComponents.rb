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

# Local
require 'PCA.rb'

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

  def initialize motion_config_file # {{{
    @config = read_motion_config( motion_config_file )
    @file   = @config.filename
    @from   = @config.from
    @to     = @config.to
    @name   = @config.name
    @dmps   = @config.dmp

    @dance_master_poses  = []
    @dance_master_poses_range = []
    @dmps.each { |dmp_array| @dance_master_poses << dmp_array.first; @dance_master_poses_range << dmp_array.last }

    @adt    = ADT.new( @file )

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



  # = do_pca_reduction returns a set of PCA reduced components
  # takes four segments ( a,b,c,d - 2 for each line (a+b) (c+d) ) one segment for
  # @param segment1 Name of segment which together with segment2 builds a body component
  # @param segment2 Name of segment which together with segment1 builds a body component
  # @param segment3 Name of segment which together with segment4 builds a body component
  # @param segment4 Name of segment which together with segment3 builds a body component
  # @param center Name of segment which is our coordinate center for measurement and projection
  # @param from Expects a number indicating to start from which time frame
  # @param to Expects a number indicating to end on which time frame
  # @returns Array, containing the points after the calculation
  def do_pca_reduction segment1 = "pt27", segment2 = "relb", segment3 = "pt26", segment4 = "lelb", center = "pt30", from = nil, to = nil # {{{

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

    # FIXME: Substitudte eval through the proper method which exists now in ruby core
    # Easy handling method internal
    center  = eval( "@adt.#{center.to_s}" )
    seg1    = eval( "@adt.#{segment1.to_s}" )
    seg2    = eval( "@adt.#{segment2.to_s}" )
    seg3    = eval( "@adt.#{segment3.to_s}" )
    seg4    = eval( "@adt.#{segment4.to_s}" )

    # Make coords relative to p30 not global -- not normalized
    seg1new           = seg1 - center
    seg2new           = seg2 - center
    seg3new           = seg3 - center
    seg4new           = seg4 - center

    # Modify our array if we want only a certain range
    # FIXME: Array.slice only supports start, length not from,to. Reimplement this properly.
    if( from.nil? )
      if( to.nil? )
        # from && to == nil
        # do nothing, we have already all resuts
        #puts "From and To Nil"
        seg1newCoord  = seg1new.getCoordinates!
        seg2newCoord  = seg2new.getCoordinates!
        seg3newCoord  = seg3new.getCoordinates!
        seg4newCoord  = seg4new.getCoordinates!
      else
        # from == nil ; to != nil
        # we start from 0 upto to
        #puts "From nil to not nil"
        seg1newCoord  = seg1new.getCoordinates![ eval( "0..#{to}" ) ]
        seg2newCoord  = seg2new.getCoordinates![ eval( "0..#{to}" ) ]
        seg3newCoord  = seg3new.getCoordinates![ eval( "0..#{to}" ) ]
        seg4newCoord  = seg4new.getCoordinates![ eval( "0..#{to}" ) ]
      end
    else
      if( to.nil? )
        # from != nil ; to == nil
        # e.g. from = 250 
        # totalLength - from = x
        #puts "From not nil to is nil"
        length = seg1new.getCoordinates!.length
        seg1newCoord  = seg1new.getCoordinates![ eval( "#{from}..#{length-from}" ) ]
        seg2newCoord  = seg2new.getCoordinates![ eval( "#{from}..#{length-from}" ) ]
        seg3newCoord  = seg3new.getCoordinates![ eval( "#{from}..#{length-from}" ) ]
        seg4newCoord  = seg4new.getCoordinates![ eval( "#{from}..#{length-from}" ) ]
      else
        # from && to != nil
        #puts "From (#{from.to_s}) not nil and to (#{to.to_s}) not nil"
        seg1newCoord  = seg1new.getCoordinates![ eval( "#{from}..#{to}" ) ]
        seg2newCoord  = seg2new.getCoordinates![ eval( "#{from}..#{to}" ) ]
        seg3newCoord  = seg3new.getCoordinates![ eval( "#{from}..#{to}" ) ]
        seg4newCoord  = seg4new.getCoordinates![ eval( "#{from}..#{to}" ) ]
      end
    end

    pca = PCA.new

    s1 = pca.reshape_data( seg1newCoord, true, false )
    s2 = pca.reshape_data( seg2newCoord, true, false )
    s3 = pca.reshape_data( seg3newCoord, true, false )
    s4 = pca.reshape_data( seg4newCoord, true, false )


    # FIXME
    #
    # Actually this approach is wrong
    # 1.) 3D line arm1 & 3D line arm2  --> CPA (3D Points)
    # 2.) all other components? 
    # 3.) All together via PCA into 3D ?

    # reduce 6D to 3D via PCA
    arm1, eigen_values1, eigen_vectors1   = pca.do_pca( (s1+s2), 3 )
    arm1_final                            = pca.clean_data( pca.transform_basis( arm1, eigen_values1, eigen_vectors1 ) )
    arm2, eigen_values2, eigen_vectors2   = pca.do_pca( (s3+s4), 3 )
    arm2_final                            = pca.clean_data( pca.transform_basis( arm2, eigen_values2, eigen_vectors2 ) )

    # ptP  = distance_of_line_to_line( pt9, pt27, pt5, pt26 )

    #pca.covariance_matrix_gnuplot( new, "cov.gp" )
    #pca.eigenvalue_energy_gnuplot( new, "energy.gp" )

    pca.interactive_gnuplot( pca.reshape_data( arm1_final, false, true ), "%e %e %e\n", %w[PC1 PC2 PC3],  "plot.gp", eigen_values1, eigen_vectors2 )

  end # end of do_pca_reduction }}}


  # = Osculating plane or Frenet Frame Method. Calculates the osculating place which is useful for
  #   determining the curvature, tangent and torsion of a 3D poly line. (finite difference based method)
  #
  #   More details see the "Frenet-Serret formula".
  #
  #   http://en.wikipedia.org/wiki/Osculating_plane
  #   http://en.wikipedia.org/wiki/Frenet%E2%80%93Serret_formulas
  #   http://newsgroups.derkeiler.com/Archive/Comp/comp.soft-sys.matlab/2008-04/msg03221.html
  #   Very good read: http://www.cs.sjsu.edu/faculty/rucker/kaptaudoc/ktpaper.htm
  #
  # @param data Accepts array of arrays. Polyline X = [x1,y1,z2; x2,y2,z2; ....; xN,yN,zN]
  #
  # @returns Array, containing [kappa,tau,T,N,B,s,ds]
  #          Kappa  -> (Unsigned) Curvature
  #          Tau    -> Torsion
  #          T      -> is the unit vector tangent to the curve, pointing in the direction of motion.
  #          N      -> is the derivative of T with respect to the arclength parameter of the curve, divided by its length.
  #          B      -> is the cross product of T and N.
  #          s      -> 
  #          ds     ->
  #
  # This function is based on the code found at
  # http://thedailyreviewer.com/compsys/view/curvature-of-a-curve-in-3d-109234866
  # - no name of the author was given.
  #
  # @warning The frenet frame doesn't always exist, the torsion is not defined when kappa = 0, there it gets interpolated.
  # @warning This method might not work well with noisy data. For noisy torsions it would be better to use quintic splines.
  #
  # Special cases:
  #
  #   o If the curvature is always zero then the curve will be a straight line. Here the vectors N, B and the torsion are not well defined.
  #   o If the torsion is always zero then the curve will lie in a plane. A circle of radius r has zero torsion and curvature equal to 1/r.
  #   o A helix has constant curvature and constant t
  def frenet_frame data, threshold = 0.001 # {{{

    # If we only have two points
    threshold = 0.001 if data.length <=  2

    # f = GSL::Function.alloc { |x|
    #    pow(x, 1.5)
    # }

    #   t_result = []

    #   h = 1e-8
    #   result, abserr = f.deriv_central(x, h)

    # FIXME Use rsruby for this --> do computations in GNU R since ruby is a pain .. or use matlab

    #T = 
    #T = diff(X); % dX/dt
    
    # exit

    []
  end # of def frenet_frame }}}

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
  # @param line1_pt0 Segment class (MotionX vpm plugin)
  # @param line1_pt1 Segment class (MotionX vpm plugin)
  # @param line2_pt0 Segment class (MotionX vpm plugin)
  # @param line2_pt1 Segment class (MotionX vpm plugin)
  # Deprec: @returns Array of scalars with the distances between line1(a,b) and line2(c,d)
  # @returns Segment dP which is the new closest point for all frames f
  def distance_of_line_to_line line1_pt0, line1_pt1, line2_pt0, line2_pt1 # {{{
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
  end # of def distance_3D_line_to_line }}}


  # = The function eucledian_distance_window takes a given dataset (x1,y1,z1;..) and calculates the
  # eucleadian distance for given points in both directions like a window function. That means that
  # with e.g. points = 5 ; 5 points before point X and 5 points after X are measured and summed up.
  #
  # @param data Array of arrays, in the form of [ [x,y,z],[..]...] .
  # @param points Accepts integer of how many points before and after should be included in the calculation
  # @returns Array, conaining floats. Each index of the array corresponds to the data frame.
  #
  # @todo Refactor this code more nicely.
  #
  # FIXME: This method is b0rked - infact the whole idea with data short/long type is nonsense
  def eucledian_distance_window data, points # {{{
    distances = []
    
    raise ArgumentError, "Data has not the right shape should be  [ [x,y,z],[..]...]" if( data.length == 3 )

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
            puts "Data has not the right shape (should be a 3D point) not (from idx: #{from.to_s} to idx: #{to.to_s} -> n: #{n.to_s} n+1: #{(n+1).to_s} -> d[n]: #{d[n].join(",").to_s} d[n+1]: #{d[n+1].join(",").to_s}"
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


  # = The eucledian_distance function takes two points in R^3 (x,y,z) and calculates the distance between them.
  #   You can easily derive this function via Pythagoras formula.
  # 
  #   P1,P2 \elem R^3
  #
  #   d(P1, P2) = \sqrt{ (x_2 - x_1)^2 + (y_2 - y_1)^2 + (z_2 - z_1)^2 }
  # 
  #   Further reading:
  #   http://en.wikipedia.org/wiki/Distance
  #   http://en.wikipedia.org/wiki/Euclidean_distance
  #
  # @param point1 Accepts array containing floats or integers (x,y,z)
  # @param point2 Accepts array containing floats or integers (x,y,z)
  # @returns Float, the distance between point 1 and point 2
  #
  # @todo Write a check that if 2D coords are passed only 2D eucleadian distance is performed
  def eucledian_distance point1, point2 # {{{
    raise ArgumentError, "Eucledian distance for 2D points is currently not implemented." if( (point1.length <= 2) or (point2.length <= 2) )

    x1, y1, z1 = *point1
    x2, y2, z2 = *point2

    Math.sqrt( ((x2-x1)**2) + ((y2-y1)**2) + ((z2-z2)**2) )
  end # of def eucledian_distance point1, point2 }}}


  # = The function interactive_gnuplot_eucledian_distances opens an X11 window in persist mode to view the data with the mouse.
  # @param data Accepts array of data with distances where each index is one frame (2D)
  # @param data_printf Accepts a formatting instruction like printf does, e.g. "%e, %e\n" etc.
  # @param labels Accepts an array containing strings with the labels for each subarray of data, e.g. %w[Frames Eucledian Distance Window Value]
  # @param filename Accepts string which represents the full path (absolute) with filename and extension (e.g. /tmp/file.ext)
  # @param from Accepts integer, representing the starting index of the motion sequence. 
  # @param pointsOfInterest Accepts array, containing integers. Each integer is a frame where we have a point of interest (e.g. frame of a dance master illustration drawing)
  def interactive_gnuplot_eucledian_distances data, data_printf, labels, title = "Plot", filename = "/tmp/tmp.plot.gp", data_filename = "/tmp/tmp/plot.gpdata", from = nil, pointsOfInterest = nil, pointsOfInterestRange = nil, pointsOfInterest_filename = nil, tp = nil, tp_filename = nil # {{{
    oldLabels = labels.dup

    File.open( filename.to_s, "w" ) do |f|
      f.write( "reset\n" )
      f.write( "set ticslevel 0\n" )
      f.write( "set style line 1 lw 3\n" )
      f.write( "set grid\n" )
      f.write( "set border\n" )
      f.write( "set pointsize 1\n" )

      f.write( "set xlabel '#{labels.shift.to_s}' font \"Helvetica,20\"\n" )
      f.write( "set ylabel '#{labels.shift.to_s}' font \"Helvetica,20\"\n" )
      f.write( "set autoscale\n" )
      f.write( "set font 'Helvetica,20'\n" )
      f.write( "set key left box\n" )
      f.write( "set output\n" )
      f.write( "set terminal x11 persist\n" )
      f.write( "set title '#{title}' font \"Helvetica,20\" \n" )

      if( pointsOfInterest.nil? )
        f.write( "plot '#{data_filename}' ti \"#{oldLabels.pop.to_s} per #{oldLabels.pop.to_s}\" w line\n" )
      else
        f.write( "plot '#{data_filename}' ti \"#{oldLabels.pop.to_s} per #{oldLabels.pop.to_s}\" w line lt 3, '#{pointsOfInterest_filename}' ti \"Poses from Dance Master Illustrations\" w xerrorbars lt 1 pt 7 ps 2, '#{tp_filename}' ti \"Turning poses\" w points 0 7, 'frenet_frame_kappa_plot.gpdata' ti \"Raw kappa\" w line, 'ekin.gpdata' w line\n" )
        #f.write( "plot '#{data_filename}' ti \"#{oldLabels.pop.to_s} per #{oldLabels.pop.to_s}\" w line, '#{pointsOfInterest_filename}' ti \"Poses from Dance Master Illustrations\" w xerrorbars lt 1 pt 7 ps 2, '#{tp_filename}' ti \"Turning poses\" w points 0 7, 'ekin.gpdata' ti \"Kinetic Energy\" w line, 'eucledian_distances_window_plot.gpdata' ti \"Eucledian Distance Window (speed)\" w line\n" )
        #f.write( "plot '#{data_filename}' ti \"#{oldLabels.pop.to_s} per #{oldLabels.pop.to_s}\" w line, '#{pointsOfInterest_filename}' ti \"Poses from Dance Master Illustrations\" w xerrorbars lt 1 pt 7 ps 2, '#{tp_filename}' ti \"Turning poses\" w points 0 7\n")
      end
    end # of File.open

    File.open( data_filename.to_s, "w" ) do |f|
      data.each_with_index do |d, i|
        if( from.nil? )
          f.write( "#{i.to_s} #{d.to_s}\n" )
        else
          f.write( "#{(i+from).to_s} #{d.to_s}\n" )
        end
      end # of data.each_with_index do |d,i|
    end

    unless( pointsOfInterest.nil? )
      File.open( pointsOfInterest_filename.to_s, "w" ) do |f|
        pointsOfInterest.each_with_index do |dmp, index|
            f.write( "#{dmp.to_s} #{data[dmp-@from].to_s} #{pointsOfInterestRange[index].first.to_s} #{pointsOfInterestRange[index].last.to_s}\n" )
        end # of data.each_with_index do |d,i|
      end
    end

    unless( tp.nil? )
      File.open( tp_filename.to_s, "w" ) do |f|
        tp.each do |point|
            f.write( "#{point.to_s} #{data[point-@from].to_s}\n" )
        end # of data.each_with_index do |d,i|
      end
    end


  end # of def interactive_gnuplot }}}


  # = getTrianglePatch returns a set of values after turning point calculation
  # takes four segments ( a,b,c,d - 2 for each line (a+b) (c+d) ) one segment for
  # @param segment1a Name of segment which together with segment1b builds a 3D line
  # @param segment1b Name of segment which together with segment1a builds a 3D line
  # @param segment2a Name of segment which together with segment2b builds a 3D line
  # @param segment2b Name of segment which together with segment2a builds a 3D line
  # @param center Name of segment which is our coordinate center for measurement and projection (3D->2D)
  # @param from Expects a number indicating to start from which time frame
  # @param to Expects a number indicating to end on which time frame
  # @returns Array, containing the points after the calculation
  def getTrianglePatch segment1 = "pt27", segment2 = "relb", segment3 = "pt26", segment4 = "lelb", center = "pt30", from = @from, to = @to # {{{

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

    ## Easy handling
    #pt30 = @adt.pt30
    #pt27 = @adt.pt27
    #pt9  = @adt.relb
    #pt26 = @adt.pt26
    #pt5  = @adt.lelb

    # FIXME: Substitudte eval through the proper method which exists now in ruby core
    # Easy handling method internal
    center  = eval( "@adt.#{center.to_s}" )
    seg1    = eval( "@adt.#{segment1.to_s}" )
    seg2    = eval( "@adt.#{segment2.to_s}" )
    seg3    = eval( "@adt.#{segment3.to_s}" )
    seg4    = eval( "@adt.#{segment4.to_s}" )

    # Make coords relative to p30 not global -- not normalized
    seg1new           = seg1 - center
    seg2new           = seg2 - center
    seg3new           = seg3 - center
    seg4new           = seg4 - center

    # Get CPA from the two 3D lines
    ptPnew            = distance_of_line_to_line( seg1new, seg2new, seg3new, seg4new )

    # Modify our array if we want only a certain range
    # FIXME: Array.slice only supports start, length not from,to. Reimplement this properly.
    if( from.nil? )
      if( to.nil? )
        # from && to == nil
        # do nothing, we have already all resuts
        #puts "From and To Nil"
        seg1newCoord  = seg1new.getCoordinates!
        seg2newCoord  = seg2new.getCoordinates!
        seg3newCoord  = seg3new.getCoordinates!
        seg4newCoord  = seg4new.getCoordinates!
        ptPnewCoord   = ptPnew.getCoordinates!
      else
        # from == nil ; to != nil
        # we start from 0 upto to
        #puts "From nil to not nil"
        seg1newCoord  = seg1new.getCoordinates![ eval( "0..#{to}" ) ]
        seg2newCoord  = seg2new.getCoordinates![ eval( "0..#{to}" ) ]
        seg3newCoord  = seg3new.getCoordinates![ eval( "0..#{to}" ) ]
        seg4newCoord  = seg4new.getCoordinates![ eval( "0..#{to}" ) ]
        ptPnewCoord   = ptPnew.getCoordinates![ eval( "0..#{to}" ) ]
      end
    else
      if( to.nil? )
        # from != nil ; to == nil
        # e.g. from = 250 
        # totalLength - from = x
        #puts "From not nil to is nil"
        length = seg1new.getCoordinates!.length
        seg1newCoord  = seg1new.getCoordinates![ eval( "#{from}..#{length-from}" ) ]
        seg2newCoord  = seg2new.getCoordinates![ eval( "#{from}..#{length-from}" ) ]
        seg3newCoord  = seg3new.getCoordinates![ eval( "#{from}..#{length-from}" ) ]
        seg4newCoord  = seg4new.getCoordinates![ eval( "#{from}..#{length-from}" ) ]
        ptPnewCoord   = ptPnew.getCoordinates![ eval( "#{from}..#{length-from}" ) ]
      else
        # from && to != nil
        #puts "From (#{from.to_s}) not nil and to (#{to.to_s}) not nil"
        seg1newCoord  = seg1new.getCoordinates![ eval( "#{from}..#{to}" ) ]
        seg2newCoord  = seg2new.getCoordinates![ eval( "#{from}..#{to}" ) ]
        seg3newCoord  = seg3new.getCoordinates![ eval( "#{from}..#{to}" ) ]
        seg4newCoord  = seg4new.getCoordinates![ eval( "#{from}..#{to}" ) ]
        ptPnewCoord   = ptPnew.getCoordinates![ eval( "#{from}..#{to}" ) ]
      end
    end

    # e.g.
    # Point l1_1 :   pt9  (right elbow)
    # Point l1_2 :   pt27 (right wrist)
    # Point l2_1 :   pt5  (left elbow)
    # Point l2_2 :   pt26 (left wrist)
    # Point P    :   Intersection of L1 & L2 (CPA Approach)

    return ptPnewCoord
    exit

    pca = PCA.new

    s1 = pca.reshape_data( ptPnewCoord, true, false )

    arms, eigen_values, eigen_vectors     = pca.do_pca( s1, 0 )
    arms_final                            = pca.clean_data( pca.transform_basis( arms, eigen_values, eigen_vectors ), 3 )
    distances                             = eucledian_distance_window( arms_final, 5 )

    # Plots
    # pca.covariance_matrix_gnuplot( arms, "cov.gp" )
    # pca.eigenvalue_energy_gnuplot( arms, "energy.gp" )
    # interactive_gnuplot_eucledian_distances( pca.normalize( distances ), "%e %e\n", ["Frames", "Normalized Eucledian Distance Window Value (0 <= e <= 1)"], "eucledian_distances_window_plot.gp" )
    pca.interactive_gnuplot( pca.reshape_data( arms_final, false, true ), "%e %e %e\n", %w[PC1 PC2 PC3],  "plot.gp", eigen_values, eigen_vectors )


    return arms_final
    # --- 

#    # OLD deprecated CPA triangle patch method below... --- refactor or delete
#
#    # Area of triangle:   line0( pt5, pt9 )  line1( pt9, pt27 )   line2( pt5, pt26 )
#    arms = pt5.area_of_triangle( pt9, ptP )
#    
#    # Lower body via Tibia
#    # Area of triangle:   line0( pt14, pt20 )   line1( pt20, pt21 )   line2( pt14, pt15  )
#    pt14  = @adt.lkne
#    pt20  = @adt.rkne
#    pt21  = @adt.rank
#    pt15  = @adt.lank
#    ptP  = distance_of_line_to_line( pt20, pt21, pt14, pt15 )
#    legs = pt14.area_of_triangle( pt20, ptP )
#
#    result = []
#    [arms, legs].transpose.each do |array|
#      arm, leg = *array
#      #result << ( arm * leg ) / ( Math.sqrt( (arm*arm) + (leg*leg)) )
#      result << ( arm * leg ) # / ( Math.sqrt( (arm*arm) ))
#    end
#    result
#




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


  # = The function velocity calculates the phyiscal velocity at each point for the data
  # @param data Accepts array of arrays in the shape of [ [x1,y1,z1], [...], ...]
  # @param capturingIntervall Accepts float, representing the capture intervall of the motion capture equipment
  # @returns Array containing corresponding velocity values for the frames n and n+1
  def velocity data, points, capturingIntervall = 0.08333 # {{{
    result        = []

    raise ArgumentError, "Data must be in the shape [ [x1,y1,z1], [...], ...]" if( data.length == 3 )

    all_distances = eucledian_distance_window( data.dup, points ) 


    data.each_index do |i|
      if( i <= (data.length - 2) )
        result[ i ]     = all_distances[ i ].to_f / ( capturingIntervall.to_f * points )
      end
    end

    result
  end # of def velocity data }}}

  # = The function acceleration calculates the phyiscal acceleration at each point for the data
  # @param data Accepts array of arrays in the shape of [ [x1,y1,z1], ...]
  # @param capturingIntervall Accepts float, representing the capture intervall of the motion capture equipment
  # @returns Array containing corresponding acceleration values for the frames n and n+1
  def acceleration data, points, capturingIntervall = 0.08333 # {{{
    
    raise ArgumentError, "Data must be in the shape [ [x1,y1,z1], [...], ...]" if( data.length == 3 )   

    result        = []
    v             = velocity( data, points, capturingIntervall )

    data.each_index do |i|
      if( i <= (data.length - 2) )
        result[ i ]     = v[i] / ( capturingIntervall.to_f * points )
      end
    end

    result
  end # of def acceleration data }}}

  # = The function power calculates the phyiscal power at each point for the data
  # @param data Accepts array of arrays in the shape of [ [x1,y1,z1], [..], ..]
  # @param mass Mass of the components involved (relative to 100% = full body)
  # @param capturingIntervall Accepts float, representing the capture intervall of the motion capture equipment
  # @returns Array containing corresponding power values for the frames n and n+1
  def power data, mass, points, capturingIntervall = 0.08333 # {{{
    result        = []
    raise ArgumentError, "Data must be in the shape [ [x1,y1,z1], [...], ...]" if( data.length == 3 )   

    a             = acceleration( data.dup, points, capturingIntervall )
    v             = velocity( data.dup, points, capturingIntervall )

    data.each_index do |i|
      if( i <= (data.length - 2) )
        result[ i ]     = mass * a[i] * v[i]
      end
    end

    result
  end # of def power data }}}


  # = The function energy calculates the phyiscal energy at each point for the data
  # @param data Accepts array of arrays in the shape of [ [x1,y1,z1], [...], ...]
  # @param capturingIntervall Accepts float, representing the capture intervall of the motion capture equipment
  # @param points Accepts integer of how many points should be included in the calculation (e.g. 20 points), 10 points before and 10 after the current point
  # @returns Array containing corresponding energy values for the frames n and n+1
  def energy data, mass, points # {{{
    raise ArgumentError, "Data must be in the shape [ [x1,y1,z1], [...], ...]" if( data.length == 3 )

    result    = []
    v         = velocity( data, points )

    data.each_index do |i|
      if( i <= (data.length - 2) )
        # Kinetic energy    E_kin = 0.5 * m * v^2
        e_kin = 0.5 * mass * ( v[ i ].to_f ** 2 )
        result[ i ] = e_kin
      end
    end

    result
  end # of def energy data }}}


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
  #   Two points p1 (x,y,z) and p2 (x2,y2,z2) span a line in 3D space.
  #   One plane is eliminated by zero'ing the factor.
  #   The slope form also known as f(x) =>  y = m*x + t  (2D)
  #   m = DeltaY / DeltaX  ; where DeltaY is the Y2 - Y1 ("steigung/increase")
  # @param array1 Set of coordinates Point A
  # @param array2 Set of coordinates Point B
  # @param direction String which is either "xy", "xz", "yz"
  # @returns Array, containing m and t for the slope form equasion
  # @warning FIXME: Z coordinate is only neglegted and this needs to be normally compensated - use PCA/ICA instead.
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


  # = The function get_turning_motions_cpa takes as input arguments the body component in question and returns the
  # result from getTrianglePatch
  # @param component Symbol, describing the name of the components desired. e.g. :forearms, :hands, :upper_arms, :thighs, :shanks, :feet
  # @param from
  # @param to
  # @returns Coordinates of new CPA from the getTrianglePatch method
  def get_turning_motions_cpa components, from = @from, to = @to # {{{

    center            = "pt30"

    # FIXME: This should go into the VPM plugin of MotionX
    valid_components  = {
      :forearms       => [ [ "pt27", "relb" ], [ "pt26", "lelb" ] ],
      :hands          => [ [ "rfin", "pt27" ], [ "lfin", "pt26" ] ],
      :upper_arms     => [ [ "relb", "rsho" ], [ "lelb", "lsho" ] ],
      :thighs         => [ [ "rkne", "pt29" ], [ "lkne", "pt28" ] ],
      :shanks         => [ [ "rank", "rkne" ], [ "lank", "lkne" ] ],
      :feet           => [ [ "rtoe", "rank" ], [ "ltoe", "lank" ] ]
    }

    #if( @adt.methods.include?( "rhee" ) )
    #  back_feet                         = getTrianglePatch( "rhee", "rank", "lhee", "lank", "pt30", @from, @to )
    #  front_feet                        = getTrianglePatch( "rtoe", "rhee", "ltoe", "lhee", "pt30", @from, @to )
   
    raise ArgumentError, "NOT IMPLEMENTED ERRROR"
    # CONTINUE HERE

  end # of def get_cpa }}}

  # = Perform calculations and extract data
  def get_data # {{{
    pca     = PCA.new

    forearms                           = getTrianglePatch( "pt27", "relb", "pt26", "lelb", "pt30", @from, @to )
    #forearms_pca, fp_eval, fp_evec    = pca.do_pca( pca.reshape_data( forearms.dup, true, false ), 0 )
    #forearms_tb                       = pca.transform_basis( forearms_pca, fp_eval, fp_evec )
    #forearms_final                    = pca.clean_data( forearms_tb, 3 )
    #forearms_distances                = eucledian_distance_window( forearms_final, 5 )

    hands                              = getTrianglePatch( "rfin", "pt27", "lfin", "pt26", "pt30", @from, @to )
    #hands_pca, hp_eval, hp_evec       = pca.do_pca( pca.reshape_data( hands, true, false ), 0 )
    #hands_final                       = pca.clean_data( pca.transform_basis( hands_pca, hp_eval, hp_evec ), 3 )
    #hands_distances                   = eucledian_distance_window( hands_final, 5 )

    upper_arms                        = getTrianglePatch( "relb", "rsho", "lelb", "lsho", "pt30", @from, @to )

    # lower body
    thighs                            = getTrianglePatch( "rkne", "pt29", "lkne", "pt28", "pt30", @from, @to )
    shanks                            = getTrianglePatch( "rank", "rkne", "lank", "lkne", "pt30", @from, @to )


    # Total: 100.0
    mass_total_body = {
     #   "head"      => 7.0,
     #   "chest"     => 25.8,
     #   "loins"     => 17.2,
     "upper arm" => 3.6,
     "fore arm"  => 2.2,
     "hand"      => 0.7,
     "thigh"     => 11.4,
     "shank"     => 5.3,
     "foot"      => 1.8
    }

    # Total: 100.0
    mass_upper_body = {
     "upper arm" => 3.6,
     "fore arm"  => 2.2,
     "hand"      => 0.7,
    }

    # Total: 100.0
    mass_lower_body = {
     "thigh"     => 11.4,
     "shank"     => 5.3,
     "foot"      => 1.8
    }




    # Some dance data doesn't have e.g. rhee markers (e.g. jongara)
    if( @adt.methods.include?( "rhee" ) )
      back_feet                         = getTrianglePatch( "rhee", "rank", "lhee", "lank", "pt30", @from, @to )
      front_feet                        = getTrianglePatch( "rtoe", "rhee", "ltoe", "lhee", "pt30", @from, @to )
      #upper                             = [ forearms, hands, upper_arms ]
      #lower                             = [ thighs, shanks, back_feet, front_feet ]
      #components                        = upper + lower
      #mass                              = mass_total_body
      #components                        = lower
      #mass                              = mass_lower_body
      components                        = [ forearms ]
      mass                              = { "xx" => 2.2 }
    else
      front_feet                        = getTrianglePatch( "rtoe", "rank", "ltoe", "lank", "pt30", @from, @to )
      upper                             = [ forearms, hands, upper_arms ]
      lower                             = [ thighs, shanks, front_feet ]
      components                        = upper + lower
      mass                              = mass_total_body
      #components                        = lower
      #mass                              = mass_lower_body
      raise Error, "foo"
      #components = [ shanks ]
      #mass      = { "xx" => 5.3 }
    end

    all   = []
    count = 0
    components.each do |c|
      all   += pca.reshape_data( c, true, false )
      count += 1
    end


    m = 0; mass.each_value { |v| m += v }
    m = m*2 # we have each component e.g. left + right arm etc.

    all_pca, all_eval, all_evec       = pca.do_pca( all, ((count*3)-3) )
    all_final                         = pca.clean_data( pca.transform_basis( all_pca, all_eval, all_evec ), 3 )

    spread                            = 20

    all_distances                     = eucledian_distance_window( pca.reshape_data( all_final.dup, false, true), spread )
    all_energy                        = energy( pca.reshape_data( all_final.dup, false, true ), m, spread )



    #### Messy Mablab interaction
    # Dump to file for matlab
    File.open( "work/data.csv", File::WRONLY|File::TRUNC|File::CREAT, 0667 ) do |f|
      pd = pca.reshape_data( all_final.dup, false, true  )
      pd.each do |x,y,z|
        f.write( "#{x.to_s}, #{y.to_s}, #{z.to_s}\n" )
      end
    end

    puts "Calling MATLAB via chroot"
    `sudo su -c "chroot /export/temp2/MatLAB_7_Linux/matlab /home/mh/ml/bin/matlab_call.sh"`

    # Read file @from matlab processing for frenet frame
    # kappa index is exacly 2 shorter than the others
    kappa = File.open( "work/kappa.csv", "r" ).readlines.collect! { |n| n.to_f }

    v                                 = velocity( pca.reshape_data( all_final.dup, false, true ), 5 )
    a                                 = acceleration( pca.reshape_data( all_final.dup, false, true), 5 )
    p                                 = power( pca.reshape_data( all_final.dup, false, true ), m, 5 )

  
    # Kappa needs to be corrected because @from is not nil and not 0
    #if( @from.to_i > 0 )
    #  old_kappa = kappa.dup
    #  n_kappa = Array.new( @from.to_i + kappa.length.to_i, 0.0 )
    #  kappa.each_with_index do |v, i|
    #    n_kappa[ @from.to_i + i ] = v
    #  end
    #  kappa = n_kappa
    #end

# EXPERIMENTS- can we extract dmps via fft analysis?
# result, no but interestingly the low frequency components are most prevalent

###    # @from is a problem here!!!
###    old_kappa = kappa.dup
###    new_kappa = Array.new( kappa.length - 1, 0.0 )
###    thresh    = 10
###
###    @dance_master_poses.each do |d|
###      (d-thresh).upto(d+thresh) do |i|
###        new_kappa[ i ] = kappa[ i ]
###      end
###    end
###
###    kappa = new_kappa
###
###    # Can we use FFT to find the sinals frequency which interest us?
###    gsl_kappa       = GSL::Vector.alloc( kappa )
###    fft_kappa       = gsl_kappa.fft
###    sampling = 1000
###    y2 = fft_kappa.subvector(1, kappa.length-2).to_complex2
###    mag = y2.abs
###    phase = y2.arg
###    #f = GSL::Vector.linspace(0, sampling/2, mag.size)
###    f = GSL::Vector.linspace(0, sampling/2, mag.size)
###
###    graph(f, mag, "-C -g 3 -x 0 500 -X 'Frequency [Hz]'")
### 
###   # exit
###
###    puts "Proceed?"
###    STDIN.gets
###
###    gsl_kappa       = GSL::Vector.alloc( kappa )
###    rtable          = FFT::Real::Wavetable.alloc( kappa.length )
###    rwork           = FFT::Real::Workspace.alloc( kappa.length )
###
###    fft_kappa       = gsl_kappa.fft
###
###    hctable         = FFT::HalfComplex::Wavetable.alloc( kappa.length )
###
###    for i in 50...(kappa.length) do
###      fft_kappa[i] = 0.0
###    end
###
###    ifft_kappa = ( fft_kappa.ifft ).to_na.to_a


    # http://users.rowan.edu/~polikar/WAVELETS/WTpart1.html

    # OLD METHOD
    # Smoothing poly - use sth between 50 - 100
    coef, err, chisq, status = GSL::MultiFit::polyfit( GSL::Vector.alloc( eval( "0..#{(kappa.length-1).to_s}" )), GSL::Vector.alloc( kappa ), 50)
    kappa_smooth = []
    0.upto( kappa.length - 1 ) { |n| kappa_smooth << coef.eval( n ) }

    # NEW METHOD
    n               = 16
    nc              = 3
    iterations      = ( kappa.length / n ) - 1
    rest            = ( kappa.length % n ) - 1
    kappa_wavelet   = GSL::Vector.alloc( ( ( iterations + 1 ) * n ) )
    cycle           = 0

    0.upto( iterations ) do |i|

      k               = GSL::Vector.alloc( n )
      c               = ( i * n ) - 1
      0.upto( n - 1 ) { |j|  k.set( j, kappa[ c + j ] ) }

      # daubechies | daubechies_centered
      # This is the Daubechies wavelet family of maximum phase with k/2 vanishing moments. The
      # implemented wavelets are k=4, 6, ..., 20, with k even.
      #
      # haar | haar_centered
      # This is the Haar wavelet. The only valid choice of k for the Haar wavelet is k=2. 
      #
      # bspline | bspline_centered
      # This is the biorthogonal B-spline wavelet family of order (i,j). The implemented values
      # of k = 100*i + j are 103, 105, 202, 204, 206, 208, 301, 303, 305 307, 309. 
      #
      # The centered forms of the wavelets align the coefficients of the various sub-bands on
      # edges. Thus the resulting visualization of the coefficients of the wavelet transform in
      # the phase plane is easier to understand. 
      wavelet         = GSL::Wavelet.alloc( "haar", 2 ) 
      work            = GSL::Wavelet::Workspace.alloc( n )
      data2           = wavelet.transform( k, GSL::Wavelet::FORWARD, work)
      perm            = data2.abs.sort_index


      cnt = 0
      while( cnt + nc ) < n
        data2[ perm[ cnt ] ] = 0.0
        cnt += 1
      end

      intermediate    = ( GSL::Wavelet.transform_inverse( wavelet, data2 ) ).to_a
      cycle          += 1

      0.upto( n - 1 ) { |j| kappa_wavelet.set( ( c + j ), intermediate[ j ] ) }
      #0.upto( n - 1 ) { |j| kappa_wavelet.set( ( c + j ), data2[ j ] ) }
    end
    kappa_wavelet     = kappa_wavelet.to_a

    # Smoothing poly - use sth between 50 - 100
    coef, err, chisq, status = GSL::MultiFit::polyfit( GSL::Vector.alloc( eval( "0..#{(kappa_wavelet.length-1).to_s}" )), GSL::Vector.alloc( kappa_wavelet ), 50)
    wavelet_kappa_smooth = []
    0.upto( kappa_wavelet.length - 1 ) { |n| wavelet_kappa_smooth << coef.eval( n ) }


    # kappa_smooth_dx = []
    # 0.upto( kappa.length - 1 ) { |x| result, abserror = GSL::Deriv.central( GSL::Function.alloc { |x| coef.eval(x) }, x, 1e-8) ; kappa_smooth_dx[x] = result }
    # p kappa_smooth_dx
    # interactive_gnuplot_eucledian_distances( kappa_smooth_dx, "%e %e\n", ["Frames", "Kappa Smooth dx/dy Value"], "Kappa Smooth dx/dy Value Graph", "dx_frenet_frame_kappa_plot.gp", "dx_frenet_frame_kappa_plot.gpdata" )a

    e                                 = []
    all_energy.each_index do |i|
      next if( kappa[i].nil? )
      #e[i] = kappa[i] * 1/all_distances[i] * 1/all_energy[i] * 1/v[i] * 1/a[i] * 1/p[i]
      #e[i] = kappa_smooth[i] * 1/all_energy[i] * 1/all_distances[i]
      ####e[i] = kappa_smooth[i] + 1/all_energy[i] + 1/all_distances[i]
      
      next if( kappa_wavelet[i].nil? )
      #e[i] = kappa_smooth[i] + 1/all_energy[i] + 1/all_distances[i]
      #e[i] = kappa_wavelet[i] + 1/all_energy[i] + 1/all_distances[i]
      e[i] = kappa_wavelet[i] - all_energy[i] - all_distances[i]
    end

    # Very simple way to determine the turning points without the derivative
    tp_frames = []
    0.upto( kappa.length - 1 ) do |n|
      begin
        previouss = e[ n-2 ]
        previous  = e[ n-1 ]
        current   = e[ n   ]
        nexts     = e[ n+1 ]
        nextss    = e[ n+2 ]

        next if previouss.nil?
        next if previous.nil?
        next if nexts.nil?
        next if nextss.nil?

        tp_frames << n if( previous < current and previouss < current and current > nexts and current > nextss )
      end
    end


    turning_poses       = tp_frames.collect { |n| n+@from.to_i }
    turning_poses.shift     # ignore the very first point

    puts "DMPs are: #{@dance_master_poses.join(", ")}"
    puts "Turningposes are: #{turning_poses.join(", ")}"

    #### Messy Mablab interaction end

    #pca.covariance_matrix_gnuplot( all, "cov.gp" )
    #pca.eigenvalue_energy_gnuplot( all, "energy.gp" )

    dis   = all_distances
    plot  = all_final

    #kappa = old_kappa

    interactive_gnuplot_eucledian_distances( wavelet_kappa_smooth, "%e %e\n", ["Frames", "Wavelet Smoothed Kappa, then poly fitted Value (0 <= e <= 1)"], "Wavelet Smoothed Kappa then poly fitted Value Graph", "poly_wavelet_smoothed_frenet_frame_kappa_plot.gp", "poly_wavelet_smoothed_frenet_frame_kappa_plot.gpdata", @from, @dance_master_poses, @dance_master_poses_range, "poly_wavelet_dmps_smoothed_frenet_frame.gpdata", turning_poses, "poly_wavelet_tp_smoothed_frenet_frame.gpdata" ) 
    interactive_gnuplot_eucledian_distances( kappa_wavelet, "%e %e\n", ["Frames", "Normalized and Wavelet Smoothed Kappa Value (0 <= e <= 1)"], "Normalized and Wavelet Smoothed Kappa Value Graph", "wavelet_smoothed_frenet_frame_kappa_plot.gp", "wavelet_smoothed_frenet_frame_kappa_plot.gpdata", @from, @dance_master_poses, @dance_master_poses_range, "wavelet_dmps_smoothed_frenet_frame.gpdata", turning_poses, "wavelet_tp_smoothed_frenet_frame.gpdata" ) 
    interactive_gnuplot_eucledian_distances( pca.normalize( kappa ), "%e %e\n", ["Frames", "Normalized Kappa Value (0 <= e <= 1)"], "Normalized Kappa Value Graph", "frenet_frame_kappa_plot.gp", "frenet_frame_kappa_plot.gpdata", @from, @dance_master_poses, @dance_master_poses_range, "dmps_frenet_frame.gpdata", turning_poses, "tp_frenet_frame.gpdata" )
    interactive_gnuplot_eucledian_distances( pca.normalize( kappa_smooth ), "%e %e\n", ["Frames", "Normalized Smoothed Kappa Value (0 <= e <= 1)"], "Normalized Smoothed Kappa Value Graph", "smoothed_frenet_frame_kappa_plot.gp", "smoothed_frenet_frame_kappa_plot.gpdata", @from, @dance_master_poses, @dance_master_poses_range, "dmps_smoothed_frenet_frame.gpdata", turning_poses, "tp_smoothed_frenet_frame.gpdata" ) 
    
    #interactive_gnuplot_eucledian_distances( pca.normalize( p ), "%e %e\n", ["Frames", "Normalized Power Value (0 <= e <= 1)"], "Normalized Power Value Graph", "power_plot.gp", "power_plot.gpdata" )
    #interactive_gnuplot_eucledian_distances( pca.normalize( v ), "%e %e\n", ["Frames", "Normalized Velocity Value (0 <= e <= 1)"], "Normalized Velocity Value Graph", "velocity_plot.gp", "velocity_plot.gpdata" )
    #interactive_gnuplot_eucledian_distances( pca.normalize( a ), "%e %e\n", ["Frames", "Normalized Acceleration Value (0 <= e <= 1)"], "Normalized Acceleration Value Graph", "acceleration_plot.gp", "acceleration_plot.gpdata" )
    
    interactive_gnuplot_eucledian_distances( pca.normalize( dis ), "%e %e\n", ["Frames", "Normalized Eucledian Distance Window Value (0 <= e <= 1)"], "Normalized Eucledian Distance Window Graph (Speed)", "eucledian_distances_window_plot.gp", "eucledian_distances_window_plot.gpdata", @from, @dance_master_poses, @dance_master_poses_range, "dmps_eucleadian_distance.gpdata", turning_poses, "tp_eucleadian_distance.gpdata" )
    interactive_gnuplot_eucledian_distances( pca.normalize( all_energy ), "%e %e\n", ["Frames", "Normalized Kinetic Energy v (0 <= e <= 1)"], "Normalized Kinetic Energy Graph", "ekin.gp", "ekin.gpdata", @from, @dance_master_poses, @dance_master_poses_range, "dmps_ekin.gpdata", turning_poses, "tp_ekin.gpdata" )
    interactive_gnuplot_eucledian_distances( pca.normalize( e ), "%e %e\n", ["Frames", "Normalized Weight (0 <= e <= 1)"], "Normalized Weight Graph", "weight.gp", "weight.gpdata", @from, @dance_master_poses, @dance_master_poses_range, "dmps_weight.gpdata", turning_poses, "tp_weight.gpdata" )
    #pca.interactive_gnuplot( pca.reshape_data( plot, false, true ), "%e %e %e\n", %w[PC1 PC2 PC3],  "plot.gp", all_eval, all_evec )

    #pca.interactive_gnuplot( forearms, "%e %e %e\n", %w[X Y Z],  "forearms_plot.gp" )

  end # of getData }}}


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


  # = Reads a yaml config describing the motion file
  def read_motion_config filename # {{{
    File.open( filename, "r" ) { |file| YAML.load( file ) }                 # return proc which is in this case a hash
  end # }}}

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


# = Direct invocation, for manual testing beside rspec
if __FILE__ == $0 # {{{

  file    = ARGV.first
  bc      = BodyComponents.new( file )
  bc.get_data

end # }}}


# vim=ts:2
