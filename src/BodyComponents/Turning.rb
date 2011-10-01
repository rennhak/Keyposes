#!/usr/bin/ruby
#

###
#
# File: Turning.rb
#
######


###
#
# (c) 2009-2011, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       Turning.rb
# @author     Bjoern Rennhak
#
#######




# Standard includes
require 'rubygems'
require 'narray'
require 'gsl'

# Local includes
require_relative 'Logger.rb'
require_relative 'PCA.rb'

require_relative 'Mathematics.rb'
require_relative 'Physics.rb'

# Change Namespace
include GSL


# The class Turning is the idea and implementation of the Turning Motions and Turning Poses method published in e.g. IROS2010, Rennhak et al.
class Turning # {{{

  def initialize options, adt, dance_master_poses, dance_master_poses_range, from, to # {{{
    @adt                          = adt
    @options                      = options
    @dance_master_poses           = dance_master_poses
    @dance_master_poses_range     = dance_master_poses_range
    @from, @to                    = from, to
    
    # Dirty class variable change this
    @components                   = nil

    @log                          = Logger.new( @options )
    @plot                         = Plotter.new( @from, @to )

    @mathematics                  = Mathematics.new
    @physics                      = Physics.new
    @filter                       = Filter.new( @options, @from, @to )
  end # of def initialize }}}


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

    pca.interactive_gnuplot( pca.reshape_data( arm1_final, false, true ), "%e %e %e\n", %w[PC1 PC2 PC3],  "graphs/plot.gp", eigen_values1, eigen_vectors2 )

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


  # = get_segments_cpa returns a set of values after Closest Point of Approach calculation
  # takes four segments ( a,b,c,d - 2 for each line (a+b) (c+d) ) one segment for center
  # @param segments Array in the form of [ [segment1, segment2], [segment3, segment4] ] where seg1 & seg2 form a 3D line and 3,4 respectively
  # @param center Name of segment which is our coordinate center for measurement
  # @param from Expects a number indicating to start from which time frame
  # @param to Expects a number indicating to end on which time frame
  # @returns Array, containing the points after the calculation
  # def get_segments_cpa segment1 = "pt27", segment2 = "relb", segment3 = "pt26", segment4 = "lelb", center = "pt30", from = @from, to = @to # {{{
  def get_segments_cpa segments, center = "pt30", from = @from, to = @to # {{{

    #####
    # Reference case
    # e.g. S. Kudoh Thesis, Page 109
    ###########

    @log.message :info, "Performing get_segements_cpa on #{segments.join( ", " )}"

    segment1, segment2 = segments.shift
    segment3, segment4 = segments.shift




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
    ptPnew            = @mathematics.distance_of_line_to_line( seg1new, seg2new, seg3new, seg4new )

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
    pca.interactive_gnuplot( pca.reshape_data( arms_final, false, true ), "%e %e %e\n", %w[PC1 PC2 PC3],  "graphs/plot.gp", eigen_values, eigen_vectors )


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

  end # end of get_segments_cpa }}}


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


  # = The function get_components_cpa takes as input arguments the body component in question and returns the result from get_segments_cpa
  # @param components_keyword Symbol, describing the name of the components desired. e.g. :forearms, :hands, :upper_arms, :thighs, :shanks, :feet
  #                           These symbols can be found in the MotionX package src/plugins/vpm/src/Body.rb
  # @param from Integer, representing the start of the desired frames
  # @param to Integer, representing the end of the desired frames
  # @returns Coordinates of new CPA from the get_segment_cpa method
  def get_components_cpa components_keyword, model = nil, from = @from, to = @to # {{{

    raise ArgumentError, "Model cannot be nil" if( model.nil? )
    raise ArgumentError, "The component keyword symbol you supplied (,,#{components_keyword.to_s}'') doesn't exist in group [ #{@adt.body.group.keys.join( ", ")} ]" unless( @adt.body.group.keys.include?( components_keyword ) ) 

    @log.message :info, "Calculating CPA of #{components_keyword.to_s}"

    center            = @adt.body.center


    # FIXME Why is this necessary?
    # components        = eval( "@adt.body.group_#{model.to_s}_model[ components_keyword ]" )
    components = (  eval( "@adt.body.group_#{model.to_s}_model_left[ components_keyword ]" ) ).concat(  eval( "@adt.body.group_#{model.to_s}_model_right[ components_keyword ]" ) )
    p components
    @components = components.dup
    result            = get_segments_cpa( components.dup, center, from, to )
  end # of def get_components_cpa }}}


  # = Perform calculations and extract data
  def get_data # {{{
    pca     = PCA.new

    @log.message :info, "CPA Extraction of all body components"

    body_components         = @options.body_parts
    model                   = @options.model.to_i
    side                    = @options.side         # which side do we process?

    raise ArgumentError, "Model needs to be either 1, 4, 8 or 12" unless( [1,4,8,12].include?( model ) )

    components            = []    # here we store our data refs in one place
    tmp_components        = []

    # Get all individual components
    case model
      when 1 then
        @log.message :warning, "We will used a fixed components set, if you defined specific components over the CLI they are ignored with the 1 Model."
        @log.message :success, "Using the following body components: #{body_components.join( ", " ).to_s}"
        raise NotImplementedError, "This is not yet implemented"
      when 4 then
        @log.message :warning, "We will used a fixed components set. So only parts that can be allowed are upper_arms, thighs all others will be automatically removed" 
        body_components.delete_if { |c| %w[hands feet fore_arms shanks].include?( c.to_s ) } # Remove hands and feet from list if exist
        @log.message :success, "Using the following body components: #{body_components.join( ", " ).to_s}"

        case @options.side
          when "both"
            body_components.each { |c| tmp_components << @adt.body.group_4_model[ c.to_sym ] } 
          when "left"
            body_components.each { |c| tmp_components << @adt.body.group_4_model_left[ c.to_sym ] } 
          when "right"
            body_components.each { |c| tmp_components << @adt.body.group_4_model_right[ c.to_sym ] } 
          else
            raise ArgumentError, "Something is seriously wrong with the @option.side value (#{@option.side.to_s}) it can only be of (left, right, both)"
        end # of case @option.side

      when 8 then
        @log.message :warning, "We will used a fixed components set. So only parts that can be allowed are upper_arms, lower_arms, thighs, shanks all others will be automatically removed."
        body_components.delete_if { |c| %w[hands feet].include?( c.to_s ) } # Remove hands and feet from list if exist
        @log.message :success, "Using the following body components: #{body_components.join( ", " ).to_s}"

        case @options.side
          when "both"
            body_components.each { |c| tmp_components << @adt.body.group_8_model[ c.to_sym ] } 
          when "left"
            body_components.each { |c| tmp_components << @adt.body.group_8_model_left[ c.to_sym ] } 
          when "right"
            body_components.each { |c| tmp_components << @adt.body.group_8_model_right[ c.to_sym ] } 
          else
            raise ArgumentError, "Something is seriously wrong with the @option.side value (#{@option.side.to_s}) it can only be of (left, right, both)"
        end # of case @option.side

      when 12 then
        @log.message :success, "Using the following body components: #{body_components.join( ", " ).to_s}"
        
        case @options.side
          when "both"
            body_components.each { |c| tmp_components << @adt.body.group_12_model[ c.to_sym ] } 
            # body_components.each { |c| tmp_components << @adt.body.group_12_model_left[ c.to_sym ] } 
            # body_components.each { |c| tmp_components << @adt.body.group_12_model_right[ c.to_sym ] } 
          when "left"
            body_components.each { |c| tmp_components << @adt.body.group_12_model_left[ c.to_sym ] } 
          when "right"
            body_components.each { |c| tmp_components << @adt.body.group_12_model_right[ c.to_sym ] } 
          else
            raise ArgumentError, "Something is seriously wrong with the @option.side value (#{@option.side.to_s}) it can only be of (left, right, both)"
        end # of case @option.side

      else
        raise ArgumentError, "Model can only be 1, 4, 8 or 12 not anything else." unless( [1, 4, 8, 12].include?( model.to_i ) )
    end


    if( @options.side == "left" or @options.side == "right" )
      raise ArgumentError, "In order to make proper use of left/right side components you need to use it with the -r switch !" unless( @options.use_raw_data )
    end

    unless( @options.use_raw_data )
      @log.message :success, "Using CPA technique before doing PCA to unify symetrical components"
      # Push data into storage for PCA
      body_components.each do |c|
        # Apply CPA-PCA for all components
        eval( "@#{c} = get_components_cpa( :#{c}, #{model} )" )
        components << instance_variable_get( "@#{c}" )
      end # of components.each
    else
      @log.message :success, "Using RAW data for PCA matrix"

      # Push raw data into storage for PCA
      tmp_components.flatten.uniq.each do |c|
        @log.message :info, "Transferring #{c.to_s} from absolute to local coordinate system"
        component = eval("@adt.#{c.to_s}")
        center    = eval("@adt.pt30")

        local     = component - center
        components << local.getCoordinates!
      end
    end

    mass = body_components.inject( 0 ) { |result, element| result + @adt.body.get_mass( element ) }

    all   = []
    count = 0
    components.each do |c|
      all   += pca.reshape_data( c, true, false )
      count += 1
    end

    @log.message :info, "Performing PCA reduction on all body components CPA"

    all_pca, all_eval, all_evec       = pca.do_pca( all, ((count*3)-3) )
    all_final                         = pca.clean_data( pca.transform_basis( all_pca, all_eval, all_evec ), 3 )

    spread                            = 20

    all_distances                     = @mathematics.eucledian_distance_window( pca.reshape_data( all_final.dup, false, true), spread )
    all_energy                        = @physics.energy( pca.reshape_data( all_final.dup, false, true ), mass, spread )

    # Calculate the distance of tdata point to local coordinate center
    tdata_distance                    = []

    center                            = ( eval("@adt.pt30") ).getCoordinates!

    ( pca.reshape_data( all_final.dup, false, true  ) ).each_with_index do |array, index|
      # eucledian distance between t-data point and coord center (float)
      tdata_distance << @mathematics.eucledian_distance( array, center[ index ] )
    end # of ( pca.reshape_data( all_final.dup,...)

    # Warning: This works only for one component per CLI
    #
    # Calculate the area of tdata patch
    center                                    = eval( "@adt.pt30" )
    tpoint                                    = @adt.getNewSegment!( "tpoint", "T-Data Point of interected component" )
    tpoint.xtran, tpoint.ytran, tpoint.ztran  = *( all_final.dup )
    
    raise ArgumentError, "Body Components may only be 1 for T-Data area calculation" unless( body_components.length == 1 )
 
    # get_components_cpa always gives us left then right
    left, right   = *@components
    left_sym      = left.last
    right_sym     = right.last

    left          = eval( "@adt.#{left_sym.to_s}" )
    right         = eval( "@adt.#{right_sym.to_s}" )
    
    tdata_area    = tpoint.area_of_triangle( left, right )

    #### Messy Mablab interaction
    # Dump to file for matlab
    File.open( "work/data.csv", File::WRONLY|File::TRUNC|File::CREAT, 0667 ) do |f|
      pd = pca.reshape_data( all_final.dup, false, true  )

      pd.each do |x,y,z|
        f.write( "#{x.to_s}, #{y.to_s}, #{z.to_s}\n" )
      end
    end

    @log.message :info, "Calling MATLAB for some specialized processing"
    `sudo su -c "chroot /export/temp/MatLAB_7_Linux/matlab /home/mh/ml/bin/matlab_call.sh"`

    # Read file @from matlab processing for frenet frame
    # kappa index is exacly 2 shorter than the others
    kappa = File.open( "work/kappa.csv", "r" ).readlines.collect! { |n| n.to_f }

    unless( @options.boxcar_filter.nil? )
      @log.message :info, "Applying FIR Boxcar filter of order #{@options.boxcar_filter.to_s} to Curvature"
      boxcar_kappa = @filter.box_car_filter( kappa.zip(kappa), @options.boxcar_filter.to_i )
      kappa = boxcar_kappa.collect { |a,b| b }
    end

    @log.message :info, "Performing additional calculations (E_k, etc.)" 

    v                                 = @physics.velocity( pca.reshape_data( all_final.dup, false, true ), 5 )
    a                                 = @physics.acceleration( pca.reshape_data( all_final.dup, false, true), 5 )
    p                                 = @physics.power( pca.reshape_data( all_final.dup, false, true ), mass, 5 )


    h = 10 ** (-1)
    e_prime       = @mathematics.derivative( all_energy, h )  # slope of the function
    e_prime_prime = @mathematics.derivative( e_prime, h )     # rate of change (or slope of the slope)

    v_prime       = @mathematics.derivative( v, h )           # slope of the function
    v_prime_prime = @mathematics.derivative( v_prime, h )     # rate of change (or slope of the slope)


    # Determine local max & min
    kappa_sign_graph        = []                              # local max or min

    kappa_slope             = @mathematics.derivative( kappa, h )       # slope of the function
    kappa_rate_of_change    = @mathematics.derivative( kappa_slope, h ) # rate of change (slope of the slope)

    kappa_slope.each_with_index do |k, i|
      next if( kappa_slope.length <= i+1 )  # abort if we reached the end

      if( k > 0 )
        if( kappa_slope[ i+1 ] < 0 )
          # we have an local maximum
          kappa_sign_graph[ i ] = "maximum"
        end
      end
    end # of kappa_slope.each_with_index


    f = File.open( "graphs/slope.gpdata", "w" )
    kappa_sign_graph.each_with_index { |k,i| f.write("#{i.to_s} #{kappa[i].to_s}\n")  }
    f.close

    kappa_candidates        = []
    energy_candidates       = []
    velocity_candidates     = []

   v_prime_frames = []
   0.upto( e_prime.length - 1 ) { |i| v_prime_frames << i }

   #GSL::graph( [ GSL::Vector.alloc( v_prime_frames ), GSL::Vector.alloc( kappa ) ]  ) #, "-T png -C -X 'X-Values' -Y 'Y-Values' -L 'Data' -S 1 -m 0 --page-size a4 > #{filename.to_s}")

   # GSL::graph( [ GSL::Vector.alloc( v_prime_frames ), GSL::Vector.alloc( kappa_slope ) ]  ) #, "-T png -C -X 'X-Values' -Y 'Y-Values' -L 'Data' -S 1 -m 0 --page-size a4 > #{filename.to_s}")

    v_prime_prime_frames = []
    0.upto( v_prime_prime.length - 1 ) { |i| v_prime_prime_frames << i }
    # GSL::graph( [ GSL::Vector.alloc( v_prime_prime_frames ), GSL::Vector.alloc( v_prime_prime ) ]  ) #, "-T png -C -X 'X-Values' -Y 'Y-Values' -L 'Data' -S 1 -m 0 --page-size a4 > #{filename.to_s}")


    # puts "Candidates after energy check"

    e_res = ( (v_prime_frames.zip( e_prime ) ).zip( e_prime_prime ) ).collect { |a| a.flatten }
    e_res.each do |frame, v1, v2|
      v1_prev = e_res[ frame - 1 ][1]

      if( ( v1_prev <= 0 and v1 >= 0 ) and ( v2 >= 0 )  )
        energy_candidates << frame - 2
        energy_candidates << frame - 1
        energy_candidates << frame
        energy_candidates << frame + 1
        energy_candidates << frame + 2
        # puts "Frame: #{frame.to_s}    v_i #{v1.to_s}      v_ii #{v2.to_s}"
      end
    end

    energy_candidates.uniq!

    #puts ""
    #puts "Candidates after velocity check"
    #puts ""

    v_res = ( (v_prime_frames.zip( v_prime ) ).zip( v_prime_prime ) ).collect { |a| a.flatten }
    v_res.each do |frame, v1, v2|
      v1_prev = v_res[ frame - 1][1]

      if( ( v1_prev <= 0 and v1 >= 0 ) and ( v2 >= 0 ) )

        velocity_candidates << frame - 2
        velocity_candidates << frame - 1
        velocity_candidates << frame
        velocity_candidates << frame + 1
        velocity_candidates << frame + 2
        # puts "Frame: #{frame.to_s}    v_i #{v1.to_s}      v_ii #{v2.to_s}" # if( new_candidates.include?(frame) ) #  and velocity_candidates.include?(frame) ) # and ( v2 >= 0 )  )
      end
    end

    velocity_candidates.uniq!

    result = []
    0.upto( all_energy.length - 1 ).each do |frame|
      sum = ""
      
      sum += "ccccc"  if( kappa_candidates.include?(frame) )
      sum += "eeeee" if( energy_candidates.include?(frame) )
      sum += "vvvvv" if( velocity_candidates.include?(frame) )

      result << sum
    end

    normed_energy = pca.normalize( all_energy.dup )
    normed_velocity = pca.normalize( v.dup )

    interesting = []

    result.each_with_index do |r, i|

      next if( kappa[i].nil? or normed_energy[i].nil? or normed_velocity[i].nil? )

      interesting[i] = [ i, 0 ]

      tmp = normed_energy[i] * normed_velocity[i] 
      if( (r.length > 5) and (tmp <= 0.05) )
        # print "#{i.to_s}      |  #{(tmp).to_s}   | " + r +"\n" 

        strength = kappa[i] + (1 - normed_energy[i]) + (1 - normed_velocity[i] ) 
        #strength += 1 if( tmp <= 0.01 )
        #strength += 1 if( tmp <= 0.005 )

        # strength += 1 kappa[i] 

        interesting[i] = [ i, r.length * strength ]
      end
    end

 
    #GSL::graph( [ GSL::Vector.alloc( interesting ), GSL::Vector.alloc( interesting_values ) ]  ) #, "-T png -C -X 'X-Values' -Y 'Y-Values' -L 'Data' -S 1 -m 0 --page-size a4 > #{filename.to_s}")

    e_show = (v_prime_frames.zip(  e_prime.dup         ) ) 
    ee_show = (v_prime_frames.zip( e_prime_prime.dup   ) )
    v_show = (v_prime_frames.zip(  v_prime.dup         ) )
    vv_show = (v_prime_frames.zip( v_prime_prime.dup   ) )

    # @plot.easy_gnuplot( interesting, "%e %e\n", ["Frames", "Dance Master Pose"], "Dance Master Pose extraction Graph", "new_weight_plot.gp", "new_weight_plot.gpdata", @from, @dance_master_poses, @dance_master_poses_range, "new_weight_dmp.gpdata" ) 

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

    @log.message :info, "Performing polynomial fitting of data"
    # OLD METHOD
    # Smoothing poly - use sth between 50 - 100
    # coef, err, chisq, status = GSL::MultiFit::polyfit( GSL::Vector.alloc( eval( "0..#{(kappa.length-1).to_s}" )), GSL::Vector.alloc( kappa ), 100)
    # kappa_smooth = []
    # 0.upto( kappa.length - 1 ) { |n| kappa_smooth << coef.eval( n ) }

#    # NEW METHOD
#    n               = 16
#    nc              = 3
#    iterations      = ( kappa.length / n ) - 1
#    rest            = ( kappa.length % n ) - 1
#    kappa_wavelet   = GSL::Vector.alloc( ( ( iterations + 1 ) * n ) )
#    cycle           = 0
#
#    0.upto( iterations ) do |i|
#
#      k               = GSL::Vector.alloc( n )
#      c               = ( i * n ) - 1
#      0.upto( n - 1 ) { |j|  k.set( j, kappa[ c + j ] ) }
#
#      # daubechies | daubechies_centered
#      # This is the Daubechies wavelet family of maximum phase with k/2 vanishing moments. The
#      # implemented wavelets are k=4, 6, ..., 20, with k even.
#      #
#      # haar | haar_centered
#      # This is the Haar wavelet. The only valid choice of k for the Haar wavelet is k=2. 
#      #
#      # bspline | bspline_centered
#      # This is the biorthogonal B-spline wavelet family of order (i,j). The implemented values
#      # of k = 100*i + j are 103, 105, 202, 204, 206, 208, 301, 303, 305 307, 309. 
#      #
#      # The centered forms of the wavelets align the coefficients of the various sub-bands on
#      # edges. Thus the resulting visualization of the coefficients of the wavelet transform in
#      # the phase plane is easier to understand. 
#      wavelet         = GSL::Wavelet.alloc( "haar", 2 ) 
#      work            = GSL::Wavelet::Workspace.alloc( n )
#      data2           = wavelet.transform( k, GSL::Wavelet::FORWARD, work)
#      perm            = data2.abs.sort_index
#
#
#      cnt = 0
#      while( cnt + nc ) < n
#        data2[ perm[ cnt ] ] = 0.0
#        cnt += 1
#      end
#
#      intermediate    = ( GSL::Wavelet.transform_inverse( wavelet, data2 ) ).to_a
#      cycle          += 1
#
#      0.upto( n - 1 ) { |j| kappa_wavelet.set( ( c + j ), intermediate[ j ] ) }
#      #0.upto( n - 1 ) { |j| kappa_wavelet.set( ( c + j ), data2[ j ] ) }
#    end
#    #kappa_wavelet     = kappa_wavelet.to_a

    # Smoothing poly - use sth between 50 - 100
    #coef, err, chisq, status = GSL::MultiFit::polyfit( GSL::Vector.alloc( eval( "0..#{(kappa_wavelet.length-1).to_s}" )), GSL::Vector.alloc( kappa_wavelet ), 50)
    #wavelet_kappa_smooth = []
    #0.upto( kappa_wavelet.length - 1 ) { |n| wavelet_kappa_smooth << coef.eval( n ) }


    # kappa_smooth_dx = []
    # 0.upto( kappa.length - 1 ) { |x| result, abserror = GSL::Deriv.central( GSL::Function.alloc { |x| coef.eval(x) }, x, 1e-8) ; kappa_smooth_dx[x] = result }
    # p kappa_smooth_dx
    # interactive_gnuplot_eucledian_distances( kappa_smooth_dx, "%e %e\n", ["Frames", "Kappa Smooth dx/dy Value"], "Kappa Smooth dx/dy Value Graph", "dx_frenet_frame_kappa_plot.gp", "dx_frenet_frame_kappa_plot.gpdata" )a

    e                                 = []
    kappa_normalized                  = pca.normalize( kappa ) 
    all_energy.each_index do |i|
      next if( kappa[i].nil? )
      #e[i] = kappa[i] * 1/all_distances[i] * 1/all_energy[i] * 1/v[i] * 1/a[i] * 1/p[i]
      #e[i] = kappa_smooth[i] * 1/all_energy[i] * 1/all_distances[i]
      #e[i] = kappa[i] + 1/all_energy[i] + 1/all_distances[i]


      # kappa indicator
      # kappa[i] = ( kappa_normalized[i] >= 0.02 ) ? ( 1 ) : ( 0 )
      # keyposes
  
      # keyposes
      # e[i] = kappa[i] * ( 1/all_energy[i] ) * ( 1/v[i] )

      # turningposes
      # e[i] = kappa[i] * ( all_energy[i] ) * ( v[i] )
      e[i] = ( all_energy[i] ) * ( v[i] )

      # current
      # e[i] = kappa_smooth[i] + ( all_energy[i] + all_distances[i] )
      
      # new idea - ng
      # kappa & max velocit
      #e[i] = kappa[i] * 20*all_distances[i] * 20*all_energy[i]

      #next if( kappa_wavelet[i].nil? )
      #e[i] = kappa_smooth[i] + 1/all_energy[i] + 1/all_distances[i]
      #e[i] = kappa_wavelet[i] + 1/all_energy[i] + 1/all_distances[i]
      ####e[i] = kappa_wavelet[i] - all_energy[i] - all_distances[i]
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

    @log.message :info, "DMPs are: #{@dance_master_poses.join(", ")}"
    @log.message :info, "Turningposes are: #{turning_poses.join(", ")}"

    #### Messy Mablab interaction end

    #pca.covariance_matrix_gnuplot( all, "cov.gp" )
    #pca.eigenvalue_energy_gnuplot( all, "energy.gp" )

    dis   = all_distances
    plot  = all_final

    #kappa = old_kappa

    @log.message :info, "Preparing data and plot files for gnuplot"
    
    #@plot.interactive_gnuplot_eucledian_distances( wavelet_kappa_smooth, "%e %e\n", ["Frames", "Wavelet Smoothed Curvature, then poly fitted Value (0 <= e <= 1)"], "Wavelet Smoothed Curvature then poly fitted Value Graph", "poly_wavelet_smoothed_frenet_frame_kappa_plot.gp", "poly_wavelet_smoothed_frenet_frame_kappa_plot.gpdata", @from, @dance_master_poses, @dance_master_poses_range, "poly_wavelet_dmps_smoothed_frenet_frame.gpdata", turning_poses, "poly_wavelet_tp_smoothed_frenet_frame.gpdata" ) 
    #@plot.interactive_gnuplot_eucledian_distances( kappa_wavelet, "%e %e\n", ["Frames", "Normalized and Wavelet Smoothed Curvature Value (0 <= e <= 1)"], "Normalized and Wavelet Smoothed Curvature Value Graph", "wavelet_smoothed_frenet_frame_kappa_plot.gp", "wavelet_smoothed_frenet_frame_kappa_plot.gpdata", @from, @dance_master_poses, @dance_master_poses_range, "wavelet_dmps_smoothed_frenet_frame.gpdata", turning_poses, "wavelet_tp_smoothed_frenet_frame.gpdata" ) 
    @plot.interactive_gnuplot_eucledian_distances( pca.normalize( kappa ), "%e %e\n", ["Frames", "Normalized Curvature"], "", "graphs/frenet_frame_kappa_plot.gp", "graphs/frenet_frame_kappa_plot.gpdata", @from, @dance_master_poses, @dance_master_poses_range, "graphs/dmps_frenet_frame.gpdata", turning_poses, "graphs/tp_frenet_frame.gpdata" )
    @plot.interactive_gnuplot_eucledian_distances( pca.normalize( tdata_distance ), "%e %e\n", ["Frames", "Normalized T-Data Point distance"], "", "graphs/tdata_point_distance_to_coord_center_plot.gp", "graphs/tdata_point_distance_to_coord_center.gpdata", @from, @dance_master_poses, @dance_master_poses_range, "graphs/dmp_tdata_point_distance_to_coord_center.gpdata", turning_poses, "graphs/tp_tdata_point_distance.gpdata" )
    @plot.interactive_gnuplot_eucledian_distances( pca.normalize( tdata_area ), "%e %e\n", ["Frames", "Normalized T-Data Area"], "", "graphs/tdata_area_plot.gp", "graphs/tdata_area.gpdata", @from, @dance_master_poses, @dance_master_poses_range, "graphs/dmp_tdata_area.gpdata", turning_poses, "graphs/tp_tdata_area.gpdata" )
    # @plot.interactive_gnuplot_eucledian_distances( pca.normalize( kappa_smooth ), "%e %e\n", ["Frames", "Normalized Smoothed Curvature"], "", "smoothed_frenet_frame_kappa_plot.gp", "smoothed_frenet_frame_kappa_plot.gpdata", @from, @dance_master_poses, @dance_master_poses_range, "dmps_smoothed_frenet_frame.gpdata", turning_poses, "tp_smoothed_frenet_frame.gpdata" ) 
    
    #@plot.interactive_gnuplot_eucledian_distances( pca.normalize( p ), "%e %e\n", ["Frames", "Normalized Power Value (0 <= e <= 1)"], "Normalized Power Value Graph", "power_plot.gp", "power_plot.gpdata" )
    @plot.interactive_gnuplot_eucledian_distances( pca.normalize( v ), "%e %e\n", ["Frames", "Normalized Velocity"], "", "graphs/velocity_plot.gp", "graphs/velocity_plot.gpdata", @from, @dance_master_poses, @dance_master_poses_range, "graphs/dmps_velocity_plot.gpdata" )
    # @plot.interactive_gnuplot_eucledian_distances( pca.normalize( a ), "%e %e\n", ["Frames", "Normalized Acceleration Value (0 <= e <= 1)"], "Normalized Acceleration Value Graph", "acceleration_plot.gp", "acceleration_plot.gpdata" )
    
    @plot.interactive_gnuplot_eucledian_distances( pca.normalize( dis ), "%e %e\n", ["Frames", "Normalized Eucledian Distance Window"], "", "graphs/eucledian_distances_window_plot.gp", "graphs/eucledian_distances_window_plot.gpdata", @from, @dance_master_poses, @dance_master_poses_range, "graphs/dmps_eucleadian_distance.gpdata", turning_poses, "graphs/tp_eucleadian_distance.gpdata" )
    @plot.interactive_gnuplot_eucledian_distances( pca.normalize( all_energy ), "%e %e\n", ["Frames", "Normalized Kinetic Energy"], "", "graphs/ekin.gp", "graphs/ekin.gpdata", @from, @dance_master_poses, @dance_master_poses_range, "graphs/dmps_ekin.gpdata", turning_poses, "graphs/tp_ekin.gpdata" )
    @plot.interactive_gnuplot_eucledian_distances( pca.normalize( e ), "%e %e\n", ["Frames", "Normalized Weight"], "", "graphs/weight.gp", "graphs/weight.gpdata", @from, @dance_master_poses, @dance_master_poses_range, "graphs/dmps_weight.gpdata", turning_poses, "graphs/tp_weight.gpdata" )
    #pca.interactive_gnuplot( pca.reshape_data( plot, false, true ), "%e %e %e\n", %w[PC1 PC2 PC3],  "plot.gp", all_eval, all_evec )
    #pca.interactive_gnuplot( forearms, "%e %e %e\n", %w[X Y Z],  "forearms_plot.gp" )

  end # of getData }}}

end # of class Turning }}}


# Direct Invocation
if __FILE__ == $0 # {{{
end # of if __FILE__ == $0 }}}

