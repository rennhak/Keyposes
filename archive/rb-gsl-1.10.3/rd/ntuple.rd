=begin
= N-tuples
This chapter describes functions for creating and manipulating ntuples, 
sets of values associated with events. The ntuples are stored in files. 
Their values can be extracted in any combination and booked in a histogram using 
a selection function.

The values to be stored are held in a ((<GSL::Vector|URL:vector.html>)) or 
a ((<GSL::Matrix|URL:matrix.html>)) object,
and an ntuple is created associating this object with a file. 
The values are then written to the file (normally inside a loop) using 
the ntuple functions described below.

A histogram can be created from ntuple data by providing a selection function 
and a value function. The selection function specifies whether an event should 
be included in the subset to be analyzed or not. The value function computes 
the entry to be added to the histogram for each event.

== The (({GSL::Ntuple})) class
--- GSL::Ntuple.create(filename, v)
--- GSL::Ntuple.alloc(filename, v)
    These create a new write-only ntuple file ((|filename|)) for ntuples. 
Any existing file with the same name is truncated to zero length and overwritten. 
A preexisting (({Vector})) object ((|v|)) for the current ntuple data must be supplied:
this is used to copy ntuples in and out of the file.

--- GSL::Ntuple.open(filename, v)
    This opens an existing ntuple file ((|filename|)) for reading. A preexisting
(({Vector})) object ((|v|)) for the current ntuple data must be supplied.

== Writing and reading ntuples
--- GSL::Ntuple#write
--- GSL::Ntuple#bookdata
    This method writes the current ntuple data to the corresponding file.

--- GSL::Ntuple#read
    This method reads the current row of the ntuple file.

== Histogramming ntuple values
Once an ntuple has been created its contents can be histogrammed in various ways using 
the function gsl_ntuple_project. Two user-defined functions must be provided, a function 
to select events and a function to compute scalar values. The selection function and the 
value function both accept the ntuple row as a first argument and other parameters as a 
second argument.

--- GSL::Ntuple::SelectFn.alloc {block}
--- GSL::Ntuple::SelectFn.alloc(proc)
--- GSL::Ntuple::ValueFn.alloc {block}
--- GSL::Ntuple::ValueFn.alloc(proc)
    Constructors for selection functions and value functions.
    The selection function shoud return a non-zero value for each ntuple row that 
    is to be included in the histogram. The value function should return the value to
    be added to the histogram for the ntuple row.
    
--- GSL::Ntuple::SelectFn#set_params(params)
--- GSL::Ntuple::ValueFn#set_params(params)
    Set the parameters of the functions, by an array ((|params|)).

--- GSL::Ntuple.project(h, n, valfn, selfn)
    These methods updates the histogram ((|h|)) from the ntuple ((|n|)) using 
    the functions ((|valfn|)) and ((|selfn|)). For each ntuple row where the selection 
    function ((|selen|)) is non-zero the corresponding value of that row is computed 
    using the function value_func((|valfn|)) and added to the histogram ((|h|)). 
    Those ntuple rows where ((|selfn|)) returns zero are ignored. New entries are added 
    to the histogram, so subsequent calls can be used to accumulate further data in the 
    same histogram.

((<prev|URL:hist2d.html>))
((<next|URL:monte.html>))

((<Reference index|URL:ref.html>))
((<top|URL:index.html>))

=end
