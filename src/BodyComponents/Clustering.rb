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
  def initialize options = nil # {{{
    @options      = options
    @mathematics  = Mathematics.new

    @algorithms   = %w[kmeans]

  end # of def initialize }}}


  # @fn def kmeans data, centroids = 8, centroids_information = nil # {{{
  def kmeans data, centroids = 8, centroids_information = nil
    raise ArgumentError, "Data should be of shape [ [x,y,z],...]" if( (data.length == 3) and not (data.first.length == 3 ) )

    if( centroids_information.nil? )
      km_tmp      = KMeans.new(data, :centroids => centroids)
    else
      cen         = []
      centroids_information.each { |c| cen << Centroid.new( c ) }
      km_tmp      = KMeans.new(data, :centroids => centroids, :custom_centroids => cen )
    end

    centroids   = km_tmp.centroids
    km          = eval( km_tmp.inspect.to_s )

    clusters    = Hash.new

    km.each_with_index do |cluster_array, cluster_index|
      cluster_array.each do |frame|
        clusters[ frame ] = cluster_index
      end
    end

    return [ clusters, centroids ]
  end # }}}


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


  # @fn def closest_centroids dists, centroids, data {{{
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


  # @fn def distortions closest_centroids # {{{
  # @param closest_centroids is input from the same named function
  # The distortion, as far as Kmeans is concerned, is used as a stopping
  # criterion (if the change between two iterations is less than some threshold, we
  # assume convergence)
  # K-Means tries to minimize distortion, which is defined as the sum of the squared
  # distances between each observation vector and its dominating centroid.
  #
  def distortions closest_centroids
    return closest_centroids.collect { |cid, d| d }.to_a.inject( :+ )
  end # of def distortions }}}


  # @fn def squared_error_distortion closest_centroids {{{
  # Given a data point v and a set of points X, define the distance rom v to X as d(v,X)
  # as the (Eucledian) distance from v to the closest point from X
  # Given a set of n data points V={v_1, ..., v_n} and a set of k points X, define the Squared Error
  # Distortion d(V,X) = sum( d(v_i, X)^2 ) / n    \forall 1<=i<=n
  def squared_error_distortion closest_centroids
    return ( closest_centroids.collect { |cid, d| d**2 }.to_a.inject( :+ ) ) / closest_centroids.length
  end # }}}


  # @fn       def rule_of_thumb_k_estimation data_size {{{
  # @brief    Estimates the size of k (the model selection for k-means) based on the data size. This
  #           method is very unexact and is prone to (significant) over estimation.
  # @param    data_size   [Integer]   Length or size of data which we apply K-Means to. E.g. data.length if it an array.
  def rule_of_thumb_k_estimation data_size = nil

    result = 0

    # Input verification {{{
    raise ArgumentError, "Data size cannot be nil" if( data_size.nil? )
    raise ArgumentError, "Data size must be of type integer" unless( data_size.is_a?(Integer) )
    # }}}

    result = ( Math.sqrt( data_size / 2 ) ).to_i

    # Output verification {{{
    raise ArgumentError, "Data size must be of type integer" unless( data_size.is_a?(Integer) )
    raise ArgumentError, "Data size must be larger, cannot estimate k for such a small data size" if( data_size == 0 )
    # }}}

    return result
  end # def rule_of_thumb_k_estimation data_size }}}


  # @fn {def total_within_cluster_sum_of_squares closest_centroids # {{{
  # @param closest_centroids is input from the same named function
  # @returns [Array] Index being cluster id index and total within cluster sum of squares
  # Should become smaller for good clustering results
  def total_within_cluster_sum_of_squares closest_centroids

    tcss = [] # index represents cluster id
    closest_centroids.each do |cid, ed|

      if( cid.nil? )
        p closest_centroids
        exit
      end

      tcss[ cid ] = 0 if( tcss[ cid ].nil? )
      tcss[ cid ] += ( ed ** 2 )
    end

    # Some clusters are not assigned
    tcss.collect! do |cid|
      if( cid.nil? )
        0
      else
        # normalize = 1 / ( 2 * closest_centroids.length )
        # cid * normalize
        cid / closest_centroids.length
      end
    end

    # closest_centroids.each_with_index do |array, index|
    #   cid, ed = array
    #  tcss[ cid ] = tcss[ cid ] / cnts[ cid ]
    # end

    # p tcss

    return tcss
  end # of def total_within_cluster_sum_of_squares }}}


  # @fn def tss data {{{
  # total squared error sum
  # input: is from distances function ( hash)
  def tss data
    tss = 0
    cnt = 0

    # we get : data-> dists[ dindex ] << [ cindex, ed ]
    data.each_pair do |dindex, array|
      array.each do |ci, ed|
        tss += ed**2
        cnt += 1
      end
    end

    return tss / cnt
  end # }}}


  # @fn def total_sum_of_squares closest_centroids # {{{
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


  attr_reader :algorithms

end # of class Clustering }}}


# Direct Invocation
if __FILE__ == $0 # {{{

end # of if __FILE__ == $0 }}}
