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


class Frames

  def initialize current_cluster, start_frame_number, start_frame_data, middle_frame_number, middle_frame_data, end_frame_number, end_frame_data

    @current_cluster          = current_cluster

    @start_frame_number       = start_frame_number
    @start_frame_data         = start_frame_data

    @middle_frame_number      = middle_frame_number
    @middle_frame_data        = middle_frame_data

    @end_frame_number         = end_frame_number
    @end_frame_data           = end_frame_data

  end


  attr :current_cluster, :start_frame_number, :start_frame_data, :middle_frame_number, :middle_frame_data, :end_frame_number, :end_frame_data
end 
