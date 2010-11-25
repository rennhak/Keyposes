#!/usr/bin/ruby
#

###
#
# File: Clustering.rb
#
######


###
#
# (c) 2009-2011, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       Clustering.rb
# @author     Bjoern Rennhak
#
#######


# = Gems
require 'k_means'

# = Local
require_relative 'Mathematics.rb'


class Clustering # {{{

  # Constructor
  def initialize options # {{{
    @options      = options
    @mathematics  = Mathematics.new
  end # of def initialize }}}


  def kmeans data, centroids = 8
    raise ArgumentError, "Data should be of shape [ [x,y,z],...]" if( (data.length == 3) and not (data.first.length == 3 ) )

    km_tmp      = KMeans.new(data, :centroids => centroids)
    centroids   = km_tmp.centroids
    km          = eval( km_tmp.inspect.to_s )

    clusters    = Hash.new

    km.each_with_index do |cluster_array, cluster_index|
      cluster_array.each do |frame|
        clusters[ frame ] = cluster_index
      end
    end

    return [ clusters, centroids ]
  end


  # @fn def distances data, centroids # {{{
  # euclidean distance from each point to each cluster centroid
  # @returns [Hash] Each Key being the data index and value containing an array which is [ centroid id , eucledian distance ]
  def distances data, centroids
    dists = Hash.new

    centroids.each_with_index do |c, cindex|
      # cx, cy, cz = c.position # cluster centroid postion

      data.each_with_index do |d, dindex|
        ed = @mathematics.eucledian_distance( c.position, d )  # distance of centroid and data point

        #           centroid_id, data index, eucleadian distance
        dists[ dindex ] = [] if( dists[ dindex ].nil? )
        dists[ dindex ] << [ cindex, ed ]
      end # of data.each
    end # of centroids.each_...

    return dists
  end # of def distances data, centroids # }}}


  # @fn {{{
  # find closest centroid to each point, and the corresponding distance
  def closest_centroids dists, centroids, data

    # dists -> subarray of [ centroid id, data index, eucledian distance ]
    closest = []    # index here is the same as for data

    # go through entire data set and find closest centroid and distance
    0.upto(data.length - 1).each do |i|
      tmp_i, tmp_cindex, tmp_ed = nil, nil, nil

      dists[ i ].each do |cindex, ed| # centroid id, eucledian distance

        # Make sure that tmp vars have some initial value
        tmp_i       = i       if( tmp_i.nil? )
        tmp_cindex  = cindex  if( tmp_cindex.nil? )
        tmp_ed      = ed      if( tmp_ed.nil? )

        # Make sure we update if value is smaller than prev
        if( ed < tmp_ed )
          tmp_i       = i
          tmp_cindex  = cindex
          tmp_ed      = ed
        end # of if( ed <= ..

      end # of dists[i].each..

      closest << [ tmp_cindex, tmp_ed ]
    end # of 0.upto(data.length..

    return closest
  end # of def closest_centroids }}}

  
  # @fn {{{
  # @param closest_centroids is input from the same named function
  # The distortion, as far as Kmeans is concerned, is used as a stopping
  # criterion (if the change between two iterations is less than some threshold, we
  # assume convergence)
  def distortions closest_centroids
    return closest_centroids.collect { |cid, d| d }.to_a.inject( :+ )
  end # of def distortions }}}


  # @fn {{{
  # @param closest_centroids is input from the same named function
  # @returns [Array] Index being cluster id index and total within cluster sum of squares
  # Should become smaller for good clustering results
  def total_within_cluster_sum_of_squares closest_centroids
    tcss = 0 # index represents cluster id

    closest_centroids.each do |cid, d|
        tcss += ( d ** 2 )
    end

    return tcss
  end # of def total_within_cluster_sum_of_squares }}}

  
  # input: is from distances function ( hash)
  def tss data
    tss = 0
    
    # we get : data-> dists[ dindex ] << [ cindex, ed ]
    data.each_pair do |dindex, array|
      array.each do |ci, ed|
        tss += ed
      end
    end
  
    return tss
  end


  # @fn {{{
  # @param input from the distances method
  # http://en.wikipedia.org/wiki/Total_sum_of_squares
  def total_sum_of_squares closest_centroids
    grand_mean = 0
    cnt = 0

    closest_centroids.each do |cid, d|
      grand_mean += d
      cnt += 1
    end

    grand_mean = grand_mean / cnt

    tss = 0
    cnt = 0

    closest_centroids.each do |cid, d|
      # tss += ( d - grand_mean ) ** 2
      tss += ( d ) ** 2
      cnt += 1
    end
  
    # # dists[ dindex ] << [ cindex, ed ]
    # distances.each_pair do |dindex, v_array|
    #  v_array.each do |ci, ed|
    #    tss += ed**2
    #    cnt += 1
    #  end 
    #end

    return tss / cnt
  end # of def total_sum_of_squares }}}
 


end # of class Clustering }}}


# Direct Invocation
if __FILE__ == $0 # {{{

end # of if __FILE__ == $0 }}}
