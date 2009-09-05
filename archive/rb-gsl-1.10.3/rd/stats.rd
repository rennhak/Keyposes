=begin
= Statistics
(1) ((<Mean, Standard Deviation and Variance|URL:stats.html#1>))
(2) ((<Absolute deviation|URL:stats.html#2>))
(3) ((<Higher moments (skewness and kurtosis)|URL:stats.html#3>))
(4) ((<Autocorrelation|URL:stats.html#4>))
(5) ((<Covariance|URL:stats.html#5>))
(6) ((<Correlation|URL:stats.html#6>))
(7) ((<Weighted samples|URL:stats.html#7>))
(8) ((<Maximum and minimum values|URL:stats.html#8>))
(9) ((<Median and percentiles|URL:stats.html#9>))
(10) ((<Examples|URL:stats.html#10>))

== Mean, Standard Deviation and Variance

--- GSL::Stats::mean(v)
--- GSL::Vector#mean
    Arithmetic mean.

    * Ex:
         irb(main):001:0> require("gsl")
         => true
         irb(main):002:0> v = Vector[1..7]
         => GSL::Vector: 
         [ 1.000e+00 2.000e+00 3.000e+00 4.000e+00 5.000e+00 6.000e+00 7.000e+00 ]
         irb(main):003:0> v.mean
         => 4.0
         irb(main):004:0> Stats::mean(v)
         => 4.0

--- GSL::Stats::variance_m(v[, mean])
--- GSL::Vector#variance_m([mean])
    Variance of ((|v|)) relative to the given value of ((|mean|)).

--- GSL::Stats::sd(v[, mean])
--- GSL::Vector#sd([mean])
    Standard deviation.

--- GSL::Stats::variance_with_fixed_mean(v, mean)
--- GSL::Vector#variance_with_fixed_mean(mean)
    Unbiased estimate of the variance of ((|v|)) when the population mean 
    ((|mean|)) of the underlying distribution is known ((|a priori|)).

--- GSL::Stats::variance_with_fixed_mean(v, mean)
--- GSL::Vector#variance_with_fixed_mean(mean)
--- GSL::Stats::sd_with_fixed_mean(v, mean)
--- GSL::Vector#sd_with_fixed_mean(mean)
    Unbiased estimate of the variance of ((|v|)) when the population mean 
    ((|mean|)) of the underlying distribution is known ((|a priori|)).

== Absolute deviation 
--- GSL::Stats::absdev(v[, mean])
--- GSL::Vector#absdev([mean])
    Compute the absolute deviation (from the mean ((|mean|)) if given).

== Higher moments (skewness and kurtosis) 

--- GSL::Stats::skew(v[, mean, sd])
--- GSL::Vector#skew([mean, sd])
    Skewness

--- GSL::Stats::kurtosis(v[, mean, sd])
--- GSL::Vector#kurtosis([mean, sd])
    Kurtosis

== Autocorrelation
--- GSL::Stats::lag1_autocorrelation(v[, mean])
--- GSL::Vector#lag1_autocorrelation([mean])
    The lag-1 autocorrelation

== Covariance
--- GSL::Stats::covariance(v1, v2)
--- GSL::Stats::covariance_m(v1, v2, mean1, mean2)
    Covariance of vectors ((|v1, v2|)).

== Correlation
--- GSL::Stats::correlation(v1, v2)
    This efficiently computes the Pearson correlation coefficient between the vectors ((|v1, v2|)). (>= GSL-1.10)

== Weighted samples
--- GSL::Vector#wmean(w)
--- GSL::Vector#wvariance(w)
--- GSL::Vector#wsd(w)
--- GSL::Vector#wabsdev(w)
--- GSL::Vector#wskew(w)
--- GSL::Vector#wkurtosis(w)

== Maximum and Minimum values 
--- GSL::Stats::max(data)
--- GSL::Vector#max
    Return the maximum value in data.

--- GSL::Stats::min(data)
--- GSL::Vector#min
    Return the minimum value in data.

--- GSL::Stats::minmax(data)
--- GSL::Vectorminmax
    Find both the minimum and maximum values in ((|data|)) and returns them.

--- GSL::Stats::max_index(data)
--- GSL::Vector#max_index
    Return the index of the maximum value in ((|data|)). 
    The maximum value is defined as the value of the element x_i 
    which satisfies x_i >= x_j for all j. 
    When there are several equal maximum elements then the first one is chosen. 
--- GSL::Stats::min_index(data)
--- GSL::Vector#min_index
    Returns the index of the minimum value in ((|data|)). 
    The minimum value is defined as the value of the element x_i 
    which satisfies x_i >= x_j for all j. 
    When there are several equal minimum elements then the first one is 
    chosen. 

--- GSL::Stats::minmax_index(data)
--- GSL::Vector#minmax_index
    Return the indexes of the minimum and maximum values in ((|data|)) 
    in a single pass. 


== Median and Percentiles 

--- GSL::Stats::median_from_sorted_data(v)
--- GSL::Vector#median_from_sorted_data
    Return the median value. The elements of the data must be 
    in ascending numerical order. There are no checks to see whether 
    the data are sorted, so the method (({GSL::Vector#sort})) 
    should always be used first.

--- GSL::Stats::quantile_from_sorted_data(v)
--- GSL::Vector#quantile_from_sorted_data
    Return the quantile value. The elements of the data must be 
    in ascending numerical order. There are no checks to see whether 
    the data are sorted, so the method (({GSL::Vector#sort})) 
    should always be used first.

== Example

     #!/usr/bin/env ruby
     require 'gsl'

     ary =  [17.2, 18.1, 16.5, 18.3, 12.6]
     data = Vector.alloc(ary)
     mean     = data.mean()
     variance = data.stats_variance()
     largest  = data.stats_max()
     smallest = data.stats_min()

     printf("The dataset is %g, %g, %g, %g, %g\n",
            data[0], data[1], data[2], data[3], data[4]);

     printf("The sample mean is %g\n", mean);
     printf("The estimated variance is %g\n", variance);
     printf("The largest value is %g\n", largest);
     printf("The smallest value is %g\n", smallest);

((<prev|URL:randist.html>))
((<next|URL:hist.html>))

((<Reference index|URL:ref.html>))
((<top|URL:index.html>))
=end
