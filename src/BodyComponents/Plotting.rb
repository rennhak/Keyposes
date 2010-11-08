#!/usr/bin/ruby
#

###
#
# File: Plotter.rb
#
######


###
#
# (c) 2009, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       BodyComponents.rb
# @author     Bjoern Rennhak
# @since      Wed Apr  7 19:49:27 JST 2010
# @version    0.0.1
# @copyright  See COPYRIGHT file for details.
#
#######


# Standard includes
require 'gsl'

# Custom includes
require 'Extensions.rb'

# Change Namespace
include GSL

###
#
# @class   Plotter
# @author  Bjoern Rennhak
# @brief   This class helps with generating proper graphs via the GSL library. It is a custom
#          wrapper to hide away all kind of configuration we don't care about.
# @details {}
#
#######
class Plotter # {{{
  def initialize # {{{
  end # of initialize }}}

  # = The transform function takes an arbitrary object and changes it to a GSL sane equivalent
  #   This function also takes care of nested substructures. E.g. an array in an array will become a
  #   GSL::Vector of a GSL::Vector etc.
  # @param input The data you want to GSL'ify. E.g. an array will become GSL::Vector etc.
  # @param fromType If empty the type is guessed. If something is given a conversion is forced. This
  #                 is the type we will input. e.g. "Array" or "String" => Object.class output
  # @param toType If empty the type is guessed. If something is given a conversion is forced. This
  #               is the type we will convert the input to. e.g. "GSL::Vector" etc.
  # @returns An array in this form: [ inputType, outputType, output ]
  def transform input, fromType = nil, toType = nil
    result    = []
    fT, tT    = "", ""

    # 1.) Input Verification
    if( fromType.nil? )
      
    else
      # fromType is not nil, what do we have?
    end

    if( toType.nil? )

    else
      # toType is not nil, what do we have?

    end

    result
  end

end # of class Plotter # }}}

