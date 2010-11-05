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


require 'k_means'

class Clustering # {{{

  # Constructor
  def initialize options # {{{
    @options = options
  end # of def initialize }}}


  def kmeans data, centroids = 8
    raise ArgumentError, "Data should be of shape [ [x,y,z],...]" if( (data.length == 3) and not (data.first.length == 3 ) )

    km_tmp    = KMeans.new(data, :centroids => centroids)
    km        = eval( km_tmp.inspect.to_s )

    clusters  = Hash.new

    km.each_with_index do |cluster_array, cluster_index|
      cluster_array.each do |frame|
        clusters[ frame ] = cluster_index
      end
    end

    return clusters
  end


end # of class Clustering }}}


# Direct Invocation
if __FILE__ == $0 # {{{

end # of if __FILE__ == $0 }}}
