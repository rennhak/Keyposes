#!/usr/bin/ruby
#

###
#
# File: Compare.rb
#
######


###
#
# (c) 2009-2011, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       Compare.rb
# @author     Bjoern Rennhak
#
#######




# Standard includes
require 'rubygems'

# Local includes
require_relative 'Logger.rb'
require_relative 'Plotter.rb'
require_relative 'Mathematics.rb'



# The class Compare takes two different cluster results and compares them for similarity
class Compare # {{{

  # @fn       def initialize options, from, to # {{{
  #
  def initialize options = nil, compare_directories = nil

    # Input verification {{{
    raise ArgumentError, "Options cannot be nil"  if( options.nil? )
    raise ArgumentError, "Compare directories cannot be nil" if( compare_directories.nil? )
    # }}}

    @options             = options
    @compare_directories = compare_directories

    @log                 = Logger.new( @options )

    @mathematics         = Mathematics.new
    @plotter             = Plotter.new( 0, 0 )

    @objects             = load_marshal_objects( @compare_directories )

  end # of def initialize }}}


  def load_marshal_objects load_dir = @compare_directories
    @log.message :info, "Loading marshaled objects"

    objects = Hash.new

    load_dir.each do |dir|
      result = []

      # get only subdirectory entries
      directories = Dir.glob( "#{dir.to_s}/*/**" )
      directories.collect! { |d| d.gsub( "#{dir}/", "" ) }

      # Extract cycle from dir string
      cycle = ""
      dir.split( "_" ).each do |i|
        match   = /c[0-9]+/.match( i )
        cycle = match[0] unless( match.nil? )
      end

      # Create empty array for cycle key
      objects[ cycle.to_s ] = [] if( objects[ cycle.to_s ].nil? )

      # Load marshalled objects onto each array place 
      # array place == cluster id
      Dir.chdir( dir ) do
        directories.each do |dentry|
          cluster = dentry.split( "/" ).first.to_i
          File.open( dentry ) do |file|
            obj = Marshal.load( file )
            objects[ cycle.to_s ][ cluster ] = [] if( objects[ cycle.to_s ][ cluster ].nil? )
            objects[ cycle.to_s ][ cluster ] << obj
          end
        end
      end

    end # of load_dir.each

    objects
  end

  def run objects = @objects
    @log.message :info, "Calculating similarity"
    
    # Objects: @objects
    # Type: Hash each key is e.g. c2, c3,..
    # Value for keys are array with subarrays 
    #
    # e.g.
    # @objects[ "c2" ][ cluster_array ][ frames objects ]
    #


    # FIXME: This is a heavy quickhack 
    @objects.each_pair do |cycle, cluster_array|
      

      # base object we want to compare (first operand)
      cluster_array.each_with_index do |frames, cluster_index|

        frames.each do |frame|
          next if( (frame.end_frame_number.to_i - frame.start_frame_number.to_i ) <= 15 )

          puts " -------- Check against c: #{cycle.to_s} - Cluster idx: #{cluster_index.to_s} - Frames object (current cluster #{frame.current_cluster.to_s}) (start frame number #{frame.start_frame_number.to_s}) (middle frame number #{frame.middle_frame_number.to_s}) (end frame number #{frame.end_frame_number.to_s})"

          # Iterate over the entire rest to find similar cluster, each i is the second operand
          # e.g. [ "c2", "c3" ] - [ "c2" ] 
          remaining_keys = @objects.keys - [ cycle ]
          remaining_keys.each do |remaining_cycle|
            
            @objects[ remaining_cycle ].each do |remaining_cluster_array|
              remaining_cluster_array.each_with_index do |remaining_frame, remaining_cluster_index|
                  d_sum, d_left, d_right = diff( frame, remaining_frame )
                  
                  thresh = 100.0
                  if( d_left[1].abs <= thresh  and d_left[2].abs <= thresh and d_right[1].abs <= thresh and d_right[2].abs <= thresh )

                    if( ( remaining_frame.end_frame_number.to_i - remaining_frame.start_frame_number.to_i)  >= 15 )
                      angles_sum = ( d_left[1].abs + d_left[2].abs + d_right[1].abs + d_right[2].abs )
                      puts "  Check against c: #{remaining_cycle.to_s} - Cluster idx: #{remaining_cluster_index.to_s} -  Remaining: Frames object (current cluster #{remaining_frame.current_cluster.to_s}) (start frame number #{remaining_frame.start_frame_number.to_s}) (middle frame number #{remaining_frame.middle_frame_number.to_s}) (end frame number #{remaining_frame.end_frame_number.to_s})"
                      print "    Distances to first point " 
                      p d_sum
                      print "     Distances total sum " 
                      p d_sum.sum
                      puts "     Angles (left, right) of forearm to upper arm "
                      print "       "
                      p d_left
                      print "       "
                      p d_right
                      puts ""
                      puts "     Angles difference sum (total) : #{angles_sum.to_s}"
                      puts "" 
                    end
                  end
              end # of remaining_cluster_array.each_with_index

            end # of @objects[ remaining_cycle ]
          end # of remaining_keys.each

        end # of frames.each do

      end # of cluster_array.each_with_index

      # Don't contine.. we just compare the first hash versus all other remainings, but we don't
      # compare the second versus all other remaining (duplication)
      break

    end # of @objects.each_pair
  end # of def run


  def angle first_frame

    res = []

    f_current_cluster, f_start_frame_number, f_start_frame_data, f_middle_frame_number, f_middle_frame_data = first_frame.current_cluster, first_frame.start_frame_number, first_frame.start_frame_data, first_frame.middle_frame_number, first_frame.middle_frame_data
    f_end_frame_number, f_end_frame_data = first_frame.end_frame_number, first_frame.end_frame_data


#      components_r = [rfin, relb, rsho, rtoe, rank, rkne, rhee, rfwt, rbwt]
#      components_l = [lfin, lelb, lsho, ltoe, lank, lkne, lhee, lfwt, lbwt]
#      components_e = [pt26, pt27, pt28, pt29, pt30, pt31]
#      components_h = [lfhd, lbhd, rfhd, rbhd]
#
#      components = ( ( components_r.concat( components_l ) ).concat( components_e ) ).concat( components_h )



    right = @mathematics.angle_between_two_lines( f_start_frame_data[19], f_start_frame_data[1], f_start_frame_data[1], f_start_frame_data[2] )
    left  = @mathematics.angle_between_two_lines( f_start_frame_data[18], f_start_frame_data[10], f_start_frame_data[10], f_start_frame_data[11] )
    res << [ left, right ]

    right = @mathematics.angle_between_two_lines( f_middle_frame_data[19], f_middle_frame_data[1], f_middle_frame_data[1], f_middle_frame_data[2] )
    left  = @mathematics.angle_between_two_lines( f_middle_frame_data[18], f_middle_frame_data[10], f_middle_frame_data[10], f_middle_frame_data[11] )
    res << [ left, right ]

    right = @mathematics.angle_between_two_lines( f_end_frame_data[19], f_end_frame_data[1], f_end_frame_data[1], f_end_frame_data[2] )
    left  = @mathematics.angle_between_two_lines( f_end_frame_data[18], f_end_frame_data[10], f_end_frame_data[10], f_end_frame_data[11] )
    res << [ left, right ]

    res
  end



  def diff first_frame, second_frame

    res = []

    f_current_cluster, f_start_frame_number, f_start_frame_data, f_middle_frame_number, f_middle_frame_data = first_frame.current_cluster, first_frame.start_frame_number, first_frame.start_frame_data, first_frame.middle_frame_number, first_frame.middle_frame_data
    f_end_frame_number, f_end_frame_data = first_frame.end_frame_number, first_frame.end_frame_data

    s_current_cluster, s_start_frame_number, s_start_frame_data, s_middle_frame_number, s_middle_frame_data = second_frame.current_cluster, second_frame.start_frame_number, second_frame.start_frame_data, second_frame.middle_frame_number, second_frame.middle_frame_data
    s_end_frame_number, s_end_frame_data = second_frame.end_frame_number, second_frame.end_frame_data


#      components_r = [rfin, relb, rsho, rtoe, rank, rkne, rhee, rfwt, rbwt]
#      components_l = [lfin, lelb, lsho, ltoe, lank, lkne, lhee, lfwt, lbwt]
#      components_e = [pt26, pt27, pt28, pt29, pt30, pt31]
#      components_h = [lfhd, lbhd, rfhd, rbhd]
#
#      components = ( ( components_r.concat( components_l ) ).concat( components_e ) ).concat( components_h )




    start_frame_distances = []
    0.upto( f_start_frame_data.length - 1 ) do |i|
      start_frame_distances << @mathematics.eucledian_distance( f_start_frame_data[i], s_start_frame_data[i] )
    end

    middle_frame_distances = []
    0.upto( f_middle_frame_data.length - 1 ) do |i|
      middle_frame_distances << @mathematics.eucledian_distance( f_middle_frame_data[i], s_middle_frame_data[i] )
    end

    end_frame_distances = []
    0.upto( f_end_frame_data.length - 1 ) do |i|
      end_frame_distances << @mathematics.eucledian_distance( f_end_frame_data[i], s_end_frame_data[i] )
    end


    #res << start_frame_distances.sum
    #res << middle_frame_distances.sum
    #res << end_frame_distances.sum
    
    # get angles of first frame
    s_frame_angle, m_frame_angle, e_frame_angle = *angle( first_frame )

    sum   = [ start_frame_distances[19], start_frame_distances[1], start_frame_distances[18], start_frame_distances[10] ].sum
    left  = @mathematics.angle_between_two_lines( s_start_frame_data[18], s_start_frame_data[10], s_start_frame_data[10], s_start_frame_data[11] )
    right = @mathematics.angle_between_two_lines( s_start_frame_data[19], s_start_frame_data[1], s_start_frame_data[1], s_start_frame_data[2] )

    left  -= s_frame_angle.first
    right -= s_frame_angle.last

    res << [ sum, left, right ]

    sum   = [ middle_frame_distances[19], middle_frame_distances[1], middle_frame_distances[18], middle_frame_distances[10] ].sum
    left  = @mathematics.angle_between_two_lines( s_middle_frame_data[18], s_middle_frame_data[10], s_middle_frame_data[10], s_middle_frame_data[11] )
    right = @mathematics.angle_between_two_lines( s_middle_frame_data[19], s_middle_frame_data[1], s_middle_frame_data[1], s_middle_frame_data[2] )

    left  -= m_frame_angle.first
    right -= m_frame_angle.last

    res << [ sum, left, right ]

    sum   = [ end_frame_distances[19], end_frame_distances[1], end_frame_distances[18], end_frame_distances[10] ].sum
    left  = @mathematics.angle_between_two_lines( s_end_frame_data[18], s_end_frame_data[10], s_end_frame_data[10], s_end_frame_data[11] )
    right = @mathematics.angle_between_two_lines( s_end_frame_data[19], s_end_frame_data[1], s_end_frame_data[1], s_end_frame_data[2] )

    left  -= e_frame_angle.first
    right -= e_frame_angle.last

    res << [ sum, left, right ]

    res
  end

end # of class Compare }}}


# Direct Invocation
if __FILE__ == $0 # {{{
end # of if __FILE__ == $0 }}}

