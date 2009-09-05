#!/usr/bin/env ruby
# This example is taken from frei2.cpp 
# in "Numerische Physik" p205-206 (Springer).
#
# Reference:
#   "Numerische Physik", by Harald Wiedemann, Springer (2004)
#   ISBN: 3-540-40774-X
#   http://www.springeronline.com/sgw/cda/frontpage/0,10735,1-102-22-22345455-0,00.html

require("gsl")

#NMAX = 8192
NMAX = 256

psi = GSL::Vector[2*NMAX]

dx = 0.1
dt = 0.1
n_out = 20
alpha = 1
p_0 = -0.5

dp = 2*Math::PI/dx/NMAX

sum = 0.0
for n in 0...NMAX
  x = (n-NMAX/2) * dx
  psi[2*n] = Math::exp(-GSL::pow_2(x/alpha)/2)
  sum += GSL::pow_2(psi[2*n]);
end
sum = 1.0/Math::sqrt(sum)

for n in 0...NMAX
  x = (n-NMAX/2) * dx
  psi[2*n+1] = -psi[2*n] * sum * Math::sin(p_0*x) # Imaginaerteil
  psi[2*n] = psi[2*n] * sum * Math::cos(p_0*x)
end

IO.popen("graph -T X -C -g 3", "w") do |io|
  psi_p = psi.duplicate
  for n1 in 0...NMAX do
    x = (n1-NMAX/2) * dx
    io.printf("%e %e\n", x, Math::sqrt(GSL::pow_2(psi[2*n1]) + GSL::pow_2(psi[2*n1+1])))
  end
  io.printf("\n")
  
  GSL::FFT::Complex::Radix2::forward(psi_p)
  
  
  t = 0.0
  for n in 1..n_out do
    t1 = n*dt
    STDOUT.printf("t = %2.1f (%2d/%2d)\n", t1, n, n_out)
    for n1 in 0...(NMAX/2) do
      pp = n1*dp
      arg = GSL::pow_2(pp)*t1/2
      psi[2*n1] = psi_p[2*n1] * Math::cos(arg) - psi_p[2*n1+1] * Math::sin(arg)
      psi[2*n1+1] = psi_p[2*n1] * Math::sin(arg) + psi_p[2*n1+1] * Math::cos(arg)
    end
    for n1 in (NMAX/2)...NMAX do
      pp = (n1-NMAX)*dp
      arg = GSL::pow_2(pp)*t1/2
      psi[2*n1] = psi_p[2*n1] * Math::cos(arg) - psi_p[2*n1+1] * Math::sin(arg)
      psi[2*n1+1] = psi_p[2*n1] * Math::sin(arg) + psi_p[2*n1+1] * Math::cos(arg)
    end
    GSL::FFT::Complex::Radix2::inverse(psi)
    if n%10 == 0
      for n1 in 0...NMAX do
        x = (n1-NMAX/2) * dx
        io.printf("%e %e\n", x, Math::sqrt(GSL::pow_2(psi[2*n1]) + GSL::pow_2(psi[2*n1+1])))
      end
      io.printf("\n")
    end
  end
end

