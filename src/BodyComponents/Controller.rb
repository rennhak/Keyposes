#!/usr/bin/ruby
#

###
#
# File: Controller.rb
#
######


###
#
# (c) 2009-2011, Copyright, Bjoern Rennhak, The University of Tokyo
#
# @file       Controller.rb
# @author     Bjoern Rennhak
#
#######


# Libraries {{{

# OptionParser related
require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

# Standard includes
require 'rubygems'
require 'narray'
require 'gsl'

# Custom includes (changes object behaviors)
require 'Extensions.rb'

# From MotionX - FIXME: Use MotionX's XYAML interface
require 'ADT.rb'

# Local includes
require 'PCA.rb'
require 'Physics.rb'
require 'Mathematics.rb'
require 'Turning.rb'
require 'Plotter.rb'
require 'Logger.rb'

# Change Namespace
include GSL

# }}}

class Controller # {{{

  # Constructor of the controller class
  def initialize options = nil # {{{

    @options = options

    @log     = Logger.new( @options )

    # Minimal configuration
    @config                       = OpenStruct.new
    @config.os                    = "Unknown"
    @config.platform              = "Unknown"
    @config.build_dir             = "build"
    @config.encoding              = "UTF-8"
    @config.archive_dir           = "archive"
    @config.config_dir            = "configurations"
    @config.cache_dir             = "cache"

    # Determine which configs are available
    @configurations       = Dir[ "#{@config.config_dir}/*.yaml" ].collect { |d| d.gsub( "#{@config.config_dir}/", "" ).gsub( ".yaml", "" ) }

    unless( options.nil? )
      @log.message :success, "Starting #{__FILE__} run"
      @log.message :debug,    "Colorizing output as requested" if( @options.colorize )

      ####
      # Main Control Flow
      ##########

      # Reuse if desired
      use_cache     if( @options.cache )

      unless( @options.process.empty? )
        @options.process.each do |motion_config_file|
          motion_config_filename    = @config.config_dir + "/" + motion_config_file + ".yaml"
          @log.message :info, "Loading Motion Capture config file (#{motion_config_filename})"

          @motion_config            = read_motion_config( motion_config_filename )

          @file                     = @motion_config.filename
          @from                     = @motion_config.from
          @to                       = @motion_config.to
          @name                     = @motion_config.name
          @dmps                     = @motion_config.dmp

          @dance_master_poses       = []
          @dance_master_poses_range = []
          @dmps.each { |dmp_array| @dance_master_poses << dmp_array.first; @dance_master_poses_range << dmp_array.last }

          @log.message :info, "Loading the Motion Capture data (#{@file}) via the MotionX VPM Plugin"
          @adt                      = ADT.new( @file )

          if( @options.filter_motion_capture_data )
            @log.message :info, "Filter Motion Capture data to smooth out outliers"
            @filter                 = Filter.new
            @adt = @filter.filter_motion_capture_data( @adt )
          end

          if( @options.turning_pose_extraction )
            @log.message :info, "Performing CPA-PCA Turning pose extraction"
            @turning                = Turning.new( @options, @adt, @dance_master_poses, @dance_master_poses_range, @from, @to )
            @turning.get_data
          end

          ## b0rked! Singleton methods - but where??! (?? http://doc.okkez.net/191/view/method/Object/i/initialize_copy )
          ## Speedup by loading a Marshalled object from /tmp/ if previously run
          #if File.exist?( "/tmp/Controller_Marshall_VPM_Data.tmp" )
          #  puts "Loading Marshal dump I found in /tmp/Controller_Marshall_VPM_Data.tmp for speedup"
          #  vpm = Marshal.load( File.read("/tmp/Controller_Marshall_VPM_Data.tmp").readlines.to_s )
          #else
          #  vpm   = ADT.new( file )
          #  x = vpm.deep_clone.to_s

          #  puts "Creating Marshal dump for later speedups (/tmp/Controller_Marshall_VPM_Data.tmp)"
          #  o = Marshal.dump( x )
          #  File.open( "/tmp/Controller_Marshall_VPM_Data.tmp", File::CREAT|File::TRUNC|File::RDWR, 0644) { |f| f.write( o.to_s ) }
          #end

          # p vpm.segments
          # See shiratori thesis page 132
          #

          @log.message :success, "Finished processing of #{motion_config_filename.to_s}"
        end # of @options.process.each
      end # of unless( @options.process.empty? )


    end # of unless( options.nil? )

  end # of def initialize }}}


  # The function 'parse_cmd_arguments' takes a number of arbitrary commandline arguments and parses them into a proper data structure via optparse
  #
  # @param    [Array]         args  Ruby's STDIN.ARGS from commandline
  # @returns  [OptionParser]        Ruby optparse package options hash object
  def parse_cmd_arguments( args ) # {{{

    options                                 = OpenStruct.new

    # Define default options
    options.verbose                         = false
    options.colorize                        = false
    options.process                         = []
    options.turning_pose_extraction         = false
    options.filter_motion_capture_data      = false

    pristine_options                        = options.dup

    opts                                    = OptionParser.new do |opts|
      opts.banner                           = "Usage: #{__FILE__.to_s} [options]"

      opts.separator ""
      opts.separator "General options:"

      # Boolean switch.
      opts.on("-t", "--turning-pose-extraction", "Performs a dance master pose extraction (Turning poses: CPA-PCA method)") do |t|
        options.turning_pose_extraction     = t
      end

      opts.on("-f", "--filter-motion-capture-data", "Filter the motion capture data against outliers before proceeding with other calculations (smoothing)") do |f|
        options.filter_motion_capture_data  = f
      end

      opts.separator ""
      opts.separator "Specific options:"

      # Set of arguments
      opts.on("-p", "--process OPT", @configurations, "Process one or more detected configuration (OPT: #{ @configurations.sort.join(', ') })" ) do |d|
        options.process << d
      end

      # Boolean switch.
      opts.on("-v", "--verbose", "Run verbosely") do |v|
        options.verbose = v
      end

      # Boolean switch.
      opts.on("-q", "--quiet", "Run quietly, don't output much") do |v|
        options.verbose = v
      end

      opts.separator ""
      opts.separator "Common options:"

      # Boolean switch.
      opts.on("-c", "--colorize", "Colorizes the output of the script for easier reading") do |c|
        options.colorize = c
      end

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

      # Another typical switch to print the version.
      opts.on_tail("--version", "Show version") do
        puts OptionParser::Version.join('.')
        exi.sortt
      end
    end

    opts.parse!(args)

    # Show opts if we have no cmd arguments
    if( options == pristine_options )
      puts opts
      puts ""
    end

    options
  end # of parse_cmd_arguments }}}


  # Reads a yaml config describing the motion file
  #
  # @param    [String]      filename    String, representing the filename and path to the config file
  # @returns  [OpenStruct]              Returns an openstruct containing the contents of the YAML read config file (uses the feature of Extension.rb)
  def read_motion_config filename # {{{

    # Pre-condition check
    raise ArgumentError, "Filename argument should be of type string, but it is (#{filename.class.to_s})" unless( filename.is_a?(String) )

    # Main
    result = File.open( filename, "r" ) { |file| YAML.load( file ) }                 # return proc which is in this case a hash

    # Post-condition check
    raise ArgumentError, "The function should return an OpenStruct, but instead returns a (#{result.class.to_s})" unless( result.is_a?( OpenStruct ) )

    result
  end # }}}


  # Dynamical method creation at run-time
  #
  # @param [String]   method    Takes the method header definition
  # @param [String]   code      Takes the body of the method
  def learn method, code # {{{
      eval <<-EOS
          class << self
              def #{method}; #{code}; end
          end
      EOS
  end # end of learn( method, code ) }}}

  attr_accessor :adt
end # of class Controller }}}


# Direct Invocation
if __FILE__ == $0 # {{{
  options = Controller.new.parse_cmd_arguments( ARGV )
  bc      = Controller.new( options )
end # of if __FILE__ == $0 }}}

# vim=ts:2
