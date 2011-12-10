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
require_relative 'Logger.rb'


# Change Namespace
include Magick
include Gl,Glu,Glut

# Set DPI
Magick::RVG.dpi = 72

###
#
# @class   PoseVisualizer
# @author  Bjoern Rennhak
# @brief   This class helps with generating images of 3D data (poses)
#
#######
class PoseVisualizer # {{{

  def initialize options = nil, kmeans = nil, adts = nil  # {{{
    @options = options
    @log     = Logger.new( options )

    # contains hash with hash[frame] => cluster id
    @kmeans           = kmeans

    @lookup_table     = []

    @adts             = adts
    @first_time       = true


    adt_cnt           = 0
    @adts.each do |adt, turning_data, meta|
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

  end # of initialize }}}


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

    @screen       = SDL::Screen.open @width, @height, 8, SDL::OPENGL | SDL::SWSURFACE
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
    # screen.save_bmp( "test.bmp" )

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


  # @fn       def normalize value = nil, smoothing_parameter = 30 # {{{
  # @brief    We use a sigmoid like function to reshape all input values to a limit set to the
  #           smoothing parameter (e.g. between -1 and 1)
  #           http://people.revoledu.com/kardi/tutorial/Similarity/Normalization.html
  #
  # @param    [Numeric]   value                 Numerical value we want to normalize
  # @param    [Numeric]   smoothing_parameter   Numerical value, greater than 0 which is used to
  #                                             determine the smoothness of the sigmoid function
  #
  # @returns  Result reshaped using a sigmoid like function to a bounded value between -1 and 1.
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


  # @fn       def drawgl width = nil, height = nil # {{{
  # @brief    Render OpenGL scene
  #
  # @param      [Integer]       width     Width of the screen size to resize to
  # @param      [Integer]       height    Height of the screen size to resize to
  def drawgl width = nil, height = nil
    @tmp_cnt          = 0

    @adts.each do |adt, turning, meta|

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
        sleep( 3 )
      
        0.upto( rfin.length - 1 ) do |i|

          current_cluster = @kmeans[ @tmp_cnt ].to_i

          # @log.message :info, "Current cluster: #{current_cluster.to_s} #{}"
          unless( current_cluster == k )
            @tmp_cnt += 1
            next
          end

          if( @first_time )
            puts "Press key"
            STDIN.gets
            @first_time = false
          end



          @log.message :success, "This pose of frame (#{@tmp_cnt.to_s}) is part of CLUSTER >>>  #{current_cluster.to_s} <<<"

          glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);

          # Draw points
          components.each do |component|
            x, y, z = *component[ i ]
            draw_point( x, y, z )
          end

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

          
          # SEGFAULT
          # @screen.save_bmp( "/tmp/test.bmp" )

          # draw_text( 0, 0, 0.0, 0.0, 0.0, GLUT_BITMAP_TIMES_ROMAN_24, "HELLO WORLD" )
          sleep( 0.1 )

          GL.MatrixMode(GL_MODELVIEW) # display the back buffer
          SDL::GL.swap_buffers

          @tmp_cnt += 1

        end


      end

    end

    @font.close
    SDL.quit
  end #  def drawgl width = nil, height = nil }}}


  # @fn         def draw_point x = nil, y = nil, z = nil, color = @color.black, point_size = 10, normalize_values = true {{{
  # @brief      The function takes point information as arguments and draws a OpenGL point via GL_POINTS
  #
  # @param      [Numeric]       x                   Float, represeting a point coordinate.
  # @param      [Numeric]       y                   Float, represeting a point coordinate.
  # @param      [Numeric]       z                   Float, represeting a point coordinate.
  # @param      [Array]         color               Array, filled with three elements [r, g, b] (pass just a @color struct entry)
  # @param      [Numeric]       line_width          Float, representing a line width (stroke width)
  # @param      [Boolean]       normalize_values    Boolean, true if input should be normalized, false if not (leave unchanged)
  def draw_point x = nil, y = nil, z = nil, color = @color.black, point_size = 10, normalize_values = true

    # Input verfication {{{
    raise ArgumentError, "All x,y,z input must be non-nil" if( x.nil? or y.nil? or z.nil? )
    raise ArgumentError, "Color needs to be of type array" unless( color.is_a?(Array) )
    raise ArgumentError, "Line width needs to be of type numeric" unless( line_width.is_a?(Numeric) )
    raise ArgumentError, "Normalized values needs to be of type bool" unless( normalize_values.is_a?(Boolean) )
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
    raise ArgumentError, "Normalized values needs to be of type bool" unless( normalize_values.is_a?(Boolean) )
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

end # of class Plotter # }}}

# = Direct invocation
if __FILE__ == $0 # {{{
end # if __FILE__ == $0 # }}}


