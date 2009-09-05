=begin
= NDLINAR: multi-linear, multi-parameter least squares fitting 

The multi-dimension fitting library NDLINEAR is not included in GSL,
but is provided as an extension library. This is available at the
((<Patric Alken's page|URL:http://ucsu.colorado.edu/~alken/gsl/>)).

Contents:
(1) ((<Introduction|URL:ndlinear.html#1>))
(2) ((<Class and methods|URL:ndlinear.html#2>))
(3) ((<Examples|URL:ndlinear.html#3>))

== Introduction
The NDLINEAR extension provides support for general linear least squares 
fitting to data which is a function of more than one variable (multi-linear or 
multi-dimensional least squares fitting). This model has the form where 
(({x})) is a vector of independent variables, a_i are the fit coefficients, 
and F_i are the basis functions of the fit. This GSL extension computes the 
design matrix X_{ij = F_j(x_i) in the special case that the basis functions 
separate: Here the superscript value j indicates the basis function 
corresponding to the independent variable x_j. The subscripts (i_1, i_2, i_3, 
�c) refer to which basis function to use from the complete set. These 
subscripts are related to the index i in a complex way, which is the main 
problem this extension addresses. The model then becomes where n is the 
dimension of the fit and N_i is the number of basis functions for the variable 
x_i. Computationally, it is easier to supply the individual basis functions 
u^{(j) than the total basis functions F_i(x). However the design matrix X is 
easiest to construct given F_i(x). Therefore the routines below allow the user 
to specify the individual basis functions u^{(j) and then automatically 
construct the design matrix X. 


== Class and Methods
--- GSL::MultiFit::Ndlinear.alloc(n_dim, N, u, params)
--- GSL::MultiFit::Ndlinear::Workspace.alloc(n_dim, N, u, params)
    Creates a workspace for solving multi-parameter, multi-dimensional linear 
    least squares problems. ((|n_dim|)) specifies the dimension of the fit 
    (the number of independent variables in the model). The array ((|N|)) of 
    length ((|n_dim|)) specifies the number of terms in each sum, so that 
    ((|N[i]|))
    specifies the number of terms in the sum of the i-th independent variable. 
    The array of (({Proc})) objects ((|u|)) of length ((|n_dim|)) specifies 
    the basis functions for each independent fit variable, so that ((|u[i]|)) 
    is a procedure to calculate the basis function for the i-th 
    independent variable.
    Each of the procedures ((|u|)) takes three block parameters: a point 
    ((|x|)) at which to evaluate the basis function, an array y of length 
    ((|N[i]|)) which is filled on output with the basis function values at 
    ((|x|)) for all i, and a params argument which contains parameters needed 
    by the basis function. These parameters are supplied in the ((|params|))
    argument to this method. 

    Ex)

       N_DIM = 3
       N_SUM_R = 10
       N_SUM_THETA = 11
       N_SUM_PHI = 9

       basis_r = Proc.new { |r, y, params|
         params.eval(r, y)
       }

       basis_theta = Proc.new { |theta, y, params|
         for i in 0...N_SUM_THETA do
           y[i] = GSL::Sf::legendre_Pl(i, Math::cos(theta));
         end
       }

       basis_phi = Proc.new { |phi, y, params|
         for i in 0...N_SUM_PHI do
           if i%2 == 0
             y[i] = Math::cos(i*0.5*phi)
           else
             y[i] = Math::sin((i+1.0)*0.5*phi)
           end
         end
       }

       N = [N_SUM_R, N_SUM_THETA, N_SUM_PHI]
       u = [basis_r, basis_theta, basis_phi]

       bspline = GSL::BSpline.alloc(4, N_SUM_R - 2)

       ndlinear = GSL::MultiFit::Ndlinear.alloc(N_DIM, N, u, bspline)

--- GSL::MultiFit::Ndlinear.design(vars, X, w)
--- GSL::MultiFit::Ndlinear.design(vars, w)
--- GSL::MultiFit::Ndlinear::Workspace#design(vars, X)
--- GSL::MultiFit::Ndlinear::Workspace#design(vars)
    Construct the least squares design matrix ((|X|)) from the input ((|vars|))
    and the previously specified basis functions. vars is a ndata-by-n_dim 
    matrix where the ith row specifies the n_dim independent variables for the 
    ith observation. 

--- GSL::MultiFit::Ndlinear.calc(x, c, cov, w)
--- GSL::MultiFit::Ndlinear::Workspace#calc(x, c, cov)
    After the least squares problem is solved via (({GSL::MultiFit::linear})), 
    this method can be used to evaluate the model at the data point ((|x|)). 
    The coefficient vector ((|c|)) and covariance matrix ((|cov|)) are 
    outputs from (({GSL::MultiFit::linear})). The model output value and 
    its error [((|y, yerr|))] are returned as an array.

== Examples
This example program generates data from the 3D isotropic harmonic oscillator 
wavefunction (real part) and then fits a model to the data using B-splines in 
the r coordinate, Legendre polynomials in theta, and sines/cosines in phi. 
The exact form of the solution is (neglecting the normalization constant for 
simplicity) The example program models psi by default. 

 #!/usr/bin/env ruby
 require("rbgsl")

 N_DIM = 3
 N_SUM_R = 10
 N_SUM_THETA = 11
 N_SUM_PHI = 9
 R_MAX = 3.0

 def psi_real_exact(k, l, m, r, theta, phi)
    rr = GSL::pow(r, l)*Math::exp(-r*r)*GSL::Sf::laguerre_n(k, l + 0.5, 2 * r * r)	 
    tt = GSL::Sf::legendre_sphPlm(l, m, Math::cos(theta))
    pp = Math::cos(m*phi)
    rr*tt*pp
 end

 basis_r = Proc.new { |r, y, params|
   params.eval(r, y)
 }

 basis_theta = Proc.new { |theta, y, params|
   for i in 0...N_SUM_THETA do
     y[i] = GSL::Sf::legendre_Pl(i, Math::cos(theta));
   end
 }

 basis_phi = Proc.new { |phi, y, params|
   for i in 0...N_SUM_PHI do
     if i%2 == 0
       y[i] = Math::cos(i*0.5*phi)
     else
       y[i] = Math::sin((i+1.0)*0.5*phi)
     end
   end
 }


 GSL::Rng::env_setup()

 k = 5
 l = 4
 m = 2

 NDATA = 3000

 N = [N_SUM_R, N_SUM_THETA, N_SUM_PHI]
 u = [basis_r, basis_theta, basis_phi]

 rng = GSL::Rng.alloc()

 bspline = GSL::BSpline.alloc(4, N_SUM_R - 2)
 bspline.knots_uniform(0.0, R_MAX)

 ndlinear = GSL::MultiFit::Ndlinear.alloc(N_DIM, N, u, bspline)
 multifit = GSL::MultiFit.alloc(NDATA, ndlinear.n_coeffs)
 vars = GSL::Matrix.alloc(NDATA, N_DIM)
 data = GSL::Vector.alloc(NDATA)


 for i in 0...NDATA do
   r = rng.uniform()*R_MAX
   theta = rng.uniform()*Math::PI
   phi = rng.uniform()*2*Math::PI
   psi = psi_real_exact(k, l, m, r, theta, phi)
   dpsi = rng.gaussian(0.05*psi)

   vars[i][0] = r
   vars[i][1] = theta
   vars[i][2] = phi		

   data[i] = psi + dpsi
 end

 X = GSL::MultiFit::Ndlinear::design(vars, ndlinear)

 coeffs, cov, chisq, = GSL::MultiFit::linear(X, data, multifit)

 rsq = GSL::MultiFit::linear_Rsq(data, chisq)
 STDERR.printf("chisq = %e, Rsq = %f\n", chisq, rsq)

 eps_rms = 0.0
 volume = 0.0
 dr = 0.05;
 dtheta = 5.0 * Math::PI / 180.0
 dphi = 5.0 * Math::PI / 180.0
 x = GSL::Vector.alloc(N_DIM)

 r = 0.01
 while r < R_MAX do
   theta = 0.0
   while theta < Math::PI do
     phi = 0.0
     while phi < 2*Math::PI do
       dV = r*r*Math::sin(theta)*r*dtheta*dphi
       x[0] = r
       x[1] = theta
       x[2] = phi

       psi_model, err = GSL::MultiFit::Ndlinear.calc(x, coeffs, cov, ndlinear)
       psi = psi_real_exact(k, l, m, r, theta, phi)
       err = psi_model - psi
       eps_rms += err * err * dV;
       volume += dV;

       if phi == 0.0
         printf("%e %e %e %e\n", r, theta, psi, psi_model)
       end

       phi += dphi
     end
     theta += dtheta
   end
   printf("\n");
   r += dr
 end

 eps_rms /= volume
 eps_rms = Math::sqrt(eps_rms)
 STDERR.printf("rms error over all parameter space = %e\n", eps_rms)


((<Reference index|URL:ref.html>))
((<top|URL:index.html>))

=end
