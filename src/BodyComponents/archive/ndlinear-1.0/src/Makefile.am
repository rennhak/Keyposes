lib_LTLIBRARIES = libndlinear.la
libndlinear_la_SOURCES = ndlinear.c

check_PROGRAMS = test
test_SOURCES = test.c
TESTS = $(check_PROGRAMS)

pkginclude_HEADERS = gsl_multifit_ndlinear.h

test_LDADD = libndlinear.la -lgsl -lgslcblas
