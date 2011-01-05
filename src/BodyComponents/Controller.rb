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

# Make sure require relative works for all ruby VM's
# FIXNE: Why is it not enough to have this in Extensions.rb?
unless Kernel.respond_to?(:require_relative)
  module Kernel
    def require_relative(path)
      # puts 'IN NEW REQUIRE_RELATIVE ' + path.to_s
      require File.join(File.dirname(caller[0]), path.to_str)
    end
  end
end


# OptionParser related
require 'optparse'
require 'optparse/time'
require 'ostruct'
require 'pp'

# Standard includes
require 'rubygems'
require 'narray'
require 'gsl'

# Profiler
require 'ruby-prof'

# Custom includes (changes object behaviors)
require 'Extensions.rb'

# From MotionX - FIXME: Use MotionX's XYAML interface
require 'ADT.rb'

# Local includes
require_relative 'Mathematics.rb'
require_relative 'Physics.rb'

require_relative 'PCA.rb'
require_relative 'Turning.rb'
require_relative 'Filter.rb'

require_relative 'Plotter.rb'
require_relative 'PoseVisualizer.rb'
require_relative 'Logger.rb'


# Change Namespace
include GSL

# }}}

class Controller # {{{

  # @fn       def initialize options = nil # {{{
  # @brief    Constructor of the controller class
  #
  # @param    [OpenStruct]      options     Options OpenStruct processed by the parse_cmd_arguments function
  def initialize options = nil

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
    @motions                      = OpenStruct.new  # store all results here for list etc.

    @config_names                 = []
    @names                        = []
    @domains                      = []
    @patterns                     = []
    @speeds                       = []
    @cycles                       = []
    @fname_table                  = Hash.new

    # Store all components here
    @yamls                        = Dir.glob( File.join( "**", "*.yaml" ) ).collect { |i| i.split( "/" ) }
    @yamls.each do |configurations_dir, domain, name, pattern, speed, cycle, filename|

      # To resolve ambiguiuity between same name/speed/cycle but different mocap data we use the config name of the yaml
      yaml_cf = read_motion_config( "#{configurations_dir}/#{domain}/#{name}/#{pattern}/#{speed}/#{cycle}/#{filename.to_s}" )
      yaml    = yaml_cf.name.gsub( " ", "_" ).gsub( "-", "_" )

      eval( "@motions.#{domain}                                                                 = OpenStruct.new if( @motions.#{domain}.nil? )" )
      eval( "@motions.#{domain}.#{name}                                                         = OpenStruct.new if( @motions.#{domain}.#{name}.nil? )" )
      eval( "@motions.#{domain}.#{name}.#{pattern}                                              = OpenStruct.new if( @motions.#{domain}.#{name}.#{pattern}.nil? )" )
      eval( "@motions.#{domain}.#{name}.#{pattern}.speed_#{speed}                               = OpenStruct.new if( @motions.#{domain}.#{name}.#{pattern}.speed_#{speed}.nil? )" )
      eval( "@motions.#{domain}.#{name}.#{pattern}.speed_#{speed}.cycle_#{cycle}                = OpenStruct.new if( @motions.#{domain}.#{name}.#{pattern}.speed_#{speed}.cycle_#{cycle}.nil? )" )
      eval( "@motions.#{domain}.#{name}.#{pattern}.speed_#{speed}.cycle_#{cycle}.yaml_#{yaml}   = OpenStruct.new if( @motions.#{domain}.#{name}.#{pattern}.speed_#{speed}.cycle_#{cycle}.yaml_#{yaml}.nil? )" )


      eval( "@motions.#{domain}.#{name}.#{pattern}.speed_#{speed}.cycle_#{cycle}.yaml_#{yaml}.filename     = '#{filename.to_s}'" )
      eval( "@motions.#{domain}.#{name}.#{pattern}.speed_#{speed}.cycle_#{cycle}.yaml_#{yaml}.path         = '#{configurations_dir}/#{domain}/#{name}/#{pattern}/#{speed}/#{cycle}'" )
      eval( "@motions.#{domain}.#{name}.#{pattern}.speed_#{speed}.cycle_#{cycle}.yaml_#{yaml}.loaded_yaml  = yaml_cf" )

      @fname_table[ filename ] = yaml    # filename = yaml[name]

      @config_names   << yaml       unless( @config_names.include?( yaml    ) )
      @domains        << domain     unless( @domains.include?(      domain  ) )
      @names          << name       unless( @names.include?(        name    ) )
      @patterns       << pattern    unless( @patterns.include?(     pattern ) )
      @speeds         << speed      unless( @speeds.include?(       speed   ) )
      @cycles         << cycle      unless( @cycles.include?(       cycle   ) )
    end

    @configurations               = Dir[ "#{@config.config_dir}/*.yaml" ].collect { |d| d.gsub( "#{@config.config_dir}/", "" ).gsub( ".yaml", "" ) }
    @sides                        = %w[left right both]
    @body_parts                   = %w[hands fore_arms upper_arms thighs shanks feet]

    @clustering                   = Clustering.new( @options )
    @clustering_algorithms        = @clustering.algorithms


    unless( options.nil? )
      @log.message :success, "Starting #{__FILE__} run"
      @log.message :debug,   "Colorizing output as requested" if( @options.colorize )
      @log.message :info,    "Processing the following sides: ''#{@options.side.to_s}''"

      RubyProf.start if( @options.profiling )

      ####
      # Main Control Flow
      ##########

      if( @options.use_all_of_domain ) # if this is given we want to summarize all the dances of this domain
          # We mix only the same domain with the same speed
          %w[domain speed].each { |i| raise ArgumentError, "You didn't provide a #{i} via CLI!" if( eval( "@options.#{i} == \"\"" ) ) }

          # If we want to match more specific inside the domain
          extended = false
          if( ( @options.pattern != "" ) && ( @options.name != "" ) )
            extended = true
          end

          one = false
          one = true if( @options.yaml != "" )

          process = []
          @yamls.each do |configurations_dir, domain, name, pattern, speed, cycle, filename|

            if( extended )
              if( one )
                if( ( domain =~ %r{#{@options.domain}}i ) and ( speed =~ %r{#{@options.speed}}i ) and ( pattern =~ %r{#{@options.pattern}}i ) and ( name =~ %r{#{@options.name}}i ) and ( filename.gsub( ".yaml","").gsub( "_-_","___") =~ %r{#{@options.yaml}}i) )
                  @log.message :info, "USING Domain( '#{domain.to_s}' ), name( '#{name}' ), pattern( '#{pattern}' ), speed( '#{speed.to_s}' ), cycle( '#{cycle.to_s}' ), filename( '#{filename.to_s}' )"
                  process << [ configurations_dir, domain, name, pattern, speed, cycle, filename ] 
                end
              else
                if( ( domain =~ %r{#{@options.domain}}i ) and ( speed =~ %r{#{@options.speed}}i ) and ( pattern =~ %r{#{@options.pattern}}i ) and ( name =~ %r{#{@options.name}}i ) )
                  @log.message :info, "USING Domain( '#{domain.to_s}' ), name( '#{name}' ), pattern( '#{pattern}' ), speed( '#{speed.to_s}' ), cycle( '#{cycle.to_s}' ), filename( '#{filename.to_s}' )"
                  process << [ configurations_dir, domain, name, pattern, speed, cycle, filename ] 
                end
              end
            else
              if( ( domain =~ %r{#{@options.domain}}i ) and ( speed =~ %r{#{@options.speed}}i ) )
                @log.message :info, "USING Domain( '#{domain.to_s}' ), name( '#{name}' ), pattern( '#{pattern}' ), speed( '#{speed.to_s}' ), cycle( '#{cycle.to_s}' ), filename( '#{filename.to_s}' )"
                process << [ configurations_dir, domain, name, pattern, speed, cycle, filename ] 
              end
            end # of extended 
          end

          turning_data  = []
          @adts         = []

          process.each do |configurations_dir, domain, name, pattern, speed, cycle, filename|

            yaml_var = @fname_table[ filename ]
            @log.message :success, "Using domain '#{domain}' with process '#{name}' with pattern '#{pattern}', speed '#{speed}' and cycle '#{cycle}' (YAML: '#{yaml_var}')"
            motion_config             = eval( "@motions.#{domain}.#{name}.#{pattern}.speed_#{speed}.cycle_#{cycle}.yaml_#{yaml_var}" )

            raise ArgumentError, "The configuration and/or the data you requested doesn't exist!" if( motion_config.nil? )

            motion_config_filename    = motion_config.path + "/" + motion_config.filename

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
              @filter                 = Filter.new( @options, @from, @to )
              @adt                    = @filter.filter_motion_capture_data( @adt )
            end

            if( @options.turning_pose_extraction )

              if( @options.each_limb_individually )
                # This option will cause e.g. --part fore_arms --part upper_arms -> to be processed
                # separaely to yield separate t-data and will then get added together into one large
                # array for e.g. clustering. This allows the mixing of all part t-data's.
                @log.message :info, "All given limbs (--part) will be treated separately for T-Data extraction and summed up."


                given_body_parts = @options.body_parts.dup    # store for later reuse
                given_body_parts.each do |part|               # iterate over each limb, reset @options.body_parts to only one limb and calculate

                  @log.message :info, "Calculating T-Data for #{part.to_s}"
                  @options.body_parts = [ part ]

                  @log.message :info, "Performing CPA-PCA Turning pose extraction"
                  @turning                = Turning.new( @options, @adt, @dance_master_poses, @dance_master_poses_range, @from, @to )
                  data                    = @turning.get_data

                  turning_data << [ [ configurations_dir, domain, name, pattern, speed, cycle, filename ], data ]

                  meta = Hash.new
                  meta[ "total_frames" ]  = @adt.relb.getCoordinates!.length
                  meta[ "from" ]          = @from
                  meta[ "to" ]            = @to
                  meta[ "motion_config" ] = @motion_config

                  @log.message :info, "Summing up T-Data for #{part.to_s}"
                  @adts << [ @adt, turning_data.dup, meta.dup ]

                end # of given_body_parts.each do |part|

              else # of if( @options.each_limb_individually )
                @log.message :info, "All given limbs (--part) will get unified together"
                @log.message :info, "Performing CPA-PCA Turning pose extraction"
                @turning                = Turning.new( @options, @adt, @dance_master_poses, @dance_master_poses_range, @from, @to )
                data                    = @turning.get_data

                turning_data << [ [ configurations_dir, domain, name, pattern, speed, cycle, filename ], data ]

                meta = Hash.new
                meta[ "total_frames" ]  = @adt.relb.getCoordinates!.length
                meta[ "from" ]          = @from
                meta[ "to" ]            = @to
                meta[ "motion_config" ] = @motion_config

                @adts << [ @adt, turning_data.dup, meta.dup ]

              end # of if( @options.each_limb_individually )
            end # of if( @options.turning_pose_extraction )

            @log.message :success, "Finished processing of #{motion_config_filename.to_s}"

        end # of process.each do |configurations_dir, domain, name, pattern, speed, cycle, filename| 

        final           = []
        turning_data.collect!{ |description, data| data }.each { |array| final.concat( array ) }

        ks              = []
        kms             = []
        total_squared   = []
        dists           = []
        tcss            = []

        @log.message :success, "Merged all data - doing Clustering on all combined data"
        @log.message :info, "We have #{final.length.to_s} data points, rule of thumb says we should use #{Clustering.new.rule_of_thumb_k_estimation(final.length.to_i)} (large overestimation)"

        if( @options.clustering_k_search )
          ( @options.clustering_k_from ).upto( @options.clustering_k_to ) do |k|  # iterate over k's

            @log.message :info, "Performing K-Means for k = #{k.to_s}"

            clustering                  = Clustering.new( @options )
            kmeans, centroids           = clustering.kmeans( final, k ) # , centroids )
            kms                        << kmeans
            distances                   = clustering.distances( final, centroids ) # Hash with   hash[ data index ] =  [ [ centroid_id, eucleadian distance ], ... ] 
            closest_centroids           = clustering.closest_centroids( distances, centroids, final ) # array with subarrays of each [ centroid_id, distance ]
            distortions                 = clustering.distortions( closest_centroids )
            squared_error_distortions   = clustering.squared_error_distortion( closest_centroids )
            dists << squared_error_distortions
            ks << k
            tcss                        << clustering.total_within_cluster_sum_of_squares( closest_centroids )

          end # of ( @options.clustering_k_from ).upto( @options.clustering_k_to ) do |k|
        else

          unless( @options.clustering_k_parameter.nil? )
            k                           = @options.clustering_k_parameter.to_i

            @log.message :info, "Performing K-Means for k = #{k.to_s}"

            clustering                  = Clustering.new( @options )
            kmeans, centroids           = clustering.kmeans( final, k ) # , centroids )
            kms                        << kmeans
            distances                   = clustering.distances( final, centroids ) # Hash with   hash[ data index ] =  [ [ centroid_id, eucleadian distance ], ... ] 

            @closest_distance = []
            @closest_frame    = []
            distances.each_pair do |frame, array|
              array.each do |cluster_id, distance|
                if( @closest_distance[ cluster_id ].nil? )
                  @closest_distance[ cluster_id ] = distance 
                  @closest_frame[ cluster_id ] = frame
                end

                if( @closest_distance[ cluster_id ] > distance )
                  @closest_distance[ cluster_id ] = distance 
                  @closest_frame[ cluster_id ] = frame 
                end
              end
            end

            closest_centroids           = clustering.closest_centroids( distances, centroids, final ) # array with subarrays of each [ centroid_id, distance ]
            distortions                 = clustering.distortions( closest_centroids )
            squared_error_distortions   = clustering.squared_error_distortion( closest_centroids )
            dists << squared_error_distortions
            ks << k
            tcss                        << clustering.total_within_cluster_sum_of_squares( closest_centroids )
          end # unless( @options.clustering_k_parameter.nil? ) 

        end # of if( @options.clustering_k_search )

        tcss.collect! { |array| array.inject(:+) / array.length } 
        ks_within     = ks.zip( tcss )
        ks_dists      = ks.zip( dists )

        @plot         = Plotter.new( 0, 0 )
        @plot.easy_gnuplot( ks_dists,  "%e %e\n", [ "Clusters", "Total distortions" ], "Total distortions Plot", "graphs/total_distortion.gp", "graphs/total_distortion.gpdata" )
        @plot.easy_gnuplot( ks_within, "%e %e\n", [ "Clusters", "Total within cluster sum of squares" ], "Total within cluster sum of squares Plot", "graphs/total_within_sum_of_squares.gp", "graphs/total_within_sum_of_squares.gpdata" )

        @turning.get_dot_graph( kms.last )
        @plot.interactive_gnuplot( final, "%e %e %e\n", %w[X Y Z],  "graphs/all_domain_plot.gp", nil, nil, kms.last )

        if( @options.pose_visualizer )
          @pv         = PoseVisualizer.new( @options, kms.last, @adts, @closest_frame )
        end

      else # if this is given we want to analyse only one dance
        @log.message :error, "No processing name given via --name '#{@options.process}'" if( @options.process == "" )

        unless( @options.process == "" )

          %w[domain name pattern speed cycle].each { |i| raise ArgumentError, "You didn't provide a #{i} via CLI!" if( eval( "@options.#{i} == \"\"" ) ) }
          @log.message :success, "Using domain #{@options.domain} with process #{@options.process} with pattern #{@options.pattern}, speed #{@options.speed} and cycle #{@options.cycle} (YAML: #{@options.yaml})"
          motion_config             = eval( "@motions.#{@options.domain}.#{@options.process}.#{@options.pattern}.speed_#{@options.speed}.cycle_#{@options.cycle}.yaml_#{@options.yaml}" )

          raise ArgumentError, "The configuration and/or the data you requested doesn't exist!" if( motion_config.nil? )

          motion_config_filename    = motion_config.path + "/" + motion_config.filename

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
            @filter                 = Filter.new( @options, @from, @to )
            @adt                    = @filter.filter_motion_capture_data( @adt )
          end

          if( @options.turning_pose_extraction )
            @log.message :info, "Performing CPA-PCA Turning pose extraction"
            @turning                = Turning.new( @options, @adt, @dance_master_poses, @dance_master_poses_range, @from, @to )
            turning_data = @turning.get_data
          end

          @log.message :success, "Finished processing of #{motion_config_filename.to_s}"
        end # of unless( @options.process.empty? )
      end # of if( @options.use_all_of_domain )


      if( @options.profiling )
        results = RubyProf.stop
        # printer = RubyProf::GraphPrinter.new(result)
        # printer.print(STDOUT, 0)

        File.open "tmp/profile-graph.html", 'w' do |file|
          RubyProf::GraphHtmlPrinter.new(results).print(file)
        end

        File.open "tmp/profile-flat.txt", 'w' do |file|
          RubyProf::FlatPrinter.new(results).print(file)
        end

        File.open "tmp/profile-tree.prof", 'w' do |file|
          RubyProf::CallTreePrinter.new(results).print(file)
        end
      end

    end # of unless( options.nil? )

  end # of def initialize }}}


  # @fn       def parse_cmd_arguments( args ) # {{{
  # @brief    The function 'parse_cmd_arguments' takes a number of arbitrary commandline arguments and parses
  #           them into a proper data structure via optparse
  #
  # @param    [Array]         args  Ruby's STDIN.ARGS from commandline
  # @returns  [OptionParser]        Ruby optparse package options hash object
  def parse_cmd_arguments( args )

    options                                 = OpenStruct.new

    # Define default options
    options.verbose                         = false
    options.colorize                        = false
    options.process                         = ""
    options.turning_pose_extraction         = false
    options.filter_motion_capture_data      = false
    options.boxcar_filter                   = nil
    options.boxcar_filter_default           = 15
    options.body_parts                      = []
    options.use_raw_data                    = false
    options.filter_point_window_size        = 20
    options.filter_polyomial_order          = 5
    options.profiling                       = false
    options.model                           = 12
    options.side                            = "both"
    options.cycle                           = ""
    options.pattern                         = ""
    options.speed                           = ""
    options.yaml                            = ""
    options.domain                          = ""
    options.use_all_of_domain               = false
    options.clustering_algorithm            = "kmeans"
    options.clustering_k_parameter          = 0
    options.clustering_k_search             = false # if this is true options.clustering_k_{from, to} are used
    options.clustering_k_from               = 1
    options.clustering_k_to                 = 1
    options.pose_visualizer                 = false
    options.each_limb_individually          = false

    pristine_options                        = options.dup

    opts                                    = OptionParser.new do |opts|
      opts.banner                           = "Usage: #{__FILE__.to_s} [options]"

      opts.separator ""
      opts.separator "General options:"

      # Boolean switch.
      opts.on("-t", "--turning-pose-extraction", "Performs a dance master pose extraction (Turning poses: CPA-PCA method)") do |t|
        options.turning_pose_extraction     = t
      end

      opts.on("-f", "--filter-motion-capture-data OPT OPT2", "Filter the motion capture data against outliers before proceeding with other calculations (smoothing) with a polynomial of the order OPT with point window size OPT2 (e.g. \"5 20\")") do |f|
        data = f.split( " " )
        raise ArgumentError, "Needs at least two arguments provided enclosed by \"\"'s, eg. \"5 20\" for order 5 and 20 points" unless( data.length == 2 )
        options.filter_motion_capture_data                               = true
        data.collect! { |i| i.to_i }
        options.filter_polyomial_order, options.filter_point_window_size = *data
      end

      opts.on( "-b", "--box-car-filter OPT", "Filter curvature result through a Finite Impulse Response (FIR) Boxcar filter of order N (#{options.boxcar_filter_default.to_s})" ) do |b|
        options.boxcar_filter = b
      end

      opts.on("-p", "--parts OPT", @body_parts, "Proces one or more body parts during the computation (OPT: #{@body_parts.sort.join(", ")})" ) do |p|
        options.body_parts << p
      end

      opts.on("-o", "--orientation OPT", @sides, "Choose which side to process (OPT: #{@sides.sort.join(", ")}) - Default: #{options.side.to_s}" ) do |s|
        options.side = s
      end

      opts.on("-m", "--model OPT", "Determine how many components the body model has 1 (one big component), 4 (two arms/legs), 8 (with upper/lower arms/legs), 12 (with hands/feet)" ) do |m|
        options.model = m
      end

      opts.on("-p", "--pattern OPT", @patterns, "Determine which pattern the dance motions have from cycle to cycle (e.g. #{@patterns.sort.join(", ")})" ) do |p|
        options.pattern = p
      end

      opts.on("-z", "--cycle NUM", @cycles, "Determine which dance cycle to use (e.g. #{@cycles.sort.join(", ")} - Default: 001)" ) do |z|
        options.cycle = z
      end

      opts.on("-s", "--speed NUM", @speeds, "Determine which speed to use (#{@speeds.sort.join(", ")} - Default: 100)" ) do |z|
        options.speed = z
      end

      opts.on("-y", "--yaml OPT", @config_names, "Determine which dance to use based on the YAML config name tag (e.g. #{@config_names.sort.join(", ")})" ) do |y|
        options.yaml = y
      end

      opts.on("-d", "--domain OPT", @domains, "Determine which domain to use (e.g. #{@domains.sort.join(", ")})" ) do |d|
        options.domain = d
      end

      opts.on("-a", "--all", "Use all dances of the given domain") do |a|
        options.use_all_of_domain  = a
      end

      opts.on("-e", "--each-limb-individually", "Calculate each limb individually when extracting T-Data. If this option is not set all given components get unified by PCA together.") do |a|
        options.each_limb_individually = a
      end


      opts.on("-g", "--clustering-algorithm OPT", @clustering_algorithms, "Choose which clustering algorithm to apply (e.g. #{@clustering_algorithms.sort.join(", ")} - default: #{options.clustering_algorithm})") do |g|
        options.clustering_algorithm  = g
      end

      opts.on("-k", "--clustering-k-parameter OPT", "Choose which clustering model you want to apply (parameter k, e.g. 1, 2, 3, ... etc.)") do |k|
        options.clustering_k_parameter = k
      end

      opts.on( "--visualize", "Pose Visualizer" ) do |p|
        options.pose_visualizer = p
      end

      opts.on("--clustering-k-search-from-to OPT1 OPT2", "Run clustering for OPT1 to OPT2 and make appropriate distortion graphs (e.g. \"1 25\")") do |f|
        data = f.split( " " )
        raise ArgumentError, "Needs at least two arguments provided enclosed by \"\"'s, eg. \"1 25\" for from k=1 to k=25 iteration" unless( data.length == 2 )
        options.clustering_k_search   = true
        data.collect! { |i| i.to_i }
        options.clustering_k_from, options.clustering_k_to       = *data
      end

      opts.on("-r", "--raw-data", "Use raw data for PCA reduction instead of CPA data") do |r|
        options.use_raw_data  = r
      end

      opts.separator ""
      opts.separator "Specific options:"

      # Set of arguments
      opts.on("-n", "--name OPT", @names, "Name of motion capture data to be processed (OPT: #{ @names.sort.join(', ') })" ) do |d|
        options.process = d
      end

      opts.on("-l", "--list", "List avaialble motion capture data with pattern, cycles, speed, etc." )  do |l| 
        options.list        = l
        puts "\nYou can choose from the following configuration files\n\n"
        @yamls.each do |configurations_dir, domain, name, pattern, speed, cycle, filename|
          printf( "Domain (--domain): %-20s  Name (--name): %-20s  Pattern (--pattern): %-10s  Speed (--speed): %-4s   Cycle (--cycle): %-4s  YAML Config name (--yaml): %-4s   \n", domain, name, pattern, speed, cycle, @fname_table[ filename ] )
        end
        puts "\n"
        exit
      end

      opts.on("-v", "--verbose", "Run verbosely")                                                       { |v| options.verbose     = v           }
      opts.on("-q", "--quiet", "Run quietly, don't output much")                                        { |v| options.quiet       = q           }
      opts.on("--profiler", "Run profiler alongside the code (see results in tmp/)")                    { |p| options.profiling   = p           }


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


  # @fn       def read_motion_config filename # {{{
  # @brief    Reads a yaml config describing the motion file
  #
  # @param    [String]      filename    String, representing the filename and path to the config file
  # @returns  [OpenStruct]              Returns an openstruct containing the contents of the YAML read config file (uses the feature of Extension.rb)
  def read_motion_config filename

    # Pre-condition check
    raise ArgumentError, "Filename argument should be of type string, but it is (#{filename.class.to_s})" unless( filename.is_a?(String) )

    # Main
    result = File.open( filename, "r" ) { |file| YAML.load( file ) }                 # return proc which is in this case a hash

    # Post-condition check
    raise ArgumentError, "The function should return an OpenStruct, but instead returns a (#{result.class.to_s})" unless( result.is_a?( OpenStruct ) )

    result
  end # }}}


  # @fn       def learn method, code # {{{
  # @brief    Dynamical method creation at run-time
  #
  # @param    [String]   method    Takes the method header definition
  # @param    [String]   code      Takes the body of the method
  def learn method, code
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
