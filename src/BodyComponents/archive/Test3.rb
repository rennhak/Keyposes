#!/usr/bin/ruby

# http://www.mail-archive.com/help-gsl@gnu.org/msg00764.html

require 'rubygems'
require 'gsl'

include GSL
include GSL::MultiFit

Rng.env_setup()

 r = GSL::Rng.alloc(Rng::DEFAULT)
 n = 19
 dim = 3
 X = Matrix.alloc(n, dim)
 y = Vector.alloc(n)
 w = Vector.alloc(n)

 a = 0.1
 for i in 0...n
   y0 = Math::exp(a)
   sigma = 0.1*y0
   val = r.gaussian(sigma)
   X.set(i, 0, 1.0)
   X.set(i, 1, a)
   X.set(i, 2, a*a)
   y[i] = y0 + val
   w[i] = 1.0/(sigma*sigma)
   printf("%g %g %g\n", a, y[i], sigma)
   a += 0.1
 end

p X
p y
p w

c, cov, chisq, status = MultiFit.wlinear(X, w, y)

p "--"
p c
