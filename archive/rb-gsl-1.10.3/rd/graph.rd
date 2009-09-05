=begin
= Graphics

The GSL library itself does not include any utilities to visualize computation results.
Some examples found in the GSL manual use 
((<GNU graph|URL:http://www.gnu.org/software/plotutils/plotutils.html>)) 
to show the results: the data are stored in data files, and then
displayed by using (({GNU graph})).
Ruby/GSL provides simple interfaces to (({GNU graph}))
to plot vectors or histograms directly without storing them in data files.
Although the methods described below do not cover all the functionalities 
of (({GNU graph})), these are useful to check calculations and get some 
speculations on the data.


== Plotting vectors
--- Vector.graph(y[,  options])
--- Vector.graph(nil, y[, y2, y3, ...,  options])
--- Vector.graph(x, y1, y2, ...., options)
--- Vector.graph([x1, y1], [x2, y2], ...., options)
--- GSL::graph(y[, options])
--- GSL::graph(nil, y[, y2, y3, ...,  options])
--- GSL::graph(x, y1, y2, ...., options)
--- GSL::graph([x1, y1], [x2, y2], ...., options)
    These methods use the (({GNU graph})) utility to plot vectors.
    The options ((|options|)) given by a (({String})). If (({nil})) is 
    given for (({ARGV[0]})), auto-generated abscissa are used.

    Ex:
       irb(main):007:0> require("gsl")
       irb(main):008:0> x = Vector.linspace(0, 2.0*M_PI, 20)
       irb(main):009:0> c = Sf::cos(x)
       irb(main):010:0> s = Sf::sin(x)
       irb(main):011:0> Vector.graph(x, c, s, "-T X -C -L 'cos(x), sin(x)'")

    This is equivalent to (({Vector.graph([x, c], [x, s], "-T X -C -L 'cos(x), sin(x)'")})).

    To create a PNG file,
       irb(main):011:0> Vector.graph(x, c, s, "-T png -C -L 'cos(x), sin(x)' > fig.png")

--- GSL::Vector#graph(options)
--- GSL::Vector#graph(x[, options])
    These methods plot the vector using the GNU (({graph})) 
    command. The options for the (({graph})) command are given by a (({String})).

    Ex1:  
         irb(main):011:0> x = Vector[1..5]
         [ 1.000e+00 2.000e+00 3.000e+00 4.000e+00 5.000e+00 ]
         irb(main):014:0> x.graph("-m 2")      # dotted line
         irb(main):012:0> x.graph("-C -l x")   # color, x log scale
         irb(main):015:0> x.graph("-X \"X axis\"")  # with an axis label

    Ex2: x-y plot
         irb(main):007:0> require("gsl")
         irb(main):008:0> x = Vector.linspace(0, 2.0*M_PI, 20)
         irb(main):009:0> c = Sf::cos(x)
         irb(main):010:0> c.graph(x, "-T X -C -g 3 -L 'cos(x)'")

== Drawing histogram 
--- GSL::Histogram#graph(options)
    This method uses the GNU plotutils (({graph})) to draw a histogram.

== Plotting Functions
--- GSL::Function#graph(x[, options])
    This method uses (({GNU graph})) to plot the function ((|self|)).
    The argument ((|x|)) is given by a (({GSL::Vector})) or an (({Array})).

    Ex: Plot sin(x)
         f = Function.alloc { |x| Math::sin(x) }
         x = Vector.linspace(0, 2*M_PI, 50)
         f.graph(x, "-T X -g 3 -C -L 'sin(x)'")

== Other way
The code below uses (({GNUPLOT})) directly to plot vectors.

       #!/usr/bin/env ruby
       require("gsl")
       x = Vector.linspace(0, 2*M_PI, 50)
       y = Sf::sin(x)
       IO.popen("gnuplot -persist", "w") do |io|
         io.print("plot '-'\n")
         x.each_index do |i|
           io.printf("%e %e\n", x[i], y[i])
         end
         io.print("e\n")
         io.flush
       end

It is also possible to use the Ruby Gnuplot library.
     require("gnuplot")
     require("rbgsl")
     require("gsl/gnuplot");

     Gnuplot.open do |gp|
       Gnuplot::Plot.new( gp ) do |plot|
  
         plot.xrange "[0:10]"
         plot.yrange "[-1.5:1.5]"
         plot.title  "Sin Wave Example"
         plot.xlabel "x"
         plot.ylabel "sin(x)"
         plot.pointsize 3
         plot.grid 

         x = GSL::Vector[0..10]
         y = GSL::Sf::sin(x)

         plot.data = [
           Gnuplot::DataSet.new( "sin(x)" ) { |ds|
             ds.with = "lines"
             ds.title = "String function"
             ds.linewidth = 4
           },
        
           Gnuplot::DataSet.new( [x, y] ) { |ds|
             ds.with = "linespoints"
             ds.title = "Array data"
           }
         ]

       end
     end

((<prev|URL:const.html>))

((<Reference index|URL:ref.html>))
((<top|URL:index.html>))

=end
