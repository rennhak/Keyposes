#!/usr/bin/ruby

require 'rubygems'
     require("gsl")
include GSL
     include GSL::Fit

     n = 4
     x = Vector.alloc(2010, 1980, 1990, 2000)
     y = Vector.alloc(12, 11, 14, 13)
     w = Vector.alloc(0.5, 0.2, 0.3, 0.4)

     #for i in 0...n do
     #   printf("%e %e %e\n", x[i], y[i], 1.0/Math::sqrt(w[i]))
     #end

     c0, c1, cov00, cov01, cov11, chisq = wlinear(x, w, y)

p "x"
p x
p "y"
p y
p "w"
p w

     printf("# best fit: Y = %g + %g X\n", c0, c1);
     printf("# covariance matrix:\n");
     printf("# [ %g, %g\n#   %g, %g]\n",
             cov00, cov01, cov01, cov11);
     printf("# chisq = %g\n", chisq);

