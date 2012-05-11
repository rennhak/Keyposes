#!/usr/bin/ruby19
#

###
#
# File: Frames.rb
#
######


###
#
# (c) 2009-2011, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       Frames.rb
# @author     Bjoern Rennhak
#
# @brief      This class encapsulates a cluster frame set.
#
#######


# @class      class Frames # {{{
# @brief      Encapsulates the cluster frame set into an object
class Frames

  # @fn       def initialize current_cluster, start_frame_number, start_frame_data, middle_frame_number, middle_frame_data, end_frame_number, end_frame_data # {{{
  # @brief    Custom constructor for the frames class
  #
  # @param    current_cluster
  # @param    start_frame_number
  # @param    start_frame_data
  # @param    middle_frame_number
  # @param    middle_frame_data
  # @param    end_frame_number
  # @param    end_frame_data
  def initialize current_cluster, centroid, start_frame_number, start_frame_data, middle_frame_number, middle_frame_data, end_frame_number, end_frame_data

    @current_cluster          = current_cluster

    @start_frame_number       = start_frame_number
    @start_frame_data         = start_frame_data

    @middle_frame_number      = middle_frame_number
    @middle_frame_data        = middle_frame_data

    @end_frame_number         = end_frame_number
    @end_frame_data           = end_frame_data

    @centroid                 = centroid.position

  end # of def initialize current_cluster, start_frame_number, start_frame_data, middle_frame_number, middle_frame_data, end_frame_number, end_frame_data # }}}


  attr :current_cluster, :start_frame_number, :start_frame_data, :middle_frame_number, :middle_frame_data, :end_frame_number, :end_frame_data, :centroid
end # of class Frames # }}}

# vim:ts=2:tw=100:wm=100
