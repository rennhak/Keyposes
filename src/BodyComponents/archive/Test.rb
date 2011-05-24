#!/usr/bin/env ruby
require 'rubygems'
require 'gsl'

include GSL
include MultiFit

N   = 100

y0  = 1.0
A   = 2.0
x0  = 3.0
w   = 0.5

r   = Rng.alloc
x   = Vector.linspace(0.01, 10, N)
sig = 1

# Lognormal function with noise
y =  y0 + A*Sf::exp(-pow_2(Sf::log(x/x0)/w)) + 0.1*Ran::gaussian(r, sig, N)

guess = [0, 3, 2, 1]
coef, err, chi2, dof = MultiFit::FdfSolver.fit(x, y, "lognormal", guess)
y0 = coef[0]
amp = coef[1]
x0 = coef[2]
w = coef[3]

graph(x, y, y0+amp*Sf::exp(-pow_2(Sf::log(x/x0)/w)))
