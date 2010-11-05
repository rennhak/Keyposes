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
  def initialize from, to # {{{
    @from, @to = from, to
  end # of initialize }}}


  # = The function eigenvalue_energy_gnuplot plots the accumulated energy of all eigenvalues to a gnuplot script.
  # @param data Array of arrays. Each sub-array contains integers or floats.
  # @param filename Accepts string which represents the full path (absolute) with filename and extension (e.g. /tmp/file.ext) of where to store the gnuplot script.
  def eigenvalue_energy_gnuplot data, filename = "/tmp/tmp.plot.gp" # {{{

    eigen_values, eigen_vectors = array_of_arrays_to_eigensystem( data ) 

    File.open( filename.to_s, "w" ) do |f|
      f.write( "reset\n" )
      f.write( "set xtics 1\n" )
      f.write( "set mxtics 0\n" )
      # f.write( "set ytics 0.1\n" )
      f.write( "set yrange [0:1]\n" )
      f.write( "set style line 1 lw 3\n" )
      f.write( "set grid\n" )
      f.write( "set border\n" )
      f.write( "set pointsize 3\n" )

      f.write( "set xlabel 'Eigenvalues (Descending order)'\n" )
      f.write( "set ylabel 'Accumulation of Energy ( 0 <= e <= 1 )'\n" )
      f.write( "set autoscale\n" )
      f.write( "set font 'arial'\n" )
      f.write( "set key left box\n" )
      f.write( "set output\n" )
      f.write( "set terminal x11 persist\n" )

      # f.write( "plot '-' w steps lw 2\n" )
      f.write( "plot '-' w lines lw 2\n" )

      # TODO: ERROR, the sum values for the energy don't add up to 1 but just slightly below due to
      # the 0-1 normalization. This is not correct. - FIXME
      # Normalize the data between 0 and 1 BUT make sure the total sum of the elements in the array is 1
      sum_of_evn  = eigen_values.to_a.dup.inject() { |result, element| result + element }
      evn         = normalize( eigen_values.to_a, 0, 1, eigen_values.to_a.min, sum_of_evn )

      sum = 0
      evn.each_index do |i|
        sum += evn[ i ]
        content = sprintf( "%e %e\n", (i + 1).to_s, sum.to_s )
        f.write( content )
      end
    end # of File.open
  end # of def interactive_gnuplot }}}


  # = The function interactive_gnuplot opens an X11 window in persist mode to view the data with the mouse.
  # @param data Accepts array of arrays. Each subarray is filled with integers or floats (needs to be uniform/of same length)
  #             Expects the data to be of form: [ [x1, y1, z1], [x2, y2, z2], ....]
  # @param data_printf Accepts a formatting instruction like printf does, e.g. "%e, %e, %e\n" etc.
  # @param labels Accepts an array containing strings with the labels for each subarray of data, e.g. %w[Foo Bar Baz]
  # @param filename Accepts string which represents the full path (absolute) with filename and extension (e.g. /tmp/file.ext)
  def interactive_gnuplot data, data_printf, labels, filename = "/tmp/tmp.plot.gp", eigen_values = nil, eigen_vectors = nil, kmeans = nil # {{{

    # raise ArgumentError, "Kmeans input can't be nil" if( kmeans.nil? )

    File.open( filename.to_s, "w" ) do |f|
      f.write( "reset\n" )
      f.write( "set ticslevel 0\n" )
      f.write( "set mxtics 2\n" )
      f.write( "set mytics 2\n" )
      f.write( "set style line 1 lw 3\n" )
      f.write( "set grid\n" )
      f.write( "set border\n" )
      f.write( "set pointsize 1\n" )

      f.write( "set xlabel '#{labels.shift.to_s}'\n" )
      f.write( "set ylabel '#{labels.shift.to_s}'\n" ) if( labels.length != 0 )
      f.write( "set zlabel '#{labels.shift.to_s}'\n" ) if( labels.length != 0 )
      f.write( "set autoscale\n" )
      f.write( "set font 'arial'\n" )
      f.write( "set key left box\n" )
      f.write( "set hidden3d\n" )
      f.write( "set output\n" )
      f.write( "set terminal x11 persist\n" )
      f.write( "set title 'Graph'\n" )

      unless( eigen_values.nil? and eigen_vectors.nil? )
        # Add information about PC axis
        # set arrow 1 from  1.9,-1.0 to 2.01,1.8
        0.upto( eigen_vectors.size1 - 1 ) do |n|
          i          = (eigen_values.to_na.to_a)[n]
          x1, y1, z1 = eigen_vectors.get_col( n ).to_a
          x2, y2, z2 = (x1*i), (y1*i), (z1*i)
          #f.write( "set arrow #{(n+1).to_s} from #{x1},#{y1},#{z1} to #{x2},#{y2},#{z2}\n" )
        end

        #f.write( "set arrow 1 from \n" )
      end


      # f.write( "splot '-' w linespoints lt 1 pt 6\n" )
      # f.write( "splot '-' using 1:2:3:4 w labels\n" )
      f.write( "splot '-' using 1:2:3:4 with points pt 5 ps 1 lt palette\n" )
      # splot '-' using 1:2:3:4 with lines lw 5 pt 5 ps 1 lt palette

      # TODO: Rewrite - this is too messy
      # Construct data array call string. We have -> data (array of arrays) but we want -> data[0][i], ... etc.
      d = []

      0.upto( data.length - 1 ) { |n| d << "data[#{n.to_s}][i]" }

      data.each_with_index do |array, index|

        #data.first.each_index do |i|
        #  nd = d.collect{|item| eval( item ).to_f }
        #  content = sprintf( data_printf.to_s, *nd ) 
        #  f.write( content )
        #end # of data.first.each_index

        f.write( array.join( " " ) + " #{kmeans[ index ].to_s} \n" )
      end # of data.each do |array|

    end # of File.open
  end # of def interactive_gnuplot }}}

  # The function covariance_matrix_gnuplot plots the cov. matrix of given data to a gnuplot script file.
  # @param data Array of arrays. Each sub-array contains integers or floats.
  # @param filename Accepts string which represents the full path (absolute) with filename and extension (e.g. /tmp/file.ext) of where to store the gnuplot script.
  def covariance_matrix_gnuplot data, filename = "/tmp/tmp.plot.gp" # {{{
    eigen_values, eigen_vectors = array_of_arrays_to_eigensystem( data ) 

    File.open( filename.to_s, "w" ) do |f|
      f.write( "reset\n" )
      #f.write( "set ticslevel 0\n" )
      f.write( "set xtics 1\n" )
      f.write( "set mxtics 0\n" )
      f.write( "set style line 1 lw 3\n" )
      f.write( "set grid\n" )
      f.write( "set border\n" )
      f.write( "set pointsize 3\n" )

      f.write( "set xlabel 'Eigenvalue (Descending order)'\n" )
      f.write( "set ylabel 'Energy'\n" )
      f.write( "set autoscale\n" )
      f.write( "set font 'arial'\n" )
      # f.write( "set key left box\n" )
      f.write( "set output\n" )
      f.write( "set terminal x11 persist\n" )

      f.write( "plot '-' w line lw 2\n" )

      eigen_values.to_a.each_index do |i|
        content = sprintf( "%e %e\n", (i + 1).to_s, eigen_values.get( i ) )
        f.write( content )
      end
    end # of File.open
  end # of def interactive_gnuplot }}}

  # Graph creates a plot and dumps it to the defined file of the arguments provided
  def graph x, y, filename = "/tmp/graph.png" # {{{
    GSL::graph([ x, y ], "-T png -C -X 'X-Values' -Y 'Y-Values' -L 'Data' -S 2 -m 0 --page-size a4 > #{filename.to_s}") 
  end # of def graph }}}


  # = The function interactive_gnuplot_eucledian_distances opens an X11 window in persist mode to view the data with the mouse.
  # @param data Accepts array of data with distances where each index is one frame (2D)
  # @param data_printf Accepts a formatting instruction like printf does, e.g. "%e, %e\n" etc.
  # @param labels Accepts an array containing strings with the labels for each subarray of data, e.g. %w[Frames Eucledian Distance Window Value]
  # @param filename Accepts string which represents the full path (absolute) with filename and extension (e.g. /tmp/file.ext)
  # @param from Accepts integer, representing the starting index of the motion sequence. 
  # @param pointsOfInterest Accepts array, containing integers. Each integer is a frame where we have a point of interest (e.g. frame of a dance master illustration drawing)
  def interactive_gnuplot_eucledian_distances data, data_printf, labels, title = "Plot", filename = "/tmp/tmp.plot.gp", data_filename = "/tmp/tmp/plot.gpdata", from = nil, pointsOfInterest = nil, pointsOfInterestRange = nil, pointsOfInterest_filename = nil, tp = nil, tp_filename = nil # {{{
    oldLabels = labels.dup

    File.open( filename.to_s, "w" ) do |f|
      f.write( "reset\n" )
      f.write( "set size 3,3\n" )
      f.write( "set ticslevel 0\n" )
      # f.write( "set style line 1 lw 3\n" )
      f.write( "set style line 2 lw 3\n" )
      f.write( "set style line 1 lt 1 lw 8 lc rgb 'blue'\n")
      f.write( "set grid\n" )
      f.write( "set border\n" )
      f.write( "set pointsize 3\n" )

      f.write( "set xrange [#{@from.to_s}:#{@to.to_s}]\n" )
      f.write( "set yrange [0:1.19]\n" )

      f.write( "set xlabel '#{labels.shift.to_s}' font \"Helvetica,60\"\n" )
      f.write( "set ylabel '#{labels.shift.to_s}' font \"Helvetica,60\"\n" )
      # f.write( "set autoscale\n" )
      f.write( "set font 'Helvetica,60'\n" )
      # f.write( "set key left box\n" )
      # # set key box outside above cente
      f.write( "set output '#{File.basename(filename, '.gp')}.eps'\n" )
      # f.write( "set terminal x11 persist\n" )
      f.write( "set terminal postscript eps enhanced color \"Helvetica\" 60\n")
      f.write( "set title '#{title}' font \"Helvetica,60\" \n" )

      if( pointsOfInterest.nil? )
        f.write( "plot '#{File.basename( data_filename )}' ti \"#{oldLabels.pop.to_s} per #{oldLabels.pop.to_s}\" w line lt 3\n" )
      else
        # ORIG; f.write( "plot '#{data_filename}' ti \"#{oldLabels.pop.to_s} per #{oldLabels.pop.to_s}\" w line lt 3, '#{pointsOfInterest_filename}' ti \"Poses from Dance Master Illustrations\" w xerrorbars lt 1 pt 7 ps 1, '#{tp_filename}' ti \"Turning poses\" w points 0 7, 'frenet_frame_kappa_plot.gpdata' ti \"Raw Curvature\" w line\n" )
        f.write( "plot '#{File.basename( data_filename )}' ti \"#{oldLabels.pop.to_s} per #{oldLabels.pop.to_s}\" w lines linestyle 1, '#{File.basename( pointsOfInterest_filename )}' ti \"Poses from Dance Master Illustrations\" w xerrorbars lt 1 pt 7 ps 4\n")
        #f.write( "plot '#{data_filename}' ti \"#{oldLabels.pop.to_s} per #{oldLabels.pop.to_s}\" w line, '#{pointsOfInterest_filename}' ti \"Poses from Dance Master Illustrations\" w xerrorbars lt 1 pt 7 ps 2, '#{tp_filename}' ti \"Turning poses\" w points 0 7, 'ekin.gpdata' ti \"Kinetic Energy\" w line, 'eucledian_distances_window_plot.gpdata' ti \"Eucledian Distance Window (speed)\" w line\n" )
        #f.write( "plot '#{data_filename}' ti \"#{oldLabels.pop.to_s} per #{oldLabels.pop.to_s}\" w line, '#{pointsOfInterest_filename}' ti \"Poses from Dance Master Illustrations\" w xerrorbars lt 1 pt 7 ps 2, '#{tp_filename}' ti \"Turning poses\" w points 0 7\n")
      end
    end # of File.open

    File.open( data_filename.to_s, "w" ) do |f|
      data.each_with_index do |d, i|
        if( from.nil? )
          f.write( "#{i.to_s} #{d.to_s}\n" )
        else
          f.write( "#{(i+from).to_s} #{d.to_s}\n" )
        end
      end # of data.each_with_index do |d,i|
    end

    unless( pointsOfInterest.nil? )
      File.open( pointsOfInterest_filename.to_s, "w" ) do |f|
        pointsOfInterest.each_with_index do |dmp, index|
            f.write( "#{dmp.to_s} #{data[dmp-@from].to_s} #{pointsOfInterestRange[index].first.to_s} #{pointsOfInterestRange[index].last.to_s}\n" )
        end # of data.each_with_index do |d,i|
      end
    end

    unless( tp.nil? )
      File.open( tp_filename.to_s, "w" ) do |f|
        tp.each do |point|
            f.write( "#{point.to_s} #{data[point-@from].to_s}\n" )
        end # of data.each_with_index do |d,i|
      end
    end


  end # of def interactive_gnuplot }}}

  def easy_gnuplot data, data_printf, labels, title = "Plot", filename = "/tmp/tmp.plot.gp", data_filename = "/tmp/tmp/plot.gpdata", from = nil, pointsOfInterest = nil, pointsOfInterestRange = nil, pointsOfInterest_filename = nil, tp = nil, tp_filename = nil # {{{
    oldLabels = labels.dup

    File.open( filename.to_s, "w" ) do |f|
      f.write( "reset\n" )
      f.write( "set ticslevel 0\n" )
      f.write( "set style line 1 lw 3\n" )
      f.write( "set grid\n" )
      f.write( "set border\n" )
      f.write( "set pointsize 1\n" )

      f.write( "set xlabel '#{labels.shift.to_s}' font \"Helvetica,20\"\n" )
      f.write( "set ylabel '#{labels.shift.to_s}' font \"Helvetica,20\"\n" )
      f.write( "set autoscale\n" )
      f.write( "set font 'Helvetica,20'\n" )
      f.write( "set key left box\n" )
      f.write( "set output\n" )
      f.write( "set terminal x11 persist\n" )
      f.write( "set title '#{title}' font \"Helvetica,20\" \n" )

      if( pointsOfInterest.nil? )
        f.write( "plot '#{File.basename( data_filename )}' ti \"#{oldLabels.pop.to_s} per #{oldLabels.pop.to_s}\" w line\n" )
      else
        f.write( "plot '#{File.basename( data_filename )}' ti \"#{oldLabels.pop.to_s} per #{oldLabels.pop.to_s}\" w line lt 3, '#{File.basename( pointsOfInterest_filename )}' ti \"Poses from Dance Master Illustrations\" w xerrorbars lt 1 pt 7 ps 1\n" )
        #f.write( "plot '#{data_filename}' ti \"#{oldLabels.pop.to_s} per #{oldLabels.pop.to_s}\" w line, '#{pointsOfInterest_filename}' ti \"Poses from Dance Master Illustrations\" w xerrorbars lt 1 pt 7 ps 2, '#{tp_filename}' ti \"Turning poses\" w points 0 7, 'ekin.gpdata' ti \"Kinetic Energy\" w line, 'eucledian_distances_window_plot.gpdata' ti \"Eucledian Distance Window (speed)\" w line\n" )
        #f.write( "plot '#{data_filename}' ti \"#{oldLabels.pop.to_s} per #{oldLabels.pop.to_s}\" w line, '#{pointsOfInterest_filename}' ti \"Poses from Dance Master Illustrations\" w xerrorbars lt 1 pt 7 ps 2, '#{tp_filename}' ti \"Turning poses\" w points 0 7\n")
      end
    end # of File.open

    File.open( data_filename.to_s, "w" ) do |f|
  
      data.each do |frame, value|
        f.write( "#{frame.to_s} #{value.to_s}\n" )
      end
    end


    unless( pointsOfInterest.nil? )
      File.open( pointsOfInterest_filename.to_s, "w" ) do |f|
        pointsOfInterest.each_with_index do |dmp, index|
            f.write( "#{dmp.to_s} 0 #{pointsOfInterestRange[index].first.to_s} #{pointsOfInterestRange[index].last.to_s}\n" )
        end # of data.each_with_index do |d,i|
      end
    end


  end # of def easy_gnuplot }}}



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

