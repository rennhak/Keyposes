=begin
= Special Functions

=== Contents:
(1) ((<Usage:|URL:sf.html#1>))
(2) ((<GSL::Sf::Result class|URL:sf.html#2>))
(3) ((<Modes|URL:sf.html#3>))
(4) ((<Airy functions|URL:sf.html#4>))
(5) ((<Bessel functins|URL:sf.html#5>))
(6) ((<Clausen functins|URL:sf.html#6>))
(7) ((<Coulomb functins|URL:sf.html#7>))
(8) ((<Coupling coefficients|URL:sf.html#8>))
(9) ((<Dawson coefficients|URL:sf.html#9>))
(10) ((<Debye coefficients|URL:sf.html#10>))
(11) ((<Dilogarithm|URL:sf.html#11>))
(12) ((<Elementary operations|URL:sf.html#12>))
(13) ((<Elliptic integrals|URL:sf.html#13>))
(14) ((<Elliptic functions|URL:sf.html#14>))
(15) ((<Error functions|URL:sf.html#15>))
(16) ((<Exponential functions|URL:sf.html#16>))
(17) ((<Exponential integrals|URL:sf.html#17>))
(18) ((<Fermi-Dirac function|URL:sf.html#18>))
(19) ((<Gamma function|URL:sf.html#19>))
(20) ((<Gegenbauer functions|URL:sf.html#20>))
(21) ((<Hypergeometric functions|URL:sf.html#21>))
(22) ((<Laguerre functions|URL:sf.html#22>))
(23) ((<Lambert W functions|URL:sf.html#23>))
(24) ((<Legendre functions and spherical harmonics|URL:sf.html#24>))
(25) ((<Logarithm and related functions|URL:sf.html#25>))
(26) ((<Mathieu functions|URL:sf.html#26>))
(27) ((<Power function|URL:sf.html#27>))
(28) ((<Psi (digamma) function|URL:sf.html#28>))
(29) ((<Synchrotron functions|URL:sf.html#29>))
(30) ((<Transport functions|URL:sf.html#30>))
(31) ((<Trigonometric functions|URL:sf.html#31>))
(32) ((<Zeta functions|URL:sf.html#32>))

== Usage
Ruby/GSL provides all the (documented) GSL special functions as module functions
under the (({GSL::Sf})) module. 
The prefix (({gsl_sf_})) in C functions is replaced by the module
identifier (({GSL::Sf::})). For example, the regular Bessel function of 0-th order
is evaluated as 
  y = GSL::Sf::bessel_J0(x)
or
  include GSL::Sf
  y = bessel_J0(x)
where the argument (({x})) can be a (({Numeric})), (({GSL::Vector})), 
(({GSL::Matrix})), or an (({NArray})) object.

Example:
  irb(main):001:0> require("gsl")
  => true
  irb(main):002:0> x = 1.0
  => 1.0
  irb(main):003:0> Sf::bessel_J0(x)
  => 0.765197686557967
  irb(main):004:0> x = Vector[1, 2, 3, 4]
  => GSL::Vector
  [ 1.000e+00 2.000e+00 3.000e+00 4.000e+00 ]
  irb(main):005:0> Sf::bessel_J0(x)
  => GSL::Vector
  [ 7.652e-01 2.239e-01 -2.601e-01 -3.971e-01 ]
  irb(main):006:0> x = Matrix[1..4, 2, 2]
  => GSL::Matrix
  [  1.000e+00  2.000e+00 
     3.000e+00  4.000e+00 ]
  irb(main):007:0> Sf::bessel_J0(x)
  => GSL::Matrix
  [  7.652e-01  2.239e-01 
    -2.601e-01 -3.971e-01 ]
  irb(main):008:0> x = NArray[1.0, 2, 3, 4]
  => NArray.float(4): 
  [ 1.0, 2.0, 3.0, 4.0 ]
  irb(main):009:0> Sf::bessel_J0(x)
  => NArray.float(4): 
  [ 0.765198, 0.223891, -0.260052, -0.39715 ]

== (({GSL::Sf::Result})) Class
The Ruby methods as wrappers of GSL functions with the suffix "(({_e}))" return
(({GSL::Sf::Result})) objects which contain the function values as well as
error information.

* Instance methods
  --- GSL::Sf::Result#val
      Returns the value.
  --- GSL::Sf::Result#err
      Returns the error.
  --- GSL::Sf::Result_e10#val
      Returns the value.
  --- GSL::Sf::Result_e10#err
      Returns the error.


== Modes
The goal of the library is to achieve double precision accuracy wherever possible. 
However the cost of evaluating some special functions to double precision can 
be significant, particularly where very high order terms are required. 
In these cases a ((|mode|)) argument allows the accuracy of the function 
to be reduced in order to improve performance. 
The following precision levels are available for the mode argument,
given by Fixnum constants under the (({GSL})) module,
* (({GSL::PREC_DOUBLE}))
  Double-precision, a relative accuracy of approximately 2 * 10^-16.
* (({GSL::PREC_SINGLE}))
  Single-precision, a relative accuracy of approximately 10^-7.
* (({GSL::PREC_APPROX}))
  Approximate values, a relative accuracy of approximately 5 * 10^-4.

The approximate mode provides the fastest evaluation at the lowest accuracy.

== Airy Functions and Derivatives
--- GSL::Sf::airy_Ai(x, mode = GSL::PREC_DOUBLE)
    Computes the Airy function Ai(x) with an accuracy specified by ((|mode|)).
--- GSL::Sf::airy_Bi(x, mode = GSL::PREC_DOUBLE)
    Computes the Airy function Bi(x) with an accuracy specified by ((|mode|)).
--- GSL::Sf::airy_Ai_scaled(x, mode = GSL::PREC_DOUBLE)
    Computes a scaled version of the Airy function S_A(x) Ai(x). 
    For x>0 the scaling factor S_A(x) is exp(+(2/3) x^(3/2)), and is 1 for x<0.
--- GSL::Sf::airy_Bi_scaled(x, mode = GSL::PREC_DOUBLE)
    Computes a scaled version of the Airy function S_B(x) Bi(x). 
    For x>0 the scaling factor S_B(x) is exp(-(2/3) x^(3/2)), and is 1 for x<0.

=== Derivatives of Airy Functions
--- GSL::Sf::airy_Ai_deriv(x, mode = GSL::PREC_DOUBLE)
    Computes the Airy function derivative Ai'(x) with an accuracy 
    specified by ((|mode|)).
--- GSL::Sf::airy_Bi_deriv(x, mode = GSL::PREC_DOUBLE)
    Computes the Airy function derivative Bi'(x) with an accuracy 
    specified by ((|mode|)).
--- GSL::Sf::airy_Ai_deriv_scaled(x, mode = GSL::PREC_DOUBLE)
    Computes the derivative of the scaled Airy function S_A(x) Ai(x).
--- GSL::Sf::airy_Bi_deriv_scaled(x, mode = GSL::PREC_DOUBLE)
    Computes the derivative of the scaled Airy function S_B(x) Bi(x).

=== Zeros of Airy Functions
--- GSL::Sf::airy_zero_Ai(s)
    Computes the location of the ((|s|))-th zero of the Airy function Ai(x).
--- GSL::Sf::airy_zero_Bi(s)
    Computes the location of the ((|s|))-th zero of the Airy function Bi(x).

=== Zeros of Derivatives of Airy Functions
--- GSL::Sf::airy_zero_Ai_deriv(s)
    Computes the location of the ((|s|))-th zero of the Airy function 
    derivative Ai'(x).
--- GSL::Sf::airy_zero_Bi_deriv(s)
    Computes the location of the ((|s|))-th zero of the Airy function 
    derivative Bi'(x).


== Bessel Functions
=== Regular Cylindrical Bessel Functions
--- GSL::Sf::bessel_J0(x)
    Computes the regular cylindrical Bessel function of zeroth order, J_0(x).
--- GSL::Sf::bessel_J1(x)
    Computes the regular cylindrical Bessel function of first order, J_1(x).
--- GSL::Sf::bessel_Jn(n, x)
    Computes the regular cylindrical Bessel function of order ((|n|)), J_n(x).
--- GSL::Sf::bessel_Jn_array(nmin, nmax, x)
    Computes the values of the regular cylindrical Bessel functions J_n(x) 
    for n from ((|nmin|)) to ((|nmax|)) inclusive, and returns the 
    results as a (({GSL::Vector})) object.
    The values are computed using recurrence relations, for efficiency, 
    and therefore may differ slightly from the exact values.
=== Irregular Cylindrical Bessel Functions
--- GSL::Sf::bessel_Y0(x)
    Computes the irregular cylindrical Bessel function of zeroth order, Y_0(x).
--- GSL::Sf::bessel_Y1(x)
    Computes the irregular cylindrical Bessel function of first order, Y_1(x).
--- GSL::Sf::bessel_Yn(n, x)
    Computes the irregular cylindrical Bessel function of order ((|n|)), Y_n(x).
--- GSL::Sf::bessel_Yn_array(nmin, nmax, x)
    Computes the values of the irregular cylindrical Bessel functions Y_n(x) 
    for n from ((|nmin|)) to ((|nmax|)) inclusive, and returns the 
    results as a (({GSL::Vector})) object.
    The values are computed using recurrence relations, for efficiency, 
    and therefore may differ slightly from the exact values.

=== Regular Modified Cylindrical Bessel Functions
--- GSL::Sf::bessel_I0(x)
    Computes the regular modified cylindrical Bessel function of zeroth order, 
    I_0(x).
--- GSL::Sf::bessel_I1(x)
    Computes the regular modified cylindrical Bessel function of first order, 
    I_1(x).
--- GSL::Sf::bessel_In(n, x)
    Computes the regular modified cylindrical Bessel function of order ((|n|)), 
    I_n(x).
--- GSL::Sf::bessel_In_array(nmin, nmax, x)
    Computes the values of the regular modified cylindrical Bessel functions 
    I_n(x) for n from ((|nmin|)) to ((|nmax|)) inclusive, and returns the 
    results as a (({GSL::Vector})) object. The start of the range ((|nmin|)) 
    must be positive or zero. The values are computed using recurrence relations, 
    for efficiency, and therefore may differ slightly from the exact values.
--- GSL::Sf::bessel_I0_scaled(x)
    Computes the scaled regular modified cylindrical Bessel function of 
    zeroth order, exp(-|x|) I_0(x).
--- GSL::Sf::bessel_I1_scaled(x)
    Computes the scaled regular modified cylindrical Bessel function of first 
    order, exp(-|x|)I_1(x).
--- GSL::Sf::bessel_In_scaled(n, x)
    Computes the scaled regular modified cylindrical Bessel function of order 
    ((|n|)),  exp(-|x|) I_n(x).
--- GSL::Sf::bessel_In_scaled_array(nmin, nmax, x)
    Computes the values of the scaled regular modified cylindrical Bessel 
    functions exp(-|x|) I_n(x) for n from ((|nmin|)) to ((|nmax|)) inclusive, 
    and returns the results as a (({GSL::Vector})) object. The start of the range 
    ((|nmin|))  must be positive or zero. The values are computed using 
    recurrence relations,  for efficiency, and therefore may differ slightly 
    from the exact values.

=== Irregular Modified Cylindrical Bessel Functions
--- GSL::Sf::bessel_K0(x)
    Computes the irregular modified cylindrical Bessel function 
    of zeroth order, K_0(x), for x > 0.
--- GSL::Sf::bessel_K1(x)
    Computes the irregular modified cylindrical Bessel function 
    of first order, K_1(x), for x > 0.
--- GSL::Sf::bessel_Kn(n, x)
    Computes the irregular modified cylindrical Bessel function 
    of order ((|n|)), K_n(x), for x > 0.
--- GSL::Sf::bessel_Kn_array(nmin, nmax, x)
    Computes the values of the irregular modified cylindrical Bessel 
    functions K_n(x) for n from ((|nmin|)) to ((|nmax|)) inclusive, 
    and returns the results as a (({GSL::Vector})) object. 
    The start of the range ((|nmin|)) must be positive or zero. 
    The domain of the function is ((|x>0|)). 
    The values are computed using recurrence relations, for efficiency, 
    and therefore may differ slightly from the exact values.
--- GSL::Sf::bessel_K0_scaled(x)
    Computes the scaled irregular modified cylindrical Bessel function 
    of zeroth order exp(x) K_0(x) for x>0.
--- GSL::Sf::bessel_K1_scaled(x)
    Computes the scaled irregular modified cylindrical Bessel function 
    of first order exp(x) K_1(x) for x>0
--- GSL::Sf::bessel_Kn_scaled(n, x)
    Computes the scaled irregular modified cylindrical Bessel function 
    of order ((|n|)), exp(x) K_n(x), for x>0.
--- GSL::Sf::bessel_Kn_scaled_array(nmin, nmax, x)
    Computes the values of the scaled irregular cylindrical Bessel functions 
    exp(x) K_n(x) for n from ((|nmin|)) to ((|nmax|)) inclusive, 
    and returns the results as a (({GSL::Vector})) object. 
    The start of the range nmin must be positive or zero. 
    The domain of the function is x>0. The values are computed 
    using recurrence relations, for efficiency, 
    and therefore may differ slightly from the exact values.

=== Regular Spherical Bessel Functions
--- GSL::Sf::bessel_j0(x)
    Computes the regular spherical Bessel function of zeroth order,
    j0(x) = sin(x)/x.
--- GSL::Sf::bessel_j1(x)
    Computes the regular spherical Bessel function of first order, 
    j1(x) = (sin(x)/x - cos(x))/x.
--- GSL::Sf::bessel_j2(x)
    Computes the regular spherical Bessel function of second order, 
    j2(x) = ((3/x^2 - 1)sin(x) - 3cos(x)/x)/x.
--- GSL::Sf::bessel_jl(l, x)
    Computes the regular spherical Bessel function of order l, 
    j_l(x), for l >= 0 and x >= 0.
--- GSL::Sf::bessel_jl_array(lmax, x)
    Computes the values of the regular spherical Bessel functions j_l(x) 
    for l from 0 to ((|lmax|)) inclusive for lmax >= 0 and x >= 0, 
    and returns the results as a (({GSL::Vector})) object. 
    The values are computed using recurrence relations, for efficiency, 
    and therefore may differ slightly from the exact values.
--- GSL::Sf::bessel_jl_steed_array(lmax, x)
    This method uses Steed's method to compute the values of the regular 
    spherical Bessel functions j_l(x) for l from 0 to ((|lmax|)) inclusive 
    for ((|lmax|)) >= 0 and x >= 0, and returns the results as a (({GSL::Vector})) 
    object.  The Steed/Barnett algorithm is described in 
    Comp. Phys. Comm. 21, 297 (1981). Steed's method is more stable than the 
    recurrence used in the other functions but is also slower.

=== Irregular Spherical Bessel Functions
--- GSL::Sf::bessel_y0(x)
    Computes the irregular spherical Bessel function of zeroth order, 
    y_0(x) = -cos(x)/x.
--- GSL::Sf::bessel_y1(x)
    Computes the irregular spherical Bessel function of first order, 
    y_1(x) = -(cos(x)/x + sin(x))/x.
--- GSL::Sf::bessel_y2(x)
    Computes the irregular spherical Bessel function of second order, 
    y_2(x) = (-3/x^3 + 1/x)cos(x) - (3/x^2)sin(x).
--- GSL::Sf::bessel_yl(l, x)
    Computes the irregular spherical Bessel function of order ((|l|)), 
    y_l(x), for l >= 0.
--- GSL::Sf::bessel_yl_array(lmax, x)
    This method computes the values of the irregular spherical Bessel functions 
    y_l(x) for l from 0 to ((|lmax|)) inclusive for ((|lmax >= 0|))), 
    and returns the results as a (({GSL::Vector})) object. 
    The values are computed using recurrence relations, for efficiency, 
    and therefore may differ slightly from the exact values.

=== Regular Modified Spherical Bessel Functions
--- GSL::Sf::bessel_i0_scaled(x)
    Computes the scaled regular modified spherical Bessel function of zeroth 
    order, exp(-|x|) i_0(x).
--- GSL::Sf::bessel_i1_scaled(x)
    Computes the scaled regular modified spherical Bessel function of first
    order, exp(-|x|) i_1(x).
--- GSL::Sf::bessel_i2_scaled(x)
    Computes the scaled regular modified spherical Bessel function of second
    order, exp(-|x|) i_2(x).
--- GSL::Sf::bessel_il_scaled(l, x)
    Computes the scaled regular modified spherical Bessel function of 
    order ((|l|)), exp(-|x|) i_l(x).
--- GSL::Sf::bessel_il_scaled_array(lmax, x)
    This routine computes the values of the scaled regular modified cylindrical 
    Bessel functions exp(-|x|) i_l(x) for l from 0 to ((|lmax|)) inclusive for 
    ((|lmax >= 0|)),     and returns the results as a (({GSL::Vector})) object. 
    The values are computed using recurrence relations, for efficiency, 
    and therefore may differ slightly from the exact values.

=== Irregular Modified Spherical Bessel Functions
--- GSL::Sf::bessel_k0_scaled(x)
    Computes the scaled irregular modified spherical Bessel function of zeroth 
    order, exp(-|x|) k_0(x).
--- GSL::Sf::bessel_k1_scaled(x)
    Computes the scaled irregular modified spherical Bessel function of first
    order, exp(-|x|) k_1(x).
--- GSL::Sf::bessel_k2_scaled(x)
    Computes the scaled irregular modified spherical Bessel function of second
    order, exp(-|x|) k_2(x).
--- GSL::Sf::bessel_kl_scaled(l, x)
    Computes the scaled irregular modified spherical Bessel function of 
    order ((|l|)), exp(-|x|) k_l(x).
--- GSL::Sf::bessel_kl_scaled_array(lmax, x)
    This routine computes the values of the scaled irregular modified cylindrical 
    Bessel functions exp(-|x|) k_l(x) for l from 0 to ((|lmax|)) inclusive for 
    ((|lmax >= 0|)),     and returns the results as a (({GSL::Vector})) object. 
    The values are computed using recurrence relations, for efficiency, 
    and therefore may differ slightly from the exact values.

=== Regular Bessel Function - Fractional Order
--- GSL::Sf::bessel_Jnu(nu, x)
    Computes the regular cylindrical Bessel function of fractional 
    order ((|nu|)), J_nu(x).
--- GSL::Sf::bessel_sequence_Jnu_e(nu, v)
--- GSL::Sf::bessel_sequence_Jnu_e(nu, mode, v)
    These compute the regular cylindrical Bessel function of fractional order nu, J_nu(x), 
    evaluated at a series of x values. The (({GSL::Vector})) object ((|v|)) 
    contains the x values. They are assumed to be strictly ordered and positive. 
    The vector is over-written with the values of J_nu(x_i).

=== Irregular Bessel Functions - Fractional Order
--- GSL::Sf::bessel_Ynu(nu, x)
    Computes the irregular cylindrical Bessel function of fractional order ((|nu|)), 
    Y_nu(x).

=== Regular Modified Bessel Functions - Fractional Order
--- GSL::Sf::bessel_Inu(nu, x)
    Computes the regular modified Bessel function of fractional order ((|nu|)), 
    I_nu(x) for x>0, nu>0.
--- GSL::Sf::bessel_Inu_scaled(nu, x)
    Computes the scaled regular modified Bessel function of fractional order ((|nu|)), 
    exp(-|x|) I_nu(x) for x>0, nu>0.

=== Irregular Modified Bessel Functions - Fractional Order
--- GSL::Sf::bessel_Knu(nu, x)
    Computes the irregular modified Bessel function of fractional order ((|nu|)), 
    K_nu(x) for x>0, nu>0.
--- GSL::Sf::bessel_lnKnu(nu, x)
    Computes the logarithm of the irregular modified Bessel function of fractional 
    order ((|nu|)), ln(K_nu(x)) for x>0, nu>0
--- GSL::Sf::bessel_Knu_scaled(nu, x)
    Computes the scaled irregular modified Bessel function of fractional order ((|nu|)), 
    exp(+|x|) K_nu(x) for x>0, nu>0.

=== Zeros of Regular Bessel Functions
--- GSL::Sf::bessel_zero_J0(s)
    Computes the location of the ((|s|))-th positive zero of the Bessel function J_0(x).
--- GSL::Sf::bessel_zero_J1(s)
    Computes the location of the ((|s|))-th positive zero of the Bessel function J_1(x).
--- GSL::Sf::bessel_zero_Jnu(nu, s)
    Computes the location of the ((|s|))-th positive zero of the Bessel function 
    J_nu(x). The current implementation does not support negative values of ((|nu|)).

== Clausen Functions
--- GSL::Sf::clausen(x)
    The Clausen function is defined by the following integral,
        Cl_2(x) = - int_0^x dt log(2 sin(t/2))
    It is related to the dilogarithm by Cl_2(theta) = Im Li_2(exp(i theta)).


== Coulomb Functions
--- GSL::Sf::hydrogenicR_1(Z, r)
    Computes the lowest-order normalized hydrogenic bound state 
    radial wavefunction R_1 := 2Z sqrt{Z} exp(-Z r).
--- GSL::Sf::hydrogenicR(n, l, Z, r)
    Computes the ((|n|))-th normalized hydrogenic bound state radial wavefunction,
         R_n := 2 (Z^{3/2}/n^2) sqrt{(n-l-1)!/(n+l)!}exp(-Z r/n) (2Z/n)^l L^{2l+1}_{n-l-1}(2Z/n r).  
    The normalization is chosen such that the wavefunction psi is given by 
    psi(n,l,r) = R_n Y_{lm}.

=== Coulomb Wave Functions
--- GSL::Sf::coulomb_wave_FG_e(eta, x, L, k)
    This method computes the coulomb wave functions 
    F_L(eta,x), G_{L-k}(eta,x) and their derivatives with respect to x, 
    F'_L(eta,x) G'_{L-k}(eta,x). 
    The parameters are restricted to ((|L|)), ((|L-k > -1/2|)), ((|x > 0|)) 
    and integer ((|k|)). Note that ((|L|)) itself is not restricted to being 
    an integer. The results are returned as an array of 7 elements,
    ((|[F, G, Fp, Gp, exp_F, exp_G, status]|)),
    as ((|F, G|)) for the function values, ((|Fp, Gp|)) 
    for the derivative values, and ((|exp_F, exp_G|)) for scaling exponents
    in the case of overflow occurs.
--- GSL::Sf::coulomb_wave_F_array(Lmin, kmax, eta, x)
    This method computes the function F_L(eta,x) for 
    L = ((|Lmin ... Lmin + kmax|)) and returns the results 
    as an array of 3 elements, 
    ((|[fc_array, F_exponent, status]|)). 
    In the case of overflow, the exponent is returned in ((|F_exponent|)).
--- GSL::Sf::coulomb_wave_FG_array(Lmin, kmax, eta, x)
    This method computes the functions F_L(eta,x), G_L(eta,x) for L = ((|Lmin|))
    ... ((|Lmin + kmax|)) and returns the results as an array of 
    5 elements, ((|[fc_array, gc_array, F_exponent, G_exponent, status]|)). 
    In the case of overflow the exponents are stored in ((|F_exponent|)) 
    and ((|G_exponent|)).
--- GSL::Sf::coulomb_wave_FGp_array(Lmin, kmax, eta, x)
    This method computes the functions F_L(eta,x), G_L(eta,x) and 
    their derivatives F'_L(eta,x), G'_L(eta,x) for L = ((|Lmin|)) ... 
    ((|Lmin + kmax|)) and returns the results as an array of 7 elements,
    ((|[fc_array, gc_array, fcp_array, gcp_array, F_exponent, G_exponent, status]|)).
    In the case of overflow the exponents are stored in ((|F_exponent|))
    and ((|G_exponent|)).
--- GSL::Sf::coulomb_wave_sphF_array(Lmin, kmax, eta, x)
    This method computes the Coulomb wave function divided by the argument 
    F_L(eta, x)/x for L = ((|Lmin|)) ... ((|Lmin + kmax|)),
    and returns the results as an array of 3 elememnts,
    ((|[fc_array, F_exponent, status]|)). 
    In the case of overflow the exponent is stored in ((|F_exponent|)). 
    This function reduces to spherical Bessel functions in the limit 
    ((|eta|)) to 0.

=== Coulomb Wave Function Normalization Constant
--- GSL::Sf::coulomb_CL_e(L, eta)
    This method computes the Coulomb wave function normalization 
    constant C_L(eta) for L > -1.
--- GSL::Sf::gsl_sf_coulomb_CL_array(Lmin, kmax, eta)
    This method computes the coulomb wave function normalization constant 
    C_L(eta) for L = Lmin ... Lmin + kmax, Lmin > -1.

== Coupling Coefficients
The Wigner 3-j, 6-j and 9-j symbols give the coupling coefficients 
for combined angular momentum vectors. Since the arguments of the standard 
coupling coefficient functions are integer or half-integer, the arguments 
of the following functions are, by convention, integers equal to twice the 
actual spin value. For information on the 3-j coefficients 
see Abramowitz & Stegun, Section 27.9. 

--- GSL::Sf::coupling_3j(two_ja, two_jb, two_jc, two_ma, two_mb, two_mc)
    Computes the Wigner 3-j coefficient,
        ja jb jc
        ma mb mc
    where the arguments are given in half-integer units, 
    ((|ja = two_ja/2, ma = two_ma/2|)), etc.

--- GSL::Sf::coupling_6j(two_ja, two_jb, two_jc, two_jd, two_je, two_jf)
    Computes the Wigner 6-j coefficient,
        ja jb jc
        jd je jf
    where the arguments are given in half-integer units, 
    ((|ja = two_ja/2, ma = two_ma/2|)), etc.

--- GSL::Sf::coupling_9j(two_ja, two_jb, two_jc, two_jd, two_je, two_jf, two_jg, two_jh, two_ji)
    Computes the Wigner 9-j coefficient,
        ja jb jc
        jd je jf
        jg jh ji
    where the arguments are given in half-integer units, 
    ((|ja = two_ja/2, ma = two_ma/2|)), etc.

== Dawson Function
The Dawson integral is defined by exp(-x^2) int_0^x dt exp(t^2). 
A table of Dawson's integral can be found in Abramowitz & Stegun, Table 7.5.
--- GSL::Sf::dawson(x)
    This method computes the value of Dawson's integral for ((|x|)).

== Debye Functions
The Debye functions are defined by the integral 
D_n(x) = n/x^n int_0^x dt (t^n/(e^t - 1)). 
For further information see Abramowitz & Stegun, Section 27.1. 
--- GSL::Sf::debye_1(x)
--- GSL::Sf::debye_2(x)
--- GSL::Sf::debye_3(x)
--- GSL::Sf::debye_4(x)
    These methods Compute the n-th order Debye functions.

== Dilogarithm
=== Real Argument
--- GSL::Sf::dilog(x)
    Computes the dilogarithm for a real argument. In Lewin's notation this 
    is Li_2(x), the real part of the dilogarithm of a real ((|x|)). 
    It is defined by the integral representation
    Li_2(x) = - Re int_0^x ds log(1-s) / s. 
    Note that Im(Li_2(x)) = 0 for x <= 1, and -pi log(x) for x > 1.

=== Complex Argument
--- GSL::Sf::complex_dilog_e(r, theta)
    This method computes the full complex-valued dilogarithm for 
    the complex argument z = r exp(i theta). 
    The result is returned as an array of 2 elements, ((|[re, im]|)),
    each of them is a (({GSL::Sf::Result})) object.

== Elementary Operations
The following methods allow for the propagation of errors when 
combining quantities by multiplication. 
--- GSL::Sf::multiply_e(x, y)
    This method multiplies ((|x|)) and ((|y|)) and returns 
    the product as a (({GSL::Sf::Result})) object.
--- GSL::Sf::multiply_err_e(x, dx, y, dy)
    This method multiplies ((|x|)) and ((|y|)) with associated absolute 
    errors ((|dx|)) and ((|dy|)),  and returns 
    the product as a (({GSL::Sf::Result})) object.

== Elliptic Integrals
=== Legendre Form of Complete Elliptic Integrals
--- GSL::Sf::ellint_Kcomp(k, mode = GSL::PREC_DOUBLE)
    Computes the complete elliptic integral K(k) 
    to the accuracy specified by the mode variable ((|mode|)).
--- GSL::Sf::ellint_Ecomp(k, mode = GSL::PREC_DOUBLE)
    Computes the complete elliptic integral E(k) 
    to the accuracy specified by the mode variable ((|mode|)).
=== Legendre Form of Incomplete Elliptic Integrals
--- GSL::Sf::ellint_F(phi, k, mode = GSL::PREC_DOUBLE)
    Computes the incomplete elliptic integral E(phi, k) 
    to the accuracy specified by the mode variable ((|mode|)).
--- GSL::Sf::ellint_P(phi, k, n, mode = GSL::PREC_DOUBLE)
    Computes the incomplete elliptic integral P(phi, k, n) 
    to the accuracy specified by the mode variable ((|mode|)).
--- GSL::Sf::ellint_D(phi, k, n, mode = GSL::PREC_DOUBLE)
    Computes the incomplete elliptic integral D(phi, k, n) 
    which is defined through the Carlson form RD(x, y, z) by the following relation,
       D(phi, k, n) = RD (1-sin^2(phi), 1-k^2 sin^2(phi), 1).
=== Carlson Forms
--- GSL::Sf::ellint_RC(x, y, mode = GSL::PREC_DOUBLE)
    Computes the incomplete elliptic integral RC(x, y) 
    to the accuracy specified by the mode variable ((|mode|)).
--- GSL::Sf::ellint_RD(x, y, z, mode = GSL::PREC_DOUBLE)
    Computes the incomplete elliptic integral RD(x, y, z) 
    to the accuracy specified by the mode variable ((|mode|)).
--- GSL::Sf::ellint_RF(x, y, z, mode = GSL::PREC_DOUBLE)
    Computes the incomplete elliptic integral RF(x, y, z) 
    to the accuracy specified by the mode variable ((|mode|)).
--- GSL::Sf::ellint_RJ(x, y, z, p, mode = GSL::PREC_DOUBLE)
    Computes the incomplete elliptic integral RJ(x, y, z, p) 
    to the accuracy specified by the mode variable ((|mode|)).

== Elliptic Functions (Jacobi)
--- GSL::Sf::gsl_sf_elljac(u, m)
--- GSL::Sf::gsl_sf_elljac_e(u, m)
    These methods compute the Jacobian elliptic functions 
    sn(u|m), cn(u|m), dn(u|m) by descending Landen transformations,
    and returns the result as an array of 3 elements.

== Error Functions
--- GSL::Sf::erf(x)
    Computes the error function erf(x) = (2/sqrt(pi)) int_0^x dt exp(-t^2).
--- GSL::Sf::erfc(x)
    Computes the complementary error function.
--- GSL::Sf::log_erfc(x)
    Computes the logarithm of the complementary error function log(erfc(x)).
=== Probability functions
--- GSL::Sf::erf_Z(x)
    Computes the Gaussian probability density function
    Z(x) = (1/sqrt{2 pi}) exp(-x^2/2).
--- GSL::Sf::erf_Q(x)
    Computes the upper tail of the Gaussian probability function 
    Q(x) = (1/sqrt{2 pi}) int_x^infty dt exp(-t^2/2).
--- GSL::Sf::hazard(x)
    The hazard function for the normal distribution, also known as
    the inverse Mill's ratio, is defined as 
    h(x) = Z(x)/Q(x) = sqrt{2/pi exp(-x^2 / 2) / erfc(x/sqrt 2)}. 
    It decreases rapidly as x approaches -infty and asymptotes to h(x) sim x 
    as x approaches +infty.

== Exponential Functions
--- GSL::Sf::exp(x)
--- GSL::Sf::exp_e(x)
    These methods provide an exponential function exp(x) 
    using GSL semantics and error checking.
--- GSL::Sf::exp_e10_e(x)
    This method computes the exponential exp(x) using the 
    (({GSL::Sf::Result_e10})) type to return a result with extended range. 
    This may be useful if the value of exp(x) would overflow the numeric 
    range of (({double})).
--- GSL::Sf::exp_mult(x, y)
--- GSL::Sf::exp_mult_e(x, y)
--- GSL::Sf::exp_mult_e10_e(x, y)
    Exponentiate ((|x|)) and multiply by the factor 
    ((|y|)) to return the product y exp(x).

=== Relative Exponential Functions
--- GSL::Sf::expm1(x)
    Computes the quantity exp(x)-1 using an algorithm that is 
    accurate for small ((|x|)).
--- GSL::Sf::exprel(x)
    Computes the quantity (exp(x)-1)/x using an algorithm that is 
    accurate for small ((|x|)). For small ((|x|)) the algorithm is 
    based on the expansion 
    (exp(x)-1)/x = 1 + x/2 + x^2/(2*3) + x^3/(2*3*4) + ... .
--- GSL::Sf::exprel_2(x)
    Computes the quantity 2(exp(x)-1-x)/x^2 using an algorithm that is 
    accurate for small ((|x|)). For small ((|x|)) the algorithm is based 
    on the expansion 
    2(exp(x)-1-x)/x^2 = 1 + x/3 + x^2/(3*4) + x^3/(3*4*5) + ... .
--- GSL::Sf::exprel_n(n, x)
    Computes the N-relative exponential, which is the ((|n|))-th 
    generalization of the methods (({exprel})) and (({exprel2})). 
    The N-relative exponential is given by,
       exprel_N(x) = N!/x^N (exp(x) - sum_{k=0}^{N-1} x^k/k!)
                   = 1 + x/(N+1) + x^2/((N+1)(N+2)) + ...
                   = 1F1 (1,1+N,x)

=== Exponentiation With Error Estimate
--- GSL::Sf::exp_err_e(x, dx)
    Exponentiates ((|x|)) with an associated absolute error ((|dx|)).
--- GSL::Sf::exp_err_e10_e(x, dx)
    Exponentiates a quantity ((|x|)) with an associated absolute error 
    ((|dx|)) using the (({GSL::Sf::Result_e10})) type 
    to return a result with extended range.
--- GSL::Sf::exp_mult_err_e(x, dx, y, dy)
    Computes the product y exp(x) for the quantities ((|x, y|)) 
    with associated absolute errors ((|dx, dy|)).
--- GSL::Sf::exp_mult_err_e10_e(x, dx, y, dy)
    Computes the product y exp(x) for the quantities ((|x, y|)) 
    with associated absolute errors ((|dx, dy|))  using the 
    (({GSL::Sf::Result_e10})) type to return a result with extended range.

== Exponential Integrals
=== Exponential Integral
--- GSL::Sf::expint_E1(x)
    Computes the exponential integral E_1(x),
         E_1(x) := int_1^infty dt exp(-xt)/t.
--- GSL::Sf::expint_E2(x)
    Computes the second-order exponential integral E_2(x),
         E_2(x) := int_1^infty dt exp(-xt)/t^2.
--- GSL::Sf::expint_En(n, x)
    Computes the exponential integral E_n(n, x) of order ((|n|)). (>= GSL-1.10)

=== Ei(x)
--- GSL::Sf::expint_Ei(x)
    Computes the exponential integral E_i(x),
         Ei(x) := - PV(int_{-x}^infty dt exp(-t)/t)
    where PV denotes the principal value of the integral.
=== Hyperbolic Integrals
--- GSL::Sf::Shi(x)
    Computes the integral Shi(x) = int_0^x dt sinh(t)/t.
--- GSL::Sf::Chi(x)
    Computes the integral 
       Chi(x) := Re[ gamma_E + log(x) + int_0^x dt (cosh[t]-1)/t] , 
    where gamma_E is the Euler constant 
    (available as the constant (({GSL::M_EULER}))).
=== Ei_3(x)
--- GSL::Sf::expint_3(x)
    Computes the exponential integral Ei_3(x) = int_0^x dt exp(-t^3) for x >= 0
=== Trigonometric Integrals
--- GSL::Sf::Si(x)
    Computes the Sine integral Si(x) = int_0^x dt sin(t)/t.
--- GSL::Sf::Ci(x)
    Computes the Cosine integral Ci(x) = -int_x^infty dt cos(t)/t for x > 0.
=== Arctangent Integral
--- GSL::Sf::atanint(x)
    Computes the Arctangent integral AtanInt(x) = int_0^x dt arctan(t)/t.

== Fermi-Dirac Functions
=== Complete Fermi-Dirac Integrals
The complete Fermi-Dirac integral F_j(x) is given by,
    F_j(x)   := (1/r Gamma(j+1)) int_0^infty dt (t^j / (exp(t-x) + 1))

--- GSL::Sf::fermi_dirac_m1(x)
    Computes the complete Fermi-Dirac integral with an index of -1. 
    This integral is given by F_{-1}(x) = e^x / (1 + e^x).
--- GSL::Sf::fermi_dirac_0(x)
    Computes the complete Fermi-Dirac integral with an index of 0. This 
    integral is given by F_0(x) = ln(1 + e^x).
--- GSL::Sf::fermi_dirac_1(x)
    Compute the complete Fermi-Dirac integral with an index of 1, 
    F_1(x) = int_0^infty dt (t /(exp(t-x)+1)).
--- GSL::Sf::fermi_dirac_2(x)
    Computes the complete Fermi-Dirac integral with an index of 2, 
    F_2(x) = (1/2) int_0^infty dt (t^2 /(exp(t-x)+1)).
--- GSL::Sf::fermi_dirac_int(j, x)
    Computes the complete Fermi-Dirac integral with an integer index of 
    ((|j|)), F_j(x) = (1/Gamma(j+1)) int_0^infty dt (t^j /(exp(t-x)+1)).
--- GSL::Sf::fermi_dirac_mhalf(x)
    Computes the complete Fermi-Dirac integral F_{-1/2}(x).
--- GSL::Sf::fermi_dirac_half(x)
    Computes the complete Fermi-Dirac integral F_{1/2}(x).
--- GSL::Sf::fermi_dirac_3half(x)
    Computes the complete Fermi-Dirac integral F_{3/2}(x).
=== Incomplete Fermi-Dirac Integrals
--- GSL::Sf::fermi_dirac_inc_0(x, b)
    Computes the incomplete Fermi-Dirac integral with an index of zero, 
    F_0(x,b) = ln(1 + e^{b-x}) - (b-x).

== Gamma Function
The Gamma function is defined by the following integral,
   Gamma(x) = int_0^infty dt  t^{x-1} exp(-t)
Further information on the Gamma function can be found in 
Abramowitz & Stegun, Chapter 6. 

--- GSL::Sf::gamma(x)
    Computes the Gamma function, subject to ((|x|)) not being a 
    negative integer. The function is computed using the real 
    Lanczos method. The maximum value of ((|x|)) such that Gamma(x) is 
    not considered an overflow is given by the constant
    (({GSL::Sf::GAMMA_XMAX})) and is 171.0.
--- GSL::Sf::lngamma(x)
    Computes the logarithm of the Gamma function, log(Gamma(x)), 
    subject to ((|x|)) not a being negative integer. 
    For x<0 the real part of log(Gamma(x)) is returned, 
    which is equivalent to log(|Gamma(x)|). 
    The function is computed using the real Lanczos method.
--- GSL::Sf::lngamma_sgn_e(x)
    Computes the sign of the gamma function and the logarithm its magnitude, 
    subject to ((|x|)) not being a negative integer, and returns the result
    as an array of 2 elements, ((|[result, sng]|)). The function is computed 
    using the real Lanczos method. The value of the gamma function can be 
    reconstructed using the relation Gamma(x) = sgn * exp(result).
--- GSL::Sf::gammastar(x)
    Computes the regulated Gamma Function Gamma^*(x) for x > 0. 
    The regulated gamma function is given by,
       Gamma^*(x) = Gamma(x)/(sqrt{2 pi} x^{(x-1/2)} exp(-x))
                  = (1 + (1/12x) + ...)  for x -> infty
    and is a useful suggestion of Temme.
--- GSL::Sf::gammainv(x)
    Computes the reciprocal of the gamma function, 1/Gamma(x) using the real Lanczos method.
--- GSL::Sf::ngamma_complex_e(zr, zi)
    These method compute log(Gamma(z)) for complex z = zr + i zi and z not a 
    negative integer, 
    using the complex Lanczos method. The result is returned as an array of 
    2 elements, ((|[lnr, arg, status]|)), where lnr = log|Gamma(z)| and arg = arg(Gamma(z)) 
    in (-pi,pi]. Note that the phase part (arg) is not well-determined when 
    |z| is very large, due to inevitable roundoff in restricting to (-pi,pi]. 
    This will result in a (({GSL::ELOSS})) error when it occurs. 
    The absolute value part (lnr), however, never suffers from loss of precision.
--- GSL::Sf::taylorcoeff(n, x)
    Computes the Taylor coefficient x^n / n! for x >= 0, n >= 0.
--- GSL::Sf::fact(n)
    Computes the factorial n!. The factorial is related to the 
    Gamma function by n! = Gamma(n+1).
--- GSL::Sf::doublefact(n)
    Computes the double factorial n!! = n(n-2)(n-4)... .
--- GSL::Sf::lnfact(n)
    Computes the logarithm of the factorial of ((|n|)), log(n!). 
    The algorithm is faster than computing ln(Gamma(n+1)) via 
    (({GSL::Sf::lngamma})) for n < 170, but defers for larger n.
--- GSL::Sf::lndoublefact(n)
    Computes the logarithm of the double factorial of n, log(n!!).
--- GSL::Sf::choose(n, m)
    Computes the combinatorial factor n choose m = n!/(m!(n-m)!).
--- GSL::Sf::lnchoose(n, m)
    Computes the logarithm of n choose m. 
    This is equivalent to the sum log(n!) - log(m!) - log((n-m)!).
--- GSL::Sf::poch(a, x)
    Computes the Pochhammer symbol (a)_x := Gamma(a + x)/Gamma(a), 
    subject to ((|a|)) and ((|a+x|)) not being negative integers. 
    The Pochhammer symbol is also known as the Apell symbol.
--- GSL::Sf::lnpoch(a, x)
    Computes the logarithm of the Pochhammer symbol, 
    log((a)_x) = log(Gamma(a + x)/Gamma(a)) for a > 0, a+x > 0.
--- GSL::Sf::lnpoch_sgn_e(a, x)
    Computes the sign of the Pochhammer symbol and the logarithm of its magnitude,
    subject to a, a+x not being negative integers.
    The result is returned as an array of 2 elements, ((|[result, sng]|)),
    where result = log(|(a)_x|), sgn = sgn((a)_x), and
    (a)_x := Gamma(a + x)/Gamma(a).
--- GSL::Sf::pochrel(a, x)
    Computes the relative Pochhammer symbol ((a,x) - 1)/x
    where (a,x) = (a)_x := Gamma(a + x)/Gamma(a).
--- GSL::Sf::gamma_inc_Q(a, x)
    Computes the normalized incomplete Gamma Function 
    Q(a,x) = 1/Gamma(a) int_x^infty dt t^{a-1} exp(-t) for a > 0, x >= 0.
--- GSL::Sf::gamma_inc_P(a, x)
    Computes the complementary normalized incomplete Gamma Function 
    P(a,x) = 1/Gamma(a) int_0^x dt t^{a-1} exp(-t) for a > 0, x >= 0.
    Note that Abramowitz & Stegun call P(a,x) the incomplete gamma function (section 6.5).
--- GSL::Sf::gamma_inc(a, x)
    Computes the incomplete Gamma Function the normalization factor included 
    in the previously defined functions: 
    Gamma(a,x) = int_x^infty dt t^{a-1} exp(-t) for a real and x >= 0.
--- GSL::Sf::beta(a, b)
    Computes the Beta Function, B(a,b) = Gamma(a)Gamma(b)/Gamma(a+b) for a > 0, b > 0.
--- GSL::Sf::lnbeta(a, b)
    Computes the logarithm of the Beta Function, log(B(a,b)) for a > 0, b > 0.
--- GSL::Sf::beta_inc(a, b, x)
    Computes the normalize incomplete Beta function 
    B_x(a,b)/B(a,b) for a > 0, b > 0, and 0 <= x <= 1.

== Gegenbauer Functions
--- GSL::Sf::gegenpoly_1(lambda, x)
--- GSL::Sf::gegenpoly_2(lambda, x)
--- GSL::Sf::gegenpoly_3(lambda, x)
    These methods evaluate the Gegenbauer polynomials 
    C^{(lambda)}_n(x) using explicit representations for n =1, 2, 3.
--- GSL::Sf::gegenpoly_n(n, lambda, x)
    This evaluates the Gegenbauer polynomial 
    C^{(lambda)}_n(x) for a specific value of ((|n, lambda, x|)) 
    subject to lambda > -1/2, n >= 0.
--- GSL::Sf::gegenpoly_array(nmax, lambda, x)
    This method computes Gegenbauer polynomials C^{(lambda)}_n(x) 
    for n = 0, 1, 2, ..., nmax, subject to lambda > -1/2, nmax >= 0.
    The result is returned as a (({GSL::Vector})) object.

== Hypergeometric Functions
--- GSL::Sf::hyperg_0F1(c, x)
    Computes the hypergeometric function 0F1(c, x).
--- GSL::Sf::hyperg_1F1_int(m, n, x)
    Computes the confluent hypergeometric function 1F1(m,n,x) = M(m,n,x) 
    for integer parameters ((|m, n|)).
--- GSL::Sf::hyperg_1F1(a, b, x)
    Computes the confluent hypergeometric function 1F1(a,b,x) = M(a,b,x) 
    for general parameters ((|a, b|)).
--- GSL::Sf::hyperg_U_int(m, n, x)
    Computes the confluent hypergeometric function U(m,n,x) for integer parameters 
    ((|m, n|)).
--- GSL::Sf::hyperg_U_int_e10_e(m, n, x)
    Computes the confluent hypergeometric function U(m,n,x) 
    for integer parameters ((|m, n|)) using the (({GSL::Sf::Result_e10})) 
    type to return a result with extended range.
--- GSL::Sf::hyperg_U(a, b, x)
    Computes the confluent hypergeometric function U(a,b,x).
--- GSL::Sf::hyperg_U_e10_e(a, b, x)
    Computes the confluent hypergeometric function U(a,b,x) 
    using the (({GSL::Sf::Result_e10}))  type to return a result with extended range.
--- GSL::Sf::hyperg_2F1(a, b, c, x)
--- GSL::Sf::hyperg_2F1_e(a, b, c, x)
    These methods compute the Gauss hypergeometric function 2F1(a,b,c,x) for |x| < 1.
    If the arguments (a,b,c,x) are too close to a singularity then the 
    function can return the error code (({GSL::EMAXITER})) when the series 
    approximation converges too slowly. This occurs in the region of 
    x=1, c - a - b = m for integer m.
--- GSL::Sf::hyperg_2F1_conj(aR, aI, c, x)
    Computes the Gauss hypergeometric function 2F1(a_R + i a_I, a_R - i a_I, c, x) 
    with complex parameters for |x| < 1. 
--- GSL::Sf::hyperg_2F1_renorm(a, b, c, x)
    Computes the renormalized Gauss hypergeometric function 
    2F1(a,b,c,x) / Gamma(c) for |x| < 1.
--- GSL::Sf::hyperg_2F1_renorm(aR, aI, c, x)
    Computes the renormalized Gauss hypergeometric function 
    2F1(a_R + i a_I, a_R - i a_I, c, x) / Gamma(c) for |x| < 1.
--- GSL::Sf::hyperg_2F0(a, b, x)
    Computes the hypergeometric function 2F0(a,b,x). 
    The series representation is a divergent hypergeometric series. 
    However, for x < 0 we have 2F0(a,b,x) = (-1/x)^a U(a,1+a-b,-1/x).

== Laguerre Functions
The Laguerre polynomials are defined in terms of confluent hypergeometric 
functions as L^a_n(x) = ((a+1)_n / n!) 1F1(-n,a+1,x).
--- GSL::Sf::laguerre_1(a, x)
--- GSL::Sf::laguerre_2(a, x)
--- GSL::Sf::laguerre_3(a, x)
    These methods evaluate the generalized Laguerre polynomials 
    L^a_1(x), L^a_2(x), L^a_3(x) using explicit representations.
--- GSL::Sf::laguerre_n(n, a, x)
    This evaluates the generalized Laguerre polynomials L^a_n(x) for a > -1, n >= 0.

== Lambert W Functions
Lambert's W functions, W(x), are defined to be solutions of the equation 
W(x) exp(W(x)) = x. This function has multiple branches for x < 0; 
however, it has only two real-valued branches. 
We define W_0(x) to be the principal branch, 
where W > -1 for x < 0, and W_{-1}(x) to be the other real branch, where W < -1 for x < 0. 

--- GSL::Sf::lambert_W0(x)
    This computes the principal branch of the Lambert W function, W_0(x).
--- GSL::Sf::lambert_Wm1(x)
    This computes the secondary real-valued branch of the Lambert W function, W_{-1}(x).

== Legendre Functions and Spherical Harmonics
=== Legendre Polynomials
--- GSL::Sf::legendre_P1(x)
--- GSL::Sf::legendre_P2(x)
--- GSL::Sf::legendre_P3(x)
    These methods evaluate the Legendre polynomials P_l(x) using explicit 
    representations for l=1, 2, 3.
--- GSL::Sf::legendre_Pl(l, x)
    This evaluates the Legendre polynomial P_l(x) for a specific value of ((|l, x|)), 
    subject to l >= 0, |x| <= 1.
--- GSL::Sf::legendre_Pl_array(lmax, x)
    This function computes Legendre polynomials P_l(x) for l = 0, ..., lmax, 
    and returns the result as a (({GSL::Vector})) object.
--- GSL::Sf::legendre_Q0(x)
    This computes the Legendre function Q_0(x) for x > -1, x != 1.
--- GSL::Sf::legendre_Q1(x)
    This computes the Legendre function Q_1(x) for x > -1, x != 1.
--- GSL::Sf::legendre_Ql(l, x)
    This computes the Legendre function Q_l(x) for x > -1, x != 1 and l >= 0.

=== Associated Legendre Polynomials and Spherical Harmonics
The following functions compute the associated Legendre Polynomials P_l^m(x). 
Note that this function grows combinatorially with ((|l|)) and can overflow for 
((|l|)) larger than about 150. There is no trouble for small ((|m|)), 
but overflow occurs when ((|m|)) and ((|l|)) are both large. 
Rather than allow overflows, these functions refuse to calculate P_l^m(x) 
and return (({GSL::EOVRFLW})) when they can sense that ((|l|)) and ((|m|)) are too big.
If you want to calculate a spherical harmonic, then do not use these functions. 
Instead use (({GSL::Sf::legendre_sphPlm()})) below, 
which uses a similar recursion, but with the normalized functions.

--- GSL::Sf::legendre_Plm(l, m, x)
--- GSL::Sf::legendre_Plm_e(l, m, x)
    These methods compute the associated Legendre polynomial 
    P_l^m(x) for m >= 0, l >= m, |x| <= 1.
--- GSL::Sf::legendre_Plm_array(lmax, m, x)
    This method computes Legendre polynomials P_l^m(x) for m >= 0, l = |m|, ..., lmax, 
    |x| <= 1, and returns the result as a (({GSL::Vector})) object.
--- GSL::Sf::legendre_sphPlm(l, m, x)
--- GSL::Sf::legendre_sphPlm_e(l, m, x)
    These methods compute the normalized associated Legendre polynomial 
    sqrt{(2l+1)/(4pi)} sqrt{(l-m)!/(l+m)!} P_l^m(x) 
    suitable for use in spherical harmonics. The parameters must satisfy 
    m >= 0, l >= m, |x| <= 1. Theses routines avoid the overflows that 
    occur for the standard normalization of P_l^m(x).
--- GSL::Sf::legendre_sphPlm_array(lmax, m, x)
    This method computes an array of normalized associated Legendre functions 
    sqrt{(2l+1)/(4pi)} sqrt{(l-m)!/(l+m)!} P_l^m(x)$ for m >= 0, l = |m|, ..., lmax, 
    |x| <= 1.0, and returns the result as a (({GSL::Vector})) object.
--- GSL::Sf::legendre_array_size(lmax, m)
    This returns the size of resulting array needed for the array versions 
    of P_l^m(x), lmax - m + 1.

=== Conical Functions
The Conical Functions P^mu_{-(1/2)+i lambda}(x), Q^mu_{-(1/2)+i lambda} 
are described in Abramowitz & Stegun, Section 8.12.

--- GSL::Sf::conicalP_half(lambda, x)
    Computes the irregular Spherical Conical Function 
    P^{1/2}_{-1/2 + i lambda}(x) for x > -1.
--- GSL::Sf::conicalP_mhalf(lambda, x)
    Computes the regular Spherical Conical Function 
    P^{-1/2}_{-1/2 + i lambda}(x) for x > -1.
--- GSL::Sf::conicalP_0(lambda, x)
--- GSL::Sf::conicalP_1(lambda, x)
    These methods compute the conical function P^0_{-1/2 + i lambda}(x),
    P^1_{-1/2 + i lambda}(x)for x > -1.
--- GSL::Sf::conicalP_sph_reg(l, lambda, x)
    Computes the Regular Spherical Conical Function 
    P^{-1/2-l}_{-1/2 + i lambda}(x) for x > -1, l >= -1.
--- GSL::Sf::conicalP_cyc_reg(m, lambda, x)
    Computes the Regular Cylindrical Conical Function
    P^{-m}_{-1/2 + i lambda}(x) for x > -1, m >= -1.

=== Radial Functions for Hyperbolic Space
The following spherical functions are specializations of Legendre functions which 
give the regular eigenfunctions of the Laplacian on a 3-dimensional hyperbolic space 
H3d. Of particular interest is the flat limit, lambda to infty, eta to 0, lambda eta fixed.
--- GSL::Sf::legendre_H3d_0(lambda, eta)
    Computes the zeroth radial eigenfunction of the Laplacian on the 3-dimensional 
    hyperbolic space, L^{H3d}_0(lambda,eta) := sin(lambda eta)/(lambda sinh(eta)) 
    for eta >= 0. In the flat limit this takes the form 
    L^{H3d}_0(lambda, eta) = j_0( lambda eta).
--- GSL::Sf::legendre_H3d_1(lambda, eta)
    Computes the first radial eigenfunction of the Laplacian on the 3-dimensional 
    hyperbolic space, 
    L^{H3d}_1(lambda, eta) := 1/sqrt{lambda^2 + 1} sin(lambda eta)/(lambda sinh(eta)) (coth(eta) - lambda cot(lambda eta)) for eta >= 0. 
    In the flat limit this takes the form L^{H3d}_1(lambda, eta) = j_1( lambda eta).
--- GSL::Sf::legendre_H3d(l, lambda, eta)
    Computes the ((|l|))-th radial eigenfunction of the Laplacian on the 
    3-dimensional hyperbolic space eta >= 0, l >= 0. 
    In the flat limit this takes the form L^{H3d}_l(lambda, eta) = j_l(lambda eta).
--- GSL::Sf::legendre_H3d_array(lmax, lambda, eta)
    This method computes radial eigenfunctions L^{H3d}_l(lambda, eta) for 0 <= l <= lmax,
    and returns the result as a (({GSL::Vector})) object.

== Logarithm and Related Functions
--- GSL::Sf::log(x)
    Computes the logarithm of ((|x|)), log(x), for x > 0.
--- GSL::Sf::log_abs(x)
    Computes the logarithm of the magnitude of ((|x|)), log(|x|), for x != 0.
--- GSL::Sf::complex_log_e(zr, zi)
--- GSL::Sf::complex_log_e(z)
    This method computes the complex logarithm of z = z_r + i z_i. 
    The results are returned as an array ((|[lnr, theta]|)) such that 
    exp(lnr + i theta) = z_r + i z_i, where theta lies in the range [-pi, pi].
--- GSL::Sf::log_1plusx(x)
    Computes log(1 + x) for x > -1 using an algorithm that is accurate for small x.
--- GSL::Sf::log_1plusx_mx(x)
    Computes log(1 + x) - x for x > -1 using an algorithm that is accurate for small x.

== Mathieu functions
The methods described in this section compute the angular and radial Mathieu functions, and their characteristic values. Mathieu functions are the solutions of the following two differential equations: The angular Mathieu functions ce_r(x,q), se_r(x,q) are the even and odd periodic solutions of the first equation, which is known as Mathieu's equation. These exist only for the discrete sequence of characteristic values a=a_r(q) (even-periodic) and a=b_r(q) (odd-periodic). 

The radial Mathieu functions Mc^{(j)}_{r}(z,q), Ms^{(j)}_{r}(z,q) are the solutions of the second equation, which is referred to as Mathieu's modified equation. The radial Mathieu functions of the first, second, third and fourth kind are denoted by the parameter ((|j|)), which takes the value 1, 2, 3 or 4. 

For more information on the Mathieu functions, see Abramowitz and Stegun, Chapter 20. 

=== Mathieu Function Workspace 
The Mathieu functions can be computed for a single order or for multiple orders, using array-based routines.
--- GSL::Sf::Mathieu.alloc(n, qmax)
    This method returns a workspace for the array versions of the Mathieu routines. The arguments ((|n|)) and ((|qmax|)) specify the maximum order and q-value of Mathieu functions which can be computed with this workspace. 

=== Mathieu Function Characteristic Values 
--- GSL::Sf::mathieu_a(n, q)
--- GSL::Sf::mathieu_a_e(n, q)
--- GSL::Sf::mathieu_b(n, q)
--- GSL::Sf::mathieu_b_e(n, q)
    These methodss compute the characteristic values a_n(q), b_n(q) of the Mathieu functions ce_n(q,x) and se_n(q,x), respectively. 

--- GSL::Sf::mathieu_a_array(nmin, nmax, q, work)
--- GSL::Sf::mathieu_b_array(nminm nmax, q, work)
    These methods compute a series of Mathieu characteristic values a_n(q), b_n(q) for n from ((|nmin|)) to ((|nmax|)) inclusive, and return the results as a (({GSL::Vector})) object.

=== Angular Mathieu Functions 
--- GSL::Sf::mathieu_ce(n, q, x)
--- GSL::Sf::mathieu_ce_e(n, q, x)
--- GSL::Sf::mathieu_se(n, q, x)
--- GSL::Sf::mathieu_se_e(n, q, x)
    These methods compute the angular Mathieu functions ce_n(q,x) and se_n(q,x), respectively. 

--- GSL::Sf::mathieu_ce_array(nmin, nmax, q, x, work)
--- GSL::Sf::mathieu_se_array(nmin, nmax, q, x, work)
    These methods compute a series of the angular Mathieu functions ce_n(q,x) and se_n(q,x) of order n from ((|nmin|)) to ((|nmax|)) inclusive, and return the results as a (({GSL::Vector})) object.
    
=== Radial Mathieu Functions 
--- GSL::Sf::mathieu_Mc(j, n, q, x)
--- GSL::Sf::mathieu_Mc_e(j, n, q, x)
--- GSL::Sf::mathieu_Ms(j, n, q, x)
--- GSL::Sf::mathieu_Ms_e(j, n, q, x)
    These methods compute the radial ((|j|))-th kind Mathieu functions Mc_n^{(j)}(q,x) and Ms_n^{(j)}(q,x) of order ((|n|)). 

    The allowed values of ((|j|)) are 1 and 2. The functions for ((|j = 3,4|)) can be computed as M_n^{(3)} = M_n^{(1)} + iM_n^{(2)} and M_n^{(4)} = M_n^{(1)} - iM_n^{(2)}, where M_n^{(j)} = Mc_n^{(j)} or Ms_n^{(j)}. 

--- GSL::Sf::mathieu_Mc_array(j, nmin, nmax, q, x, work)
--- GSL::Sf::mathieu_Ms_array(j, nmin, nmax, q, x, work)
    These methods compute a series of the radial Mathieu functions of kind ((|j|)), with order from ((|nmin|)) to ((|nmax|)) inclusive, and return the results as a (({GSL::Vector})) object.

== Power Functions
--- GSL::Sf::pow_int(x, n)
--- GSL::Sf::pow_int_e(x, n)
    These methods compute the power x^n for integer n. The power is computed using 
    the minimum number of multiplications. For example, x^8 is computed as 
    ((x^2)^2)^2, requiring only 3 multiplications. For reasons of efficiency, 
    these functions do not check for overflow or underflow conditions.

== Psi (Digamma) Function
The polygamma functions of order ((|m|)) defined by 
psi^{(m)}(x) = (d/dx)^m psi(x) = (d/dx)^{m+1} log(Gamma(x)), 
where psi(x) = Gamma'(x)/Gamma(x) is known as the digamma function.

=== Digamma Function
--- GSL::Sf::psi_int(n)
    Computes the digamma function psi(n) for positive integer ((|n|)). 
    The digamma function is also called the Psi function.
--- GSL::Sf::psi(x)
    Computes the digamma function psi(x) for general x, x != 0.
--- GSL::Sf::psi_1piy(x)
    Computes the real part of the digamma function on the line 1+i y, Re[psi(1 + i y)].

=== Trigamma Function
--- GSL::Sf::psi_1_int(n)
    Computes the Trigamma function psi'(n) for positive integer ((|n|)).
--- GSL::Sf::psi_1(x)
    Computes the Trigamma function psi'(x) for general ((|x|)).

=== Polygamma Function
--- GSL::Sf::psi_n(m, x)
    Computes the polygamma function psi^{(m)}(x) for m >= 0, x > 0.

== Synchrotron Functions
--- GSL::Sf::synchrotron_1(x)
    Computes the first synchrotron function x int_x^infty dt K_{5/3}(t) for x >= 0.

--- GSL::Sf::synchrotron_2(x)
    Computes the second synchrotron function x K_{2/3}(x) for x >= 0.

== Transport Functions
The transport functions J(n,x) are defined by the integral representations 
J(n,x) := int_0^x dt t^n e^t /(e^t - 1)^2.

--- GSL::Sf::transport_2(x)
--- GSL::Sf::transport_3(x)
--- GSL::Sf::transport_4(x)
--- GSL::Sf::transport_5(x)
    These methods compute the transport function J(n, x), for n = 2, 3, 4, and 5.

== Trigonometric Functions
=== Circular Trigonometric Functions
--- GSL::Sf::sin(x)
--- GSL::Sf::cos(x)
--- GSL::Sf::hypot(x, y)
    sqrt{x^2 + y^2}
--- GSL::Sf::sinc(x)
    sinc(x) = sin(pi x) / (pi x)

=== Trigonometric Functions for Complex Arguments
--- GSL::Sf::complex_sin_e(zr, zi)
--- GSL::Sf::complex_sin_e(z)
--- GSL::Sf::complex_cos_e(zr, zi)
--- GSL::Sf::complex_cos_e(z)
--- GSL::Sf::complex_logsin_e(zr, zi)
--- GSL::Sf::complex_logsin_e(z)

=== Hyperbolic Trigonometric Functions
--- GSL::Sf::lnsinh(x)
--- GSL::Sf::lncosh(x)

=== Conversion Functions
--- GSL::Sf::polar_to_rect(r, theta)
--- GSL::Sf::rect_to_polar(x, y)

=== Restriction Functions
--- GSL::Sf::angle_restrict_symm(theta)
    This forces the angle ((|theta|)) to lie in the range (-pi, pi].
--- GSL::Sf::angle_restrict_pos(theta)
    This forces the angle ((|theta|)) to lie in the range [0, 2pi).

=== Trigonometric Functions With Error Estimates
--- GSL::Sf::sin_err(x, dx)
    Computes the sine of an angle ((|x|)) with an associated absolute error ((|dx|)), 
    sin(x +- dx).
--- GSL::Sf::cos_err(x, dx)
    Computes the cosine of an angle ((|x|)) with an associated absolute error ((|dx|)), 
    cos(x +- dx).

== Zeta Functions
=== Riemann Zeta Function
The Riemann zeta function is defined by the infinite sum 
zeta(s) = sum_{k=1}^infty k^{-s}.

--- GSL::Sf::zeta_int(n)
    Computes the Riemann zeta function zeta(n) for integer n, n != 1.
--- GSL::Sf::zeta(s)
    Computes the Riemann zeta function zeta(s) for arbitrary s, s != 1.

=== Riemann Zeta Function Minus One
--- GSL::Sf::zetam1_int(n)
    Computes zeta(n) - 1 for integer n, n != 1.
--- GSL::Sf::zetam1(s)
    Computes zeta(s) - 1 for arbitrary s, s != 1.

=== Hurwitz Zeta Function
The Hurwitz zeta function is defined by zeta(s,q) = sum_0^infty (k+q)^{-s}.
--- GSL::Sf::hzeta(s, q)
    Computes the Hurwitz zeta function zeta(s,q) for s > 1, q > 0.

=== Eta Function
The eta function is defined by eta(s) = (1-2^{1-s}) zeta(s).
--- GSL::Sf::eta_int(n)
    Computes the eta function eta(n) for integer n.
--- GSL::Sf::eta(s)
    Computes the eta function eta(s) for arbitrary s.

((<prev|URL:poly.html>))
((<next|URL:vector.html>))

((<Reference index|URL:ref.html>))
((<top|URL:index.html>))

=end
