#!/usr/bin/ruby19
#

###
#
# File: KMeans_Worker.rb
#
######


###
#
# (c) 2012, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       KMeans_Worker.rb
# @author     Bjoern Rennhak
#
# @brief      This class is a simple worker to scale over all CPU's for K-Means analysis.
#
#######


require 'rubygems'
require 'ffi-rzmq'
require 'json'


# @class      class KMeans_Worker # {{{
# @brief      Encapsulates K-Means computation
class KMeans_Worker

  # {{{
  def initialize options, logger, id, iterations, k, final

    @options  = options
    @logger   = logger
    @id       = id

    @logger.message :info, "Starting ZMQ K-Means Worker (id: #{@id.to_s}) (iterations: #{iterations.to_s})"

    context     = ZMQ::Context.new(1)

    # # Socket to receive messages on
    # receiver    = context.socket(ZMQ::PULL)
    # receiver.connect("tcp://*:5557")

    # Socket to send messages to
    sender      = context.socket(ZMQ::PUSH)
    sender.connect("tcp://*:5558")

    kms                 = []
    tmp_distortions     = []
    tmp_centroids       = []

    iterations.to_i.times do |i|

      clustering                  = Clustering.new( @options )
      kmeans, centroids           = clustering.kmeans( final, k ) # , centroids )
      kms                        << kmeans
      distances                   = clustering.distances( final, centroids ) # Hash with   hash[ data index ] =  [ [ centroid_id, eucleadian distance ], ... ] 

      closest_centroids           = clustering.closest_centroids( distances, centroids, final ) # array with subarrays of each [ centroid_id, distance ]
      distortions                 = clustering.distortions( closest_centroids )
      tcss                        = clustering.total_within_cluster_sum_of_squares( closest_centroids )

      # Serialize the centroid class instances 
      cents = []
      centroids.each { |c| cents << c.position }


      tmp_distortions << distortions
      tmp_centroids << cents

      puts "[ID: #{@id.to_s}] K-Means iteration #{i.to_s} of #{iterations.to_s} - Distortion: #{distortions.to_s}"

    end

    payload = [ kms, tmp_distortions, tmp_centroids ].to_json

    sender.send_string( payload )

  end # def initialize }}}

end # of class KMeans_Worker # }}}


# Direct invocation
if __FILE__ == $0

end

# vim:ts=2:tw=100:wm=100

