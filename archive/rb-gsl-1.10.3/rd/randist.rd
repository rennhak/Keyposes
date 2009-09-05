=begin
= Random Number Distributions
This chapter describes functions for generating random variates and computing 
their probability distributions. Samples from the distributions described 
in this chapter can be obtained using any of the random number generators 
in the library as an underlying source of randomness. 

In the simplest cases a non-uniform distribution can be obtained analytically 
from the uniform distribution of a random number generator by applying an 
appropriate transformation. This method uses one call to the random number
generator. More complicated distributions are created by the 
acceptance-rejection method, which compares the desired distribution against
a distribution which is similar and known analytically. This usually requires 
several samples from the generator. 

The library also provides cumulative distribution functions and inverse 
cumulative distribution functions, sometimes referred to as quantile 
functions. The cumulative distribution functions and their inverses are 
computed separately for the upper and lower tails of the distribution, 
allowing full accuracy to be retained for small results. 

Contents:
(1) ((<Introduction|URL:randist.html#1>))
(2) ((<The Gaussian Distribution|URL:randist.html#2>))
(3) ((<The Gaussian Tail Distribution|URL:randist.html#3>))
 ...
and more, see ((<the GSL reference|URL:http://www.gnu.org/software/gsl/manual/>))
(4) ((<Shuffling and Sampling|URL:randist.html#7>))

== Introduction
Continuous random number distributions are defined by a probability density 
function, p(x), such that the probability of x occurring in the 
infinitesimal range x to x+dx is p dx. 

The cumulative distribution function for the lower tail P(x) is defined by the 
integral, and gives the probability of a variate taking a value less than x. 

The cumulative distribution function for the upper tail Q(x) is defined by the 
integral, and gives the probability of a variate taking a value greater than 
x. 

The upper and lower cumulative distribution functions are related 
by P(x) + Q(x) = 1 and satisfy 0 <= P(x) <= 1, 0 <= Q(x) <= 1. 

The inverse cumulative distributions, x=P^{-1}(P) and x=Q^{-1}(Q) give the 
values of x which correspond to a specific value of P or Q. They can be used 
to find confidence limits from probability values. 

For discrete distributions the probability of sampling the integer value k is 
given by p(k), where \sum_k p(k) = 1. The cumulative distribution for the 
lower tail P(k) of a discrete distribution is defined as, where the sum is 
over the allowed range of the distribution less than or equal to k. 

The cumulative distribution for the upper tail of a discrete distribution Q(k)
is defined as giving the sum of probabilities for all values greater than k. 
These two definitions satisfy the identity P(k)+Q(k)=1. 

If the range of the distribution is 1 to n inclusive then P(n)=1, Q(n)=0 
while P(1) = p(1), Q(1)=1-p(1). 



== The Gaussian Distribution
--- GSL::Rng#gaussian(sigma = 1)
--- GSL::Ran::gaussian(rng, sigma = 1)
--- GSL::Rng#ugaussian
--- GSL::Ran::ugaussian
    These return a Gaussian random variate, with mean zero and standard 
    deviation ((|sigma|)). 

--- GSL::Ran::gaussian_pdf(x, sigma = 1)
    Computes the probability density p(x) at ((|x|)) for a Gaussian distribution 
    with standard deviation ((|sigma|)).

--- GSL::Rng#gaussian_ratio_method(sigma = 1)
--- GSL::Ran::gaussian_ratio_method(rng, sigma = 1)
    Use Kinderman-Monahan ratio method.

--- GSL::Cdf::gaussian_P(x, sigma = 1)
--- GSL::Cdf::gaussian_Q(x, sigma = 1)
--- GSL::Cdf::gaussian_Pinv(P, sigma = 1)
--- GSL::Cdf::gaussian_Qinv(Q, sigma = 1)
--- GSL::Cdf::ugaussian_P(x)
--- GSL::Cdf::ugaussian_Q(x)
--- GSL::Cdf::ugaussian_Pinv(P)
--- GSL::Cdf::ugaussian_Qinv(Q)
    These methods compute the cumulative distribution functions P(x), Q(x) 
    and their inverses for the Gaussian distribution with standard 
    deviation ((|sigma|)).

== The Gaussian Tail Distribution
--- GSL::Rng#gaussian_tail(a, sigma = 1)
--- GSL::Ran#gaussian_tail(rng, a, sigma = 1)
--- GSL::Rng#ugaussian_tail(a)
--- GSL::Ran#ugaussian_tail(rng)
    These methods provide random variates from the upper tail of a Gaussian 
    distribution with standard deviation ((|sigma|)). 
    The values returned are larger than the lower limit ((|a|)), which must be positive.

--- GSL::Ran::gaussian_tail_pdf(x, a, sigma = 1)
--- GSL::Ran::ugaussian_tail_pdf(x, a)
    These methods compute the probability density p(x) at ((|x|)) for a Gaussian 
    tail distribution with standard deviation ((|sigma|)) 
    and lower limit ((|a|)).

== The Bivariate Gaussian Distribution
--- GSL::Rng#bivariate_gaussian(sigma_x, sigma_y, rho)
--- GSL::Ran::bivariate_gaussian(rng, sigma_x, sigma_y, rho)
    These methods generate a pair of correlated gaussian variates, 
    with mean zero, correlation coefficient ((|rho|)) and standard deviations 
    ((|sigma_x|)) and ((|sigma_y|)) in the x and y directions.

--- GSL::Ran::bivariate_gaussian_pdf(x, y, sigma_x, sigma_y, rho)
    This method computes the probability density p(x,y) at ((|(x,y)|)) 
    for a bivariate gaussian distribution with standard deviations 
    ((|sigma_x, sigma_y|)) and correlation coefficient ((|rho|)).

== The Exponential Distribution
--- GSL::Rng#exponential(mu)
--- GSL::Ran::exponential(rng, mu)
    These methods return a random variate from the exponential 
    distribution with mean ((|mu|)).

--- GSL::Ran::exponential_pdf(x, mu)
    This method computes the probability density p(x) at ((|x|)) 
    for an exponential distribution with mean ((|mu|)).

--- GSL::Cdf::exponential_P(x, mu)
--- GSL::Cdf::exponential_Q(x, mu)
--- GSL::Cdf::exponential_Pinv(P, mu)
--- GSL::Cdf::exponential_Qinv(Q, mu)
    These methods compute the cumulative distribution functions P(x), Q(x) 
    and their inverses for the exponential distribution with mean ((|mu|)).

==  The Laplace Distribution
--- GSL::Rng#laplace(a)
--- GSL::Ran::laplace(rng, a)
    These methods return a random variate from the Laplace distribution 
    with width ((|a|)).

--- GSL::Ran::laplace_pdf(x, a)
    This method computes the probability density p(x) at ((|x|)) 
    for a Laplace distribution with width ((|a|)).

--- GSL::Cdf::laplace_P(x, a)
--- GSL::Cdf::laplace_Q(x, a)
--- GSL::Cdf::laplace_Pinv(P, a)
--- GSL::Cdf::laplace_Qinv(Q, a)
    These methods compute the cumulative distribution functions P(x), Q(x) 
    and their inverses for the Laplace distribution with width ((|a|)).

--- GSL::Rng#exppow(a, b)
--- GSL::Rng#cauchy(a)
--- GSL::Rng#rayleigh(sigma)
--- GSL::Rng#rayleigh_tail(a, sigma)
--- GSL::Rng#landau()
--- GSL::Rng#levy(c, alpha)
--- GSL::Rng#levy_skew(c, alpha, beta)
--- GSL::Rng#gamma(a, b)
--- GSL::Rng#flat(a, b)
--- GSL::Rng#lognormal(zeta, sigma)
--- GSL::Rng#chisq(nu)
--- GSL::Rng#fdist(nu1, nu2)
--- GSL::Rng#tdist(nu)
--- GSL::Rng#beta(a, b)
--- GSL::Rng#logistic(a)
--- GSL::Rng#pareto(a, b)

...

and more, see ((<the GSL reference|URL:http://www.gnu.org/software/gsl/manual/gsl-ref_19.html#SEC286>)).

==  Shuffling and Sampling
--- GSL::Rng#shuffle(v, n)
    This randomly shuffles the order of ((|n|)) objects, 
    stored in the ((<GSL::Vector|URL:vector.html>)) object ((|v|)). 
--- GSL::Rng#choose(v, k)
    This returns a ((<GSL::Vector|URL:vector.html>)) object with ((|k|)) objects 
    taken randomly from the ((<GSL::Vector|URL:vector.html>)) object ((|v|)). 

    The objects are sampled without replacement, thus each object can only 
    appear once in the returned vector. It is required that ((|k|)) be less 
    than or equal to the length of the vector ((|v|)). 

--- GSL::Rng#sample(v, k)
    This method is like the method (({choose})) but samples ((|k|)) items 
    from the original vector ((|v|)) with replacement, so the same object 
    can appear more than once in the output sequence. There is no requirement 
    that ((|k|)) be less than the length of ((|v|)).

((<prev|URL:qrng.html>))
((<next|URL:stats.html>))

((<Reference index|URL:ref.html>))
((<top|URL:index.html>))
    
=end
