#!/usr/bin/ruby
#

###
#
# File: PoseVisualizer.rb
#
######


###
#
# (c) 2009-2011, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       PoseVisualizer.rb
# @author     Bjoern Rennhak
# @copyright  See COPYRIGHT file for details.
#
#######


# Standard includes
require 'ostruct'
require 'rubygems'

# 3D
require 'opengl'

# 2D + Audio
require 'sdl'

# SVG and Convert
require 'RMagick'
require 'rvg/rvg'

# Custom includes
$:.push('.')
require 'Logger.rb'
require 'Frames.rb'

# Change Namespace
include Magick
include Gl,Glu,Glut

# Set DPI
Magick::RVG.dpi = 72

###
#
# @class   PoseVisualizer
# @brief   This class helps with generating images of 3D data (poses).
#
#######
class PoseVisualizer # {{{

  # @fn         def initialize options = nil, kmeans = nil, adts = nil, closest_frame = nil  # {{{
  # @brief      The Custom Constructor of the PoseVisualizer class, used for instantiating and object.
  #
  # @param      [OpenStruct]    options         Options Struct which we generated in the Controller class (parse function)
  # @param      [Hash]          kmeans          Kmeans, output gathered from the Clustering::kmeans function (first part of the return value)
  # @param      [Array]         adts            Array containing other complex datastructures as items (adts.each do |adt, turning_data, meta|)
  # @param      [Array]         closest_frame   Array, each index is a cluster id and each item is a subarray with corresponding frames for that cluster.
  # @param      [Array]         centroids       Centroids used for this clustering. Array consists of centroid classes as defined in the k_means gem. (array index is cluster id)
  def initialize options = nil, kmeans = nil, adts = nil, closest_frame = nil, centroids = nil

    # Input verification {{{
    raise ArgumentError, "Options cannot be nil"        if( options.nil? )
    raise ArgumentError, "Kmeans cannot be nil"         if( kmeans.nil? )
    raise ArgumentError, "Adts cannot be nil"           if( adts.nil? )
    raise ArgumentError, "Closest frame cannot be nil"  if( closest_frame.nil? )
    raise ArgumentError, "Centroids cannot be nil"      if( centroids.nil? )
    # }}}

    @options          = options
    @log              = Logger.new( options )

    # contains hash with hash[frame] => cluster id
    @kmeans           = kmeans
    @centroids        = centroids
    @closest_frame    = closest_frame

    @lookup_table     = []

    @adts             = adts
    @first_time       = true

    adt_cnt           = 0
    @adts.each do |adt, turning_data, meta|

      raise ArgumentError, "adt_cnt > 0 means trouble - implementation is messy" if( adt_cnt > 0 ) 

      config          = turning_data[0][0]
      tp_calc_result  = turning_data[0][1]

      configurations_dir, domain, name, pattern, speed, cycle, filename = config

      raise ArgumentError, "From -> to range needs to include all frames for PoseVisualizer" if( (meta[ "from" ] != 0) or (meta[ "to" ] != meta[ "total_frames" ]) )
      meta[ "from" ].upto( meta[ "to" ] - 1 ).each { @lookup_table << adt_cnt }
      adt_cnt        += 1
    end

    raise ArgumentError, "K-Means length and lookup table length need to be the same" unless( ( @kmeans.keys.length ) == ( @lookup_table.length ) )

    @fov              = 90

    @width            = 800 # in pixel
    @height           = 600

    @color            = OpenStruct.new
    @color.black      = [ 0.0, 0.0, 0.0 ] # each color (r,g,b) from 0.0 - 1.0
    @color.red        = [ 1.0, 0.0, 0.0 ]

    init
    drawgl( @width, @height )

  end # of def initialize }}}


  # @fn         def init font = "fonts/arial.ttf", font_size = 24 {{{
  # @brief      Initialise OpenGL state for 3D rendering.
  #
  # @param      [String]        font          Truetype font file
  # @param      [Integer]       font_size     Font size in ints
  def init font = "fonts/arial.ttf", font_size = 24

    # Initialize SDL and OpenGL
    SDL.init( SDL::INIT_VIDEO )

    SDL::GL.set_attr( SDL::GL::RED_SIZE,      8   )
    SDL::GL.set_attr( SDL::GL::GREEN_SIZE,    8   )
    SDL::GL.set_attr( SDL::GL::BLUE_SIZE,     8   )
    SDL::GL.set_attr( SDL::GL::ALPHA_SIZE,    8   )
    SDL::GL.set_attr( SDL::GL::DOUBLEBUFFER,  1   )
    SDL::GL.set_attr( SDL::GL::DEPTH_SIZE,    16  )

    @screen       = SDL::Screen.open @width, @height, 8, SDL::OPENGL # | SDL::SURFACE
    SDL::WM::set_caption( $0, $0 )


    SDL::TTF.init
    @font         = SDL::TTF.open( font, font_size )
    @font.style   = SDL::TTF::STYLE_NORMAL

    GL.ClearColor( 1.0, 1.0, 1.0, 1.0)
    GL.ClearDepth( 1.0 )

    # Anti-Aliasing for lines and points
    GL.Enable( GL_LINE_SMOOTH )
    GL.Enable( GL_POINT_SMOOTH )
    GL.Enable( GL_BLEND )
    GL.BlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA )
    GL.PointSize( 4.0 )

    GL.Clear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT )

    GL.Viewport( 0, 0, @width, @height );

    GL.MatrixMode( GL_PROJECTION );
    GL.LoadIdentity();

    GL.MatrixMode( GL_MODELVIEW );
    GL.LoadIdentity( );

    GL.Enable( GL_DEPTH_TEST );
    GL.DepthFunc( GL_LESS );
    GL.ShadeModel( GL_SMOOTH );

    GL.Hint( GL::PERSPECTIVE_CORRECTION_HINT, GL::NICEST )

    GL.MatrixMode( GL_PROJECTION )
    GL.LoadIdentity()

    # Zoom view
    # zoom_factor = 5.0
    # zNear, zFar = 0.1,50
    # GLU.Perspective(50.0*zoom_factor, @width.to_f/@height.to_f, zNear, zFar)
    # GLU.LookAt( 0, 0, 0, 0, 0, 0, 0, 1, 0 );
    # GLU.Perspective(@fov, @width.to_f() / @height.to_f(), 0.1, 1024.0)

    # Segfaults currently
    # @screen.save_bmp( "test.bmp" )

    return true
  end # def init font = "fonts/arial.ttf", font_size = 24 }}}


  # @fn         def resize width = 800, height = 600 # {{{
  # @brief      Resize OpenGL viewport
  #
  # @param      [Integer]       width     Width of the screen size to resize to
  # @param      [Integer]       height    Height of the screen size to resize to
  def resize width = 800, height = 600, fov = @fov

    # Input verification {{{
    raise ArgumentError, "Width needs to be of type integer" unless( width.is_a?(Integer) )
    raise ArgumentError, "Height needs to be of type integer" unless( height.is_a?(Integer) )
    # }}}

    GL.Viewport( 0, 0, width, height )                                  # Adjust viewport

    GL.MatrixMode(GL::PROJECTION)                                       # Reproject current scene
    GL.LoadIdentity()                                                   # Clear current
    GLU.Perspective( @fov, width.to_f() / height.to_f(), 0.1, 1024.0 )  # Adjust perspective

    GL.MatrixMode(GL::MODELVIEW)                                        # Switch to normal
    GL.LoadIdentity()
  end # of def resize width = 800, height = 600 }}}


  # @fn         def normalize value = nil, smoothing_parameter = 30 # {{{
  # @brief      We use a sigmoid like function to reshape all input values to a limit set to the
  #             smoothing parameter (e.g. between -1 and 1)
  #             http://people.revoledu.com/kardi/tutorial/Similarity/Normalization.html
  #
  # @param      [Numeric]   value                 Numerical value we want to normalize
  # @param      [Numeric]   smoothing_parameter   Numerical value, greater than 0 which is used to
  #                                             determine the smoothness of the sigmoid function
  #
  # @returns    Result reshaped using a sigmoid like function to a bounded value between -1 and 1.
  def normalize value = nil, smoothing_parameter = 30

      # Input verification # {{{
      raise ArgumentError, "Value may not be nil" if( value.nil? )
      raise ArgumentError, "Value must be of type numeric" unless( value.is_a?(Numeric) )
      raise ArgumentError, "smoothing_parameter must be of type numeric" unless( smoothing_parameter.is_a?(Numeric) )
      raise ArgumentError, "smoothing_parameter must be greater 0" unless( smoothing_parameter > 0 )
      # }}}

      # Sigmoid function
      result = value / ( Math.sqrt( value ** 2 ) + smoothing_parameter )

      return result
  end # end of def normalize value = nil, smoothing_parameter = 30 # }}}


  # @fn         def drawgl width = nil, height = nil # {{{
  # @brief      Render OpenGL scene
  #
  # @param      [Integer]       width     Width of the screen size to resize to
  # @param      [Integer]       height    Height of the screen size to resize to
  def drawgl width = nil, height = nil
    @tmp_cnt          = 0


    @clus = Hash.new
    @kmeans.each_pair do |frame, cluster|
      @clus[ cluster ] = [] if( @clus[ cluster ].nil? )
      @clus[ cluster ] << frame
    end

    @intervals = Hash.new
    @clus.each_pair do |cluster, frames|
      @current_interval = []
      @intervals[ cluster ] = [] if( @intervals[ cluster ].nil? )
      # puts "Cluster: " + cluster.to_s

      frames.each_with_index do |frame, index|
        if( @current_interval.empty? )
          @current_interval << frame.to_i
          # puts "A: #{frame.to_s}"
          next
        end

        # reached end of interval
        unless( ( frames[ index ].to_i + 1 ) == ( frames[ index + 1 ] )  )
          @current_interval << frame.to_i
          @intervals[ cluster ] << @current_interval.dup
          @current_interval.clear
          # puts "B: #{frame.to_s}"
          next
        end

      end # of frames.each
    end # of @clus.each_pair

    @final_intervals = Hash.new
    @intervals.each_pair do |cluster, vals|
      vals.each do |start_frame, end_frame|
        @final_intervals[ cluster ] = [] if( @final_intervals[ cluster ].nil? )

        middle_frame = start_frame + ( ( end_frame - start_frame ) * 0.5 ).to_i
        @final_intervals[ cluster ] << [ start_frame, middle_frame, end_frame ]
      end
    end


    @adts.each do |adt, turning, meta|

      config          = turning[0][0]
      tp_calc_result  = turning[0][1]

      configurations_dir, domain, name, pattern, speed, cycle, filename = config


      center    = adt.pt30

      # right
      rfin      = ( adt.rfin - center).getCoordinates!
      relb      = ( adt.relb - center).getCoordinates!
      rsho      = ( adt.rsho - center).getCoordinates!

      rtoe      = ( adt.rtoe - center).getCoordinates!
      rank      = ( adt.rank - center).getCoordinates!
      rkne      = ( adt.rkne - center).getCoordinates!
      rhee      = ( adt.rhee - center).getCoordinates!

      # center
      pt26      = ( adt.pt26 - center).getCoordinates!
      pt27      = ( adt.pt27 - center).getCoordinates!
      pt28      = ( adt.pt28 - center).getCoordinates!
      pt29      = ( adt.pt29 - center).getCoordinates!
      pt30      = ( adt.pt30 - center).getCoordinates!
      pt31      = ( adt.pt31 - center).getCoordinates!

      # waist
      rfwt      = ( adt.rfwt - center).getCoordinates!
      rbwt      = ( adt.rbwt - center).getCoordinates!
      lfwt      = ( adt.lfwt - center).getCoordinates!
      lbwt      = ( adt.lbwt - center).getCoordinates!

      # left
      lfin      = ( adt.lfin - center).getCoordinates!
      lelb      = ( adt.lelb - center).getCoordinates!
      lsho      = ( adt.lsho - center).getCoordinates!

      ltoe      = ( adt.ltoe - center).getCoordinates!
      lank      = ( adt.lank - center).getCoordinates!
      lkne      = ( adt.lkne - center).getCoordinates!
      lhee      = ( adt.lhee - center).getCoordinates!

      # head
      lfhd      = ( adt.lfhd - center).getCoordinates!
      lbhd      = ( adt.lbhd - center).getCoordinates!
      rfhd      = ( adt.rfhd - center).getCoordinates!
      rbhd      = ( adt.rbhd - center).getCoordinates!

      # e.g. aarms=>[[:rfin, :rsho]], :legs=>[[:rtoe, :pt29]], :upper_arms=>[[:relb, :rsho]], :fore_arms=>[[:pt27, :relb]], :hands=>[[:rfin, :pt27]], :thighs=>[[:rkne, :pt29]], :shanks=>[[:rank, :rkne]], :feet=>[[:rtoe, :rank]]}
      components_right  = adt.body.group_12_model_right
      components_left   = adt.body.group_12_model_left

      @highlight         = []

      @options.body_parts.each do |part|
        @highlight << components_right[ part.to_sym ].flatten
        @highlight << components_left[ part.to_sym ].flatten
      end

      components_head   = Hash.new
      components_head[ "head" ]   = [[:lfhd, :rfhd],[:lbhd, :rbhd],[:lfhd, :lbhd],[:rfhd, :rbhd]]
    
      components_waist = Hash.new
      components_waist[ "waist" ] = [[:lfwt, :rfwt],[:lbwt, :rbwt],[:lfwt, :lbwt],[:rfwt, :rbwt]]
    
      components_extra = Hash.new
      components_extra[ "heels" ] = [[:ltoe, :lhee],[:rtoe, :rhee], [:lhee, :lank], [:rhee, :rank]]


      components_h = [lfhd, lbhd, rfhd, rbhd]
      components_e = [pt26, pt27, pt28, pt29, pt30, pt31]
      components_r = [rfin, relb, rsho, rtoe, rank, rkne, rhee, rfwt, rbwt]
      components_l = [lfin, lelb, lsho, ltoe, lank, lkne, lhee, lfwt, lbwt]

      components = ( ( components_r.concat( components_l ) ).concat( components_e ) ).concat( components_h )

      ( 0 ).upto( @options.clustering_k_parameter.to_i ).each do |k|
        @tmp_cnt = 0

        @log.message :warning, "Showing *NOW* only CLUSTER #{k.to_s}"
        # sleep( 3 )

        0.upto( rfin.length - 1 ) do |i|

          current_cluster = @kmeans[ @tmp_cnt ].to_i

          # @log.message :info, "Current cluster: #{current_cluster.to_s} #{}"
          unless( current_cluster == k )
            @tmp_cnt += 1
            next
          end

          if( @first_time )
            puts "Press key"
            #STDIN.gets
            @first_time = false
          end

          @log.message :success, "This pose of frame (#{@tmp_cnt.to_s}) is part of CLUSTER >>>  #{current_cluster.to_s} <<<"

          glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

          # Draw points
          components.each do |component|
            x, y, z = *component[ i ]
            draw_point( x, y, z )
          end

          deg2rad = Math::PI / 180.0

          # Turning point -- FIXME: This point cannot be correct?
          tp_x, tp_y, tp_z = tp_calc_result[ i ]
          # draw_point( tp_x, tp_y, tp_z, [1,0,0] )

          # Draw connecting lines
          components_right.each do |type, combo|
            combo.each do |array|
              raise ArgumentError, "Array needs to be of length 2" unless( array.length == 2 ) 

              first, last = *array
              next if( first.to_s == "rfin" and last.to_s == "rsho" )
              next if( first.to_s == "rtoe" and last.to_s == "pt29" )

              x1, y1, z1 = *( eval(array.first.to_s)[ i ] )
              x2, y2, z2 = *( eval(array.last.to_s)[ i ] )

              color = @color.black
              @highlight.each do |a, b|
                if( ((first.to_s == a.to_s) and (last.to_s == b.to_s) ) or ( (last.to_s == a.to_s) and (first.to_s == b.to_s) )  )
                  color = @color.red
                  break
                end
              end

#              Draw Ellipsoid
#              lengthX = (x2 - x1)
#              lengthY = (y2 - y1)
#              lengthZ = (z2 - z1)
#
#              radiusX = lengthX / 2
#              radiusY = lengthY / 2
#              radiusZ = lengthZ / 2
#
#              centerX = radiusX + x1 
#              centerY = radiusY + y1
#              centerZ = radiusZ + z1
#
#              # draw_point( centerX, centerY, centerZ, [0,1,0], 10, true )
#
#              0.upto( 360 ).each do |i|
#                #degInRad = i * deg2rad
#
#                glPushMatrix()
#                  ellipsoid = GLU.NewQuadric()
#                  GL.Translate( normalize( centerX ), normalize( centerY ), normalize( centerZ ) )
#                  #angle = 0
#                  GL.Rotate( i, normalize( lengthX ), normalize( lengthY ), normalize( lengthZ ) )
#
#                  glScale( normalize( radiusX.to_f ) , normalize( radiusY.to_f ), normalize( radiusZ.to_f ) )
#                  glColor( 0.8, 0.8, 0.8 )
#                  GLU.Sphere( ellipsoid, 1.0, 100, 100 )
#                  GLU.DeleteQuadric( ellipsoid )
#                glPopMatrix()
#              end 

              draw_line( x1, y1, z1, x2, y2, z2, color )
            end
          end

          components_left.each do |type, combo|
            combo.each do |array|
              raise ArgumentError, "Array needs to be of length 2" unless( array.length == 2 ) 

              first, last = *array
              next if( first.to_s == "lfin" and last.to_s == "lsho" )
              next if( first.to_s == "ltoe" and last.to_s == "pt28" )

              x1, y1, z1 = *( eval(array.first.to_s)[ i ] )
              x2, y2, z2 = *( eval(array.last.to_s)[ i ] )

              color = @color.black
              @highlight.each do |a, b|
                if( ((first.to_s == a.to_s) and (last.to_s == b.to_s) ) or ( (last.to_s == a.to_s) and (first.to_s == b.to_s) )  )
                  color = @color.red
                  break
                end
              end

              draw_line( x1, y1, z1, x2, y2, z2, color )
            end
          end

          components_head.each do |type, combo|
            combo.each do |array|
              raise ArgumentError, "Array needs to be of length 2" unless( array.length == 2 ) 

              first, last = *array
              x1, y1, z1 = *( eval(array.first.to_s)[ i ] )
              x2, y2, z2 = *( eval(array.last.to_s)[ i ] )

              color = @color.black
              @highlight.each do |a, b|
                if( ((first.to_s == a.to_s) and (last.to_s == b.to_s) ) or ( (last.to_s == a.to_s) and (first.to_s == b.to_s) )  )
                  color = @color.red
                  break
                end
              end

              draw_line( x1, y1, z1, x2, y2, z2, color )
            end
          end

          components_waist.each do |type, combo|
            combo.each do |array|
              raise ArgumentError, "Array needs to be of length 2" unless( array.length == 2 ) 

              first, last = *array
              x1, y1, z1 = *( eval(array.first.to_s)[ i ] )
              x2, y2, z2 = *( eval(array.last.to_s)[ i ] )
              color = @color.black
              @highlight.each do |a, b|
                if( ((first.to_s == a.to_s) and (last.to_s == b.to_s) ) or ( (last.to_s == a.to_s) and  (first.to_s == b.to_s) )  )
                  color = @color.red
                  break
                end
              end

              draw_line( x1, y1, z1, x2, y2, z2, color )
            end
          end

          components_extra.each do |type, combo|
            combo.each do |array|
              raise ArgumentError, "Array needs to be of length 2" unless( array.length == 2 ) 

              first, last = *array
              x1, y1, z1 = *( eval(array.first.to_s)[ i ] )
              x2, y2, z2 = *( eval(array.last.to_s)[ i ] )
              color = @color.black

              draw_line( x1, y1, z1, x2, y2, z2, color )
            end
          end

          #glDisable(GL_DEPTH_TEST)

          # glColor( @color.black )
          #@font.draw_solid_utf8( @screen, 'CLASS XXXXXXX', 0, 0, 0.0, 1.0, 0.0 )

          #@screen.flip
          #glEnable(GL_DEPTH_TEST)

          @plot = Plotter.new(0,0)
          @final_intervals[ current_cluster ].each do |start_frame, middle_frame, end_frame|
            if( [ start_frame.to_i, middle_frame.to_i, end_frame.to_i ].include?( i ) )

              # Plot histograms only for bounrary frames we are interested in
              sf = []
              mf = []
              ef = []

              0.upto( rfin.length - 1 ) do |i|
                components.each do |component|
                  sf << component[i] if( [ start_frame.to_i ].include?( i ) )
                  mf << component[i] if( [ middle_frame.to_i ].include?( i ) )
                  ef << component[i] if( [ end_frame.to_i ].include?( i ) )
                end
              end

              puts "Storing cluster object for later usage"

              frames = Frames.new( current_cluster, @centroids[ current_cluster.to_i], start_frame.to_s, sf, middle_frame.to_s, mf, end_frame.to_s, ef )
              dump   = Marshal.dump( frames )
              begin
                Dir.mkdir( "frames_objects/" + current_cluster.to_s )
              rescue
              end

              file   = File.new( "frames_objects/" + current_cluster.to_s + "/" + start_frame.to_s + "_" + middle_frame.to_s + "_" + end_frame.to_s, "w" )
              file.write( dump )
              file.close


              # @plot.histogram( sf, "/tmp/" + start_frame.to_s + "_start.gp",  "/tmp/" + start_frame.to_s + "_start.gpdata",   "Start Frame (#{start_frame.to_s})" )
              # @plot.histogram( mf, "/tmp/" + middle_frame.to_s + "_middle.gp", "/tmp/" + middle_frame.to_s + "_middle.gpdata",  "Middle Frame (#{middle_frame.to_s})" )
              # @plot.histogram( ef, "/tmp/" + end_frame.to_s + "_end.gp",    "/tmp/" + end_frame.to_s + "_end.gpdata",     "End Frame (#{end_frame.to_s})" )

              # Dir.chdir( "/tmp/" ) do
              #   `gnuplot #{start_frame.to_s}_start.gp`
              #   `convert -background white #{start_frame.to_s}_start.eps #{start_frame.to_s}_start.jpg`
              #   `rm -f #{start_frame.to_s}_start.eps`

              #   `gnuplot #{middle_frame.to_s}_middle.gp`
              #   `convert -background white #{middle_frame.to_s}_middle.eps #{middle_frame.to_s}_middle.jpg`
              #   `rm -f #{middle_frame.to_s}_middle.eps`

              #   `gnuplot #{end_frame.to_s}_end.gp`
              #   `convert -background white #{end_frame.to_s}_end.eps #{end_frame.to_s}_end.jpg`
              #   `rm -f #{end_frame.to_s}_end.eps`
              # end

              screenshot( current_cluster, i )
            end
          end

          # draw_text( 0, 0, 0.0, 0.0, 0.0, GLUT_BITMAP_TIMES_ROMAN_24, "HELLO WORLD" )
          # sleep( 0.1 )

          GL.MatrixMode(GL_MODELVIEW) # display the back buffer
          SDL::GL.swap_buffers

          @tmp_cnt += 1


          # Closest frame to centroid screenshot
          # screenshot( @closest_frame.index( i ).to_s, i, "graphs/clusters/centroids" )  if( @closest_frame.include?( i ) )

        end

      end

      # Concat images
      @cluster_images = Hash.new
      @cluster_images_histograms = Hash.new
      @final_intervals.each_pair do |cluster, array|

        @cluster_images[ cluster.to_s ] = [] if( @cluster_images[ cluster.to_s ].nil? )
        @cluster_images_histograms[ cluster.to_s ] = [] if( @cluster_images_histograms[ cluster.to_s ].nil? )

        array.each do |start_frame, middle_frame, end_frame|

          images = []
          images <<  "graphs/clusters/" + cluster.to_s + "/" + start_frame.to_s + ".png"
          images <<  "graphs/clusters/" + cluster.to_s + "/" + middle_frame.to_s + ".png"
          images <<  "graphs/clusters/" + cluster.to_s + "/" + end_frame.to_s + ".png"

          @cluster_images[ cluster.to_s ] << images

          histograms = []
          histograms <<  "/tmp/" + start_frame.to_s + "_start.jpg"
          histograms <<  "/tmp/" + middle_frame.to_s + "_middle.jpg"
          histograms <<  "/tmp/" + end_frame.to_s + "_end.jpg"

          @cluster_images_histograms[ cluster.to_s ] << histograms
        end
      end

      Dir.chdir( "/tmp" ) do
        `rm -f magick*`
      end

      # Merge the screenshots
      @vertical = []
      cnt = 0
      @cluster_images.each_pair do |cluster, images|
        cnt = 0
        @vertical.clear
        images.each do |start, middle, last|

          begin
            imagelist = Magick::ImageList.new( start, middle, last )

            imagelist.each do |image|
              image.border!( 5, 5, "black" )
            end

            im = imagelist.append( false )
            fn = "/tmp/concat_#{cluster.to_s}_#{cnt.to_s}.png"
            im.write( fn.to_s )
            @vertical << fn
            cnt += 1
          rescue
            puts "There was a problem in poseviewer with frames (#{start.to_s}, #{middle.to_s}, #{last.to_s})"
          end
        end # of images.each

        final_fn = "/tmp/final_#{cluster.to_s}.png"

        @log.message :info, "Generating #{final_fn.to_s}"

        final_im = Magick::ImageList.new( *@vertical )
        final_im = final_im.append( true )
        final_im.write( final_fn )
      end # of @cluster_images.each_pair

#:      Dir.chdir( "/tmp" ) do
#:        `rm -f magick*`
#:      end
#:
#:      # Merge the histograms
#:      @vertical = []
#:      cnt = 0
#:      @cluster_images_histograms.each_pair do |cluster, images|
#:        cnt = 0
#:        @vertical.clear
#:        images.each do |start, middle, last|
#:
#:          begin
#:            imagelist = Magick::ImageList.new( start, middle, last )
#:
#:            imagelist.each do |image|
#:              image.border!( 5, 5, "black" )
#:              # image.background_color( "white" )
#:            end
#:
#:            im = imagelist.append( false )
#:            fn = "/tmp/histograms_concat_#{cluster.to_s}_#{cnt.to_s}.jpg"
#:            im.write( fn.to_s )
#:            @vertical << fn
#:            cnt += 1
#:          rescue
#:            puts "There was a problem in poseviewer with frames (#{start.to_s}, #{middle.to_s}, #{last.to_s})"
#:          end
#:        end # of images.each
#:
#:        final_fn = "/tmp/histograms_final_#{cluster.to_s}.jpg"
#:
#:        @log.message :info, "Generating #{final_fn.to_s}"
#:
#:        final_im = Magick::ImageList.new( *@vertical )
#:        final_im = final_im.append( true )
#:        final_im.write( final_fn )
#:
#:      end # of @cluster_images.each_pair
    end

    @font.close
    SDL.quit
  end #  def drawgl width = nil, height = nil }}}


  # @fn         def screenshot cluster = nil, frame = nil, save_dir = "graphs/clusters" # {{{
  # @brief      Create a screenshot over Ruby ImageMagick. Takes a snapshot of OpenGL via glreadpixels
  #             and passes the data to imagemagick for file storage.
  #
  #             The reason why we don't use SDL.save_bmp use is that it segfaults on my machine.
  #             It saves only bmp - anyway (@screen.save_bmp)
  #
  # @param      [Integer]   cluster   Cluster ID.
  # @param      [Integer]   frame     Frame number.
  # @param      [String]    save_dir  Save images in this base directory.
  def screenshot cluster = nil, frame = nil, save_dir = "graphs/clusters"

    cluster_dir = save_dir + "/" + cluster.to_s
    filename    = cluster_dir + "/" + frame.to_s + ".png"

    Dir.mkdir( save_dir ) unless( File.exists?( save_dir ) )
    Dir.mkdir( cluster_dir ) unless( File.exists?( cluster_dir ) ) 

    data = glReadPixels( 0, 0, @width, @height, GL_RGB, GL_UNSIGNED_SHORT )
    screenbuffer = Magick::Image.new( @width, @height )
    screenbuffer.import_pixels( 0, 0, @width, @height, "RGB", data, Magick::ShortPixel ).flip!

    text_string  = "Cluster: #{cluster.to_s} Frame: #{frame.to_s} Component: #{@options.body_parts.join(" ").to_s}"

    text = Magick::Draw.new
    text.font_family = 'helvetica'
    text.pointsize = 25
    text.gravity = Magick::SouthGravity
    text.annotate( screenbuffer, 0, 0, 0, 0, text_string ) {
      self.fill = 'darkred'
    }

    screenbuffer.write( filename )

  end # of def screenshot cluster = nil, frame = nil, save_dir = "graphs/clusters" }}}


  # @fn         def draw_point x = nil, y = nil, z = nil, color = @color.black, point_size = 10, normalize_values = true {{{
  # @brief      The function takes point information as arguments and draws a OpenGL point via GL_POINTS
  #
  # @param      [Numeric]       x                   Float, represeting a point coordinate.
  # @param      [Numeric]       y                   Float, represeting a point coordinate.
  # @param      [Numeric]       z                   Float, represeting a point coordinate.
  # @param      [Array]         color               Array, filled with three elements [r, g, b] (pass just a @color struct entry)
  # @param      [Numeric]       point_size          Float, representing a point size
  # @param      [Boolean]       normalize_values    Boolean, true if input should be normalized, false if not (leave unchanged)
  def draw_point x = nil, y = nil, z = nil, color = @color.black, point_size = 10, normalize_values = true

    # Input verfication {{{
    raise ArgumentError, "All x,y,z input must be non-nil" if( x.nil? or y.nil? or z.nil? )
    raise ArgumentError, "Color needs to be of type array" unless( color.is_a?(Array) )
    raise ArgumentError, "Line width needs to be of type numeric" unless( point_size.is_a?(Numeric) )
    raise ArgumentError, "Normalized values needs to be of type bool" unless( [TrueClass, FalseClass].include?( normalize_values.class ) ) # boolean check
    # }}}

    glPointSize( point_size )                                                             # set point size

    x, y, z = normalize( x ), normalize( y ), normalize( z )  if( normalize_values )      # normalize if requested

    glBegin( GL_POINTS )                                                                  # draw point
      glColor( color )                                                                    # set color
      glVertex( [ x, y, z ] )
    glEnd()

  end # of def draw_point x = nil, y = nil, z = nil, color = @color.black, point_size = 10, normalize_values = true }}}


  # @fn         def draw_line x1 = nil, y1 = nil, z1 = nil, x2 = nil, y2 = nil, z2 = nil, color = @color.black, line_width = 5, normalize_values = true {{{
  # @brief      The function takes point information as arguments and draws a OpenGL line via GL_LINES.
  #
  # @param      [Numeric]       x1                  Float, represeting a point coordinate.
  # @param      [Numeric]       y1                  Float, represeting a point coordinate.
  # @param      [Numeric]       z1                  Float, represeting a point coordinate.
  # @param      [Numeric]       x2                  Float, represeting a point coordinate.
  # @param      [Numeric]       y2                  Float, represeting a point coordinate.
  # @param      [Numeric]       z2                  Float, represeting a point coordinate.
  # @param      [Array]         color               Array, filled with three elements [r, g, b] (pass just a @color struct entry)
  # @param      [Numeric]       line_width          Float, representing a line width (stroke width)
  # @param      [Boolean]       normalize_values    Boolean, true if input should be normalized, false if not (leave unchanged)
  def draw_line x1 = nil, y1 = nil, z1 = nil, x2 = nil, y2 = nil, z2 = nil, color = @color.black, line_width = 5, normalize_values = true

    # Input verfication {{{
    raise ArgumentError, "All x,y,z input must be non-nil" if( x1.nil? or y1.nil? or z1.nil? or x2.nil? or y2.nil? or z2.nil? )
    raise ArgumentError, "Color needs to be of type array" unless( color.is_a?(Array) )
    raise ArgumentError, "Line width needs to be of type numeric" unless( line_width.is_a?(Numeric) )
    raise ArgumentError, "Normalized values needs to be of type bool" unless( [TrueClass, FalseClass].include?( normalize_values.class ) )
    # }}}

    glLineWidth( line_width )       # set line width

    # Normalize values if requested
    if( normalize_values )
      x1, y1, z1 = normalize( x1 ), normalize( y1 ), normalize( z1 )
      x2, y2, z2 = normalize( x2 ), normalize( y2 ), normalize( z2 )
    end

    # Draw lines
    glBegin( GL_LINES )
      glColor( color )              # set line color
      glVertex( [ x1, y1, z1 ] )
      glVertex( [ x2, y2, z2 ] )
    glEnd()

  end # of def draw_line x1 = nil, y1 = nil, z1 = nil, x2 = nil, y2 = nil, z2 = nil, color = @color.black, line_width = 5, normalize_values = true }}}


  # @fn         def draw_text x = nil, y = nil, r = nil, g = nil, b = nil, font = nil, text = nil # {{{
  # @brief      This function draws some text onto the bitmap via GLUT (glutBitmapCharacter function)
  #
  # @param      [Numeric]           x         Numeric, representing the X coordinate.
  # @param      [Numeric]           y         Numeric, representing the Y coordinate.
  # @param      [Numeric]           r         Numeric, representign the red color (0-1)
  # @param      [Numeric]           g         Numeric, representing the green color (0-1)
  # @param      [Numeric]           b         Numeric, representing the blue color (0-1)
  # @param      [SDL::TTF]          font      Object of type SDL::TTF initiated with a proper front file.
  # @param      [String]            text      String, containing the text we want to display on the screen.
  # 
  # Inspireation: http://stackoverflow.com/questions/2183271/what-is-the-easiest-way-to-print-text-to-screen-in-opengl
  def draw_text x = nil, y = nil, r = nil, g = nil, b = nil, font = nil, text = nil

    # Input verification {{{
    raise ArgumentError, "Inputs must all be non-nil" if( x.nil? or y.nil? or r.nil? or g.nil? or b.nil? or font.nil? or text.nil? )
    # }}}

    glColor( r, g, b )                              # set color
    glRasterPos( x, y )                             # set current position

    0.upto( text.length - 1 ).each do |i|           # draw each character onto the bitmap
      glutBitmapCharacter( font, text[i].to_i )
    end

  end # of def draw_text( x = nil, y = nil, r = nil, g = nil, b = nil, font = nil, text = nil ) }}}

end # of class PoseVisualizer # }}}

# Direct invocation (local testing) # {{{
if __FILE__ == $0
end # if __FILE__ == $0 # }}}

# vim:ts=2:tw=100:wm=100
