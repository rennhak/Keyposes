#!/usr/bin/env ruby
require("gsl")
include GSL
include Monte
include Math

proc_f = Proc.new { |k, dim, params|
  pi = Math::PI
  a = 1.0/(pi*pi*pi)
  a/(1.0 - cos(k[0])*cos(k[1])*cos(k[2]))
}

def display_results(title, result, error)
  exact = 1.3932039296856768591842462603255

  diff = result - exact
  printf("%s ==================\n", title);
  printf("result = % .6f\n", result);
  printf("sigma  = % .6f\n", error);
  printf("exact  = % .6f\n", exact);
  printf("error  = % .6f = %.1g sigma\n", diff, diff.abs/error)
end

dim = 3
xl = Vector.alloc([0, 0, 0])
xu = Vector.alloc([PI, PI, PI])
G = Monte::Function.alloc(proc_f, dim)
calls = 10000
r = GSL::Rng.alloc(Rng::DEFAULT)

vegas = Monte::Vegas.alloc(dim)
result, error = Monte::Vegas::integrate(G, xl, xu, dim, calls, r, vegas)
#result, error = Monte::Vegas::integrate(G, xl, xu, calls, r, vegas)
#result, error = Monte::Vegas::integrate(G, xl, xu, calls, vegas)
#result, error = Monte::Vegas::integrate(G, xl, xu, dim, calls, r, "vegas")

#result, error = G.integrate(xl, xu, dim, calls, r, vegas)
#result, error = G.integrate(xl, xu, calls, r, vegas)
#result, error = G.integrate(xl, xu, calls, vegas)

#result, error = vegas.integrate(G, xl, xu, dim, calls, r)
#result, error = vegas.integrate(G, xl, xu, calls, r)
#result, error = vegas.integrate(G, xl, xu, dim, calls)
#result, error = vegas.integrate(G, xl, xu, calls)

display_results("vegas", result, error)
