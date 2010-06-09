#!/usr/bin/ruby19
#

###
#
# File: KMeans_Sink.rb
#
######


###
#
# (c) 2012, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       KMeans_Sink.rb
# @author     Bjoern Rennhak
#
# @brief      This class is a simple worker to scale over all CPU's for K-Means analysis.
#
#######


require 'rubygems'
require 'ffi-rzmq'
require 'json'


# @class      class KMeans_Sink # {{{
# @brief      Encapsulates K-Means computation
class KMeans_Sink

  # {{{
  def initialize logger = nil, workers

    @logger     = logger
    @workers    = workers
    @done       = false

    @logger.message :info, "Starting ZMQ K-Means Sink to collect results from #{workers.to_s} workers"

    # Prepare our context and socket
    context = ZMQ::Context.new(1)
    receiver = context.socket(ZMQ::PULL)
    receiver.bind("tcp://*:5558")

    tstart = Time.now

    @tmp_centroids = []
    @tmp_distortions  = []
    @kms  = []

    # Process 100 confirmations
    workers.to_i.times do |task_nbr|
      message = ""
      receiver.recv_string( message )
      kms, dist, cent = *( JSON.parse( message ) )

      cent.collect! do |c|
          c.collect! do |inner|
            Centroid.new( inner )
          end
      end

      @kms.concat( kms )
      @tmp_distortions.concat( dist )
      @tmp_centroids.concat( cent )
    end

    # Calculate and report duration of batch
    tend = Time.now
    total_msec = (tend-tstart) * 1000
    @logger.message :info, "Total elapsed time: #{total_msec} msec"

    @done = true
  end # def initialize }}}


  attr        :kms, :tmp_distortions, :tmp_centroids
  attr_reader :done
end # of class KMeans_Sink # }}}

# vim:ts=2:tw=100:wm=100
