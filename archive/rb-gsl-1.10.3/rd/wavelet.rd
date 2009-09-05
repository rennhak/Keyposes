=begin
= Discrete Wavelet Transforms
This chapter describes functions for performing Discrete Wavelet Transforms 
(DWTs). 
The library includes wavelets for real data in both one and two dimensions. 

Contents:
(1) ((<Definitions|URL:wavelet.html#1>))
(2) ((<Initialization|URL:wavelet.html#2>))
(3) ((<Transform methods|URL:wavelet.html#3>))
    (1) ((<Wavelet transforms in one dimension|URL:wavelet.html#3.1>))
    (2) ((<Wavelet transforms in two dimension|URL:wavelet.html#3.2>))
(4) ((<Examples|URL:wavelet.html#4>))

== Definitions

The continuous wavelet transform and its inverse are defined by the relations,
and,
where the basis functionspsi_{s,tau} are obtained by scaling and translation 
from a single function, referred to as the mother wavelet.

The discrete version of the wavelet transform acts on evenly sampled data, 
with fixed scaling and translation steps (s, tau). The frequency and time 
axes are sampled dyadically on scales of 2^j through a level parameter j. 
The resulting family of functions {psi_{j,n}} constitutes an orthonormal 
basis for square-integrable signals.

The discrete wavelet transform is an O(N) algorithm, and is also referred to as 
the fast wavelet transform.

== Initialization

--- GSL::Wavelet.alloc(type, k)
--- GSL::Wavelet.alloc(type, k)
    This function allocates and initializes a wavelet object of type ((|type|)). 
    The parameter ((|k|)) selects the specific member of the wavelet family. 

    The wavelet types are given by a constant (Fixnum) or a string as followings.

    * (({GSL::Wavelet::DAUBECHIES})), or (({"daubechies"}))
    * (({GSL::Wavelet::DAUBECHIES_CENTERED})), or (({"daubechies_centered"}))
    * (({GSL::Wavelet::HAAR})), or (({"haar"}))
    * (({GSL::Wavelet::HAAR_CENTERED})), or (({"haar_centered"}))
    * (({GSL::Wavelet::BSPLINE})), or (({"bspline"}))
    * (({GSL::Wavelet::BSPLINE_CENTERED})), or (({"bspline_centered"}))

    The centered forms of the wavelets align the coefficients of the various 
    sub-bands on edges. Thus the resulting visualization of the coefficients 
    of the wavelet transform in the phase plane is easier to understand.

--- GSL::Wavelet#name
    This method returns a String of the name of the wavelet family for ((|self|)).

--- GSL::Wavelet::Workspace.alloc(n)
    The GSL::Wavelet::Workspace object contains scratch space of the same size as 
    the input data, for holding intermediate results during the transform.
    This method allocates a workspace for the discrete wavelet transform. 
    To perform a one-dimensional transform on ((|n|)) elements, a workspace of 
    size ((|n|)) must be provided. For two-dimensional transforms of n-by-n 
    matrices it is sufficient to allocate a workspace of size ((|n|)), 
    since the transform operates on individual rows and columns.

== Transform Methods
=== Wavelet transforms in one dimension

--- GSL::Wavelet.transform(w, v, dir = GSL::Wavelet::FORWARD, work)
--- GSL::Wavelet.transform(w, v, dir)
--- GSL::Wavelet.transform(w, v, work)
--- GSL::Wavelet.transform(w, v)
--- GSL::Wavelet#transform(v, dir = GSL::Wavelet::FORWARD, work)
--- GSL::Wavelet#transform(v, dir)
--- GSL::Wavelet#transform(v, work)
--- GSL::Wavelet#transform(v)
--- GSL::Wavelet.transform_forward(w, v, work)
--- GSL::Wavelet.transform_forward(w, v)
--- GSL::Wavelet#transform_forward(v, work)
--- GSL::Wavelet#transform_forward(v)
--- GSL::Wavelet.transform_inverse(w, v, work)
--- GSL::Wavelet.transform_inverse(w, v)
--- GSL::Wavelet#transform_inverse(v, work)
--- GSL::Wavelet#transform_inverse(v)
--- GSL::Vector#wavelet_transform(w, ...)
--- GSL::Vector#wavelet_transform_forward(w, ...)
--- GSL::Vector#wavelet_transform_inverse(w, ...)
    These methods compute forward and inverse discrete wavelet transforms 
    of the vector ((|v|)). The length of the transform is restricted to powers 
    of two. For the transform version of the function the argument dir can be 
    either GSL::Wavelet::FORWARD (+1) or GSL::Wavelet::BACKWARD (-1). 
    A workspace ((|work|)) can be omitted.
    
    If ((|v|)) is a (({GSL::Matrix})) object, methods for 2d-transforms
    are called.

    For the forward transform, the elements of the original vector are replaced by 
    the discrete wavelet transform f_i -> w_{j,k} in a packed triangular storage 
    layout, where j is the index of the level j = 0 ... J-1 and k is the index of 
    the coefficient within each level, k = 0 ... (2^j)-1. The total number of 
    levels is J = log_2(n). 

    These methods return a transformed data, and the input vector is not changed.
#    These methods return a status of GSL::SUCCESS upon successful completion. 
#    GSL::EINVAL is returned if the length is not an integer power of 2 
#    or if insufficient workspace is provided.

=== Wavelet transforms in two dimension
--- GSL::Wavelet.transform(same as the methods for one dimensional transforms)
--- GSL::Wavelet.transform_matrix()
--- GSL::Wavelet2d.transform()
--- GSL::Wavelet#transform(same as the methods for one dimensional transforms)
--- GSL::Wavelet#transform_matrix()
--- GSL::Wavelet2d#transform()

--- GSL::Wavelet.transform_forward()
--- GSL::Wavelet.transform_matrix_forward()
--- GSL::Wavelet2d.transform_forward()
--- GSL::Wavelet#transform_forward()
--- GSL::Wavelet#transform_matrix_forward()
--- GSL::Wavelet2d#transform_forward()

--- GSL::Wavelet.transform_inverse()
--- GSL::Wavelet.transform_matrix_inverse()
--- GSL::Wavelet2d.transform_inverse()
--- GSL::Wavelet#transform_inverse()
--- GSL::Wavelet#transform_matrix_inverse()
--- GSL::Wavelet2d#transform_inverse()

--- GSL::Wavelet.nstransform(same as the methods for one dimensional nstransforms)
--- GSL::Wavelet.nstransform_matrix()
--- GSL::Wavelet2d.nstransform()
--- GSL::Wavelet#nstransform(same as the methods for one dimensional nstransforms)
--- GSL::Wavelet#nstransform_matrix()
--- GSL::Wavelet2d#nstransform()

--- GSL::Wavelet.nstransform_forward()
--- GSL::Wavelet.nstransform_matrix_forward()
--- GSL::Wavelet2d.nstransform_forward()
--- GSL::Wavelet#nstransform_forward()
--- GSL::Wavelet#nstransform_matrix_forward()
--- GSL::Wavelet2d#nstransform_forward()

--- GSL::Wavelet.nstransform_inverse()
--- GSL::Wavelet.nstransform_matrix_inverse()
--- GSL::Wavelet2d.nstransform_inverse()
--- GSL::Wavelet#nstransform_inverse()
--- GSL::Wavelet#nstransform_matrix_inverse()
--- GSL::Wavelet2d#nstransform_inverse()

== Example
  #!/usr/bin/env ruby
  require("gsl")

  n = 256
  nc = 20
 
  data = Vector.alloc(n)
  data.fscanf("ecg.dat")

  w = GSL::Wavelet.alloc("daubechies", 4)
  work = GSL::Wavelet::Workspace.alloc(n)

  ##### Choose as you like...
  data2 = w.transform(data, Wavelet::FORWARD, work)
  #data2 = w.transform(data, work)
  #data2 = w.transform(data)
  #data2 = w.transform(data, Wavelet::FORWARD)
  #data2 = w.transform_forward(data, work)
  #data2 = w.transform_forward(data)
  #data2 = Wavelet.transform(w, data, Wavelet::FORWARD, work)
  #data2 = Wavelet.transform(w, data, Wavelet::FORWARD)
  #data2 = Wavelet.transform(w, data, work)
  #data2 = Wavelet.transform_forward(w, data)
  #data2 = data.wavelet_transform(w, Wavelet::FORWARD, work)
  #data2 = data.wavelet_transform_forward(w, work)

  perm = data2.abs.sort_index

  i = 0
  while (i + nc) < n
    data2[perm[i]] = 0.0
    i += 1  
  end

  #data3 = w.transform(data2, Wavelet::BACKWARD, work)
  #data3 = w.transform(data2, Wavelet::BACKWARD)
  #data3 = w.transform_inverse(data2, work)
  #data3 = w.transform_inverse(data2)
  #data3 = Wavelet.transform(w, data2, Wavelet::BACKWARD, work)
  #data3 = Wavelet.transform(w, data2, Wavelet::BACKWARD)
  #data3 = Wavelet.transform_inverse(w, data2, work)
  data3 = Wavelet.transform_inverse(w, data2)
  #data3 = data2.wavelet_transform(w, Wavelet::BACKWARD, work)
  #data3 = data2.wavelet_transform_inverse(w, work)

  #If you have GNU graph utility...
  GSL::graph(nil, data, data3, "-T X -C -g 3")
  
((<prev|URL:fft.html>))
((<next|URL:integration.html>))

((<back|URL:index.html>))
=end
