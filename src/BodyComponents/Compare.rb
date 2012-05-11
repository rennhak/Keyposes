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
$:.push('.')
require 'Logger.rb'
require 'Plotter.rb'
require 'Mathematics.rb'


# @class      Compare # {{{
# @brief      The class Compare takes two different cluster results and compares them for similarity
class Compare

  # @fn       def initialize options, from, to # {{{
  # @brief    Custom constructor for Compare class
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


  # @fn       def load_marshal_objects load_dir = @compare_directories # {{{
  # @brief    Loads instantiated marshalled objects from given directory
  def load_marshal_objects load_dir = @compare_directories
    @log.message :info, "Loading marshaled objects"

    objects = Hash.new

    load_dir.each do |dir|
      result = []

      # get only subdirectory entries
      directories = Dir.glob( "#{dir.to_s}/*/**" )
      directories.collect! { |d| d.gsub( "#{dir}/", "" ) }

      # Extract cycle from dir string (only with ruby 1.9
      /(?<cycle>cycle_[0-9]+)_/ =~ dir

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
  end # of def load_marshal_objects load_dir = @compare_directories # }}}


  # @fn       def centroid_comparsion objects = @objects # {{{
  # @brief    Compares the relative position of cluster centroids from one to another cycle to extact cluster labels
  # 
  # @param    []        objects
  # @returns  [Hash]    Mapping of clusters to each other
  def centroid_comparsion objects = @objects
    @log.message :info, "Comparing relative cluster similarity by centroid similarity in T-Data space"

    # Idea: { "cycle_02" => [ [ cluster0 centroid ], [...], ... ] }
    centroids = Hash.new

    objects.each_pair do |cycle, cluster_array|

      # if centroids doesn't have a empty array create one
      centroids[ cycle.to_s ] = [] if( centroids[ cycle.to_s ].nil? )

      cluster_array.each_with_index do |frames, cluster_index|
        c = []
        frames.each { |f| c << f.centroid } # obviously all centroids should be the same for all frames.

        # If this is not of length 3 then there is something wrong.
        c = c.uniq.flatten 
        raise ArgumentError, "There are more then one unique centroid for this cluster. This cannot be, there is some very bad error." if( c.length != 3 )

        # centroid information stored in frames class
        centroids[ cycle.to_s ][ cluster_index.to_i ] = c
      end
    end # of objects.each_pair do |cycle, cluster_array| 

    # We store the cluster mapping from one cycle to another here
    mapping = Hash.new

    centroids.each_pair do |cycle, first_centroids|

      # Iterate over the entire rest to find similar cluster, each i is the second operand
      # e.g. [ "c2", "c3" ] - [ "c2" ] 
      remaining_keys = centroids.keys - [ cycle ]

      remaining_keys.each do |remaining_cycle|
        second_centroids = centroids[ remaining_cycle ]

        # compare the first_centroids to the remaining centroids
        first_centroids.each_with_index do |f_centroid, f_index|
          # iterate for each of first centroids over all of second centroids
           tmp_distances = []
          second_centroids.each_with_index do |s_centroid, s_index|
            value = @mathematics.eucledian_distance( f_centroid, s_centroid )
            puts "First Centroid (index: #{f_index.to_s}) (coord: #{f_centroid.join(", ").to_s}) - Second Centroid (index: #{s_index.to_s}) (coord: #{s_centroid.join(", ").to_s}) - Eucledian distance: #{value.to_s}"
            tmp_distances[ s_index.to_i ] = value
          end # of second_centroids.each_with_index

          f_cluster_index = f_index
          s_cluster_index = tmp_distances.index( tmp_distances.min )

          hash_key_name   = "#{cycle.to_s + "_->_" + remaining_cycle.to_s}"
          mapping[ hash_key_name ] = [] if( mapping[ hash_key_name ].nil? )
          mapping[ hash_key_name ] << [ f_cluster_index, s_cluster_index ]
          puts ""
        end # of first_centroids.each_with_index
      end # of remaining_keys

      # we just want to exit the centroids hash now (just compare first element of hash to rest of hash)
      break
    end # of centroids.each_pair

    # Distance of centroids to each other
    distances = []
    centroids.each_pair do |cycle, first_centroids|
      first_centroids.each_with_index do |f_centroid, index|

        distances[ index ] = [] if( distances[ index ].nil? )

        first_centroids.each_with_index do |s_centroid, s_index| 
          value = @mathematics.eucledian_distance( f_centroid, s_centroid )
          distances[ index ][ s_index ] = value
        end

      end
    end

    scores      = []

    distances.each_with_index do |dists, index|
      # sort lowest to largest

      indexes   = []
      sorted    = dists.dup.sort
      sorted.each_with_index do |v, i|
        old_index = dists.index( v )
        indexes[ i ] = old_index
      end

      indexes.each_with_index do |cluster_id, iter_idx|
        scores[ cluster_id.to_i ] = 0 if( scores[ cluster_id.to_i ].nil? )
        scores[ cluster_id.to_i ] += iter_idx
      end

      puts "Cluster (#{index.to_s}) closest clusters (similar color) are at (smallest->largest) (#{indexes.join(", ")})"
    end

    # smallerest to largest
    ordered_scores = scores.dup.sort
    ordered_indexes = []
    ordered_scores.each do |os|
      ordered_indexes << scores.index( os )
    end

    p scores
    p ordered_indexes
    puts ""

    mapping
  end # of def centroid_comparsion objects = @objects # }}}


  # @fn       def run objects = @objects # {{{
  # @brief    The run function takes objects from different cycles and compares them.
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
  end # of def run }}}


  # @fn       def angle first_frame # {{{
  # @brief    The angle function measures pose similarity
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
  end # of def angle first_frame # }}}


  # @fn       def diff first_frame, second_frame # {{{
  # @brief    The diff function measures differences between two given frames
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
  end # of def diff }}}

end # of class Compare }}}


# Direct Invocation (local testing) # {{{
if __FILE__ == $0
end # of if __FILE__ == $0 }}}


# vim:ts=2:tw=100:wm=100
