#!/usr/bin/ruby19
#

###
#
# File: KMeans_Controller.rb
#
######


###
#
# (c) 2012, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       KMeans_Controller.rb
# @author     Bjoern Rennhak
#
# @brief      This class is a simple worker to scale over all CPU's for K-Means analysis.
#
#######


require 'rubygems'
require 'ffi-rzmq'
# require 'zmq'


# @class      class KMeans_Controller # {{{
# @brief      Encapsulates K-Means computation
class KMeans_Controller

  # {{{
  def initialize logger = nil

    @logger     = logger

    @logger.message :info, "Starting ZMQ K-Means controller"

    context = ZMQ::Context.new(1)

    # Socket to send messages on
    sender = context.socket(ZMQ::PUSH)
    sender.bind("tcp://*:5557")

    # puts "Press enter when the workers are ready"
    # $stdin.read(1)
    # puts "Sending tasks to workers"

    # The first message is "0" and signals start of batch
    sender.send_string('0')

    # Send 100 tasks
    total_msec = 0 # Total expected cost in msecs
    100.times do
      @logger.message :info, "Sending time to workers"
      workload = rand(100) + 1
      total_msec += workload
      $stdout << "#{workload}."
      sender.send_string(workload.to_s)
    end

    @logger.message :info, "Total expected cost: #{total_msec.to_s} msec"
    Kernel.sleep(1) # Give 0MQ time to deliver

  end # def initialize }}}

end # of class KMeans_Controller # }}}

# vim:ts=2:tw=100:wm=100
