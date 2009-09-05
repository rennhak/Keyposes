
SHELL = /bin/sh

#### Start of system configuration section. ####

srcdir = /home/br/MotionX/archive/rb-gsl-1.10.3/ext
topdir = /usr/lib/ruby/1.8/i686-linux
hdrdir = $(topdir)
VPATH = $(srcdir):$(topdir):$(hdrdir)
prefix = $(DESTDIR)/usr
exec_prefix = $(prefix)
sitedir = $(DESTDIR)/usr/lib/ruby/site_ruby
rubylibdir = $(libdir)/ruby/$(ruby_version)
docdir = $(datarootdir)/doc/$(PACKAGE)
dvidir = $(docdir)
datarootdir = $(prefix)/share
archdir = $(rubylibdir)/$(arch)
sbindir = $(exec_prefix)/sbin
psdir = $(docdir)
localedir = $(datarootdir)/locale
htmldir = $(docdir)
datadir = $(DESTDIR)/usr/share
includedir = $(prefix)/include
infodir = $(DESTDIR)/usr/share/info
sysconfdir = $(DESTDIR)/etc
mandir = $(DESTDIR)/usr/share/man
libdir = $(exec_prefix)/lib
sharedstatedir = $(prefix)/com
oldincludedir = $(DESTDIR)/usr/include
pdfdir = $(docdir)
sitearchdir = $(sitelibdir)/$(sitearch)
bindir = $(exec_prefix)/bin
localstatedir = $(DESTDIR)/var/lib
sitelibdir = $(sitedir)/$(ruby_version)
libexecdir = $(exec_prefix)/libexec

CC = i686-pc-linux-gnu-gcc
LIBRUBY = $(LIBRUBY_SO)
LIBRUBY_A = lib$(RUBY_SO_NAME)-static.a
LIBRUBYARG_SHARED = -Wl,-R -Wl,$(libdir) -L$(libdir) -l$(RUBY_SO_NAME)
LIBRUBYARG_STATIC = -l$(RUBY_SO_NAME)-static

RUBY_EXTCONF_H = 
CFLAGS   =  -fPIC  -Wall -I../include -I/usr/include 
INCFLAGS = -I. -I. -I/usr/lib/ruby/1.8/i686-linux -I/home/br/MotionX/archive/rb-gsl-1.10.3/ext
DEFS     = -D_FILE_OFFSET_BITS=64
CPPFLAGS = -DHAVE_NARRAY_H -I/usr/lib/ruby/site_ruby/1.8/i686-linux  -D_FILE_OFFSET_BITS=64
CXXFLAGS = $(CFLAGS) 
DLDFLAGS = -L. -Wl,-O1 -rdynamic -Wl,-export-dynamic  
LDSHARED = $(CC) -shared
AR = i686-pc-linux-gnu-ar
EXEEXT = 

RUBY_INSTALL_NAME = ruby18
RUBY_SO_NAME = ruby18
arch = i686-linux
sitearch = i686-linux
ruby_version = 1.8
ruby = /usr/bin/ruby18
RUBY = $(ruby)
RM = rm -f
MAKEDIRS = mkdir -p
INSTALL = /usr/bin/install -c
INSTALL_PROG = $(INSTALL) -m 0755
INSTALL_DATA = $(INSTALL) -m 644
COPY = cp

#### End of system configuration section. ####

preload = 

libpath = . $(libdir) $(sitelibdir)/$(sitearch)
LIBPATH =  -L. -L$(libdir) -Wl,-R$(libdir) -L$(sitelibdir)/$(sitearch) -Wl,-R$(sitelibdir)/$(sitearch)
DEFFILE = 

CLEANFILES = mkmf.log
DISTCLEANFILES = 

extout = 
extout_prefix = 
target_prefix = 
LOCAL_LIBS =  -L/usr/lib -lgsl -lgslcblas -lm
LIBS = $(LIBRUBYARG_SHARED) -lgsl -lcblas  -lrt -ldl -lcrypt -lm   -lc
SRCS = permutation.c blas.c array.c monte.c sf_debye.c sf_erfc.c combination.c sf_exp.c vector.c sf_coulomb.c tensor.c vector_double.c complex.c linalg.c cheb.c multifit.c sf_power.c tamu_anova.c matrix_int.c histogram3d.c qrng.c odeiv.c matrix.c cdf.c bundle.c blas3.c diff.c linalg_complex.c sf_ellint.c common.c histogram_find.c sf_gamma.c histogram.c ieee.c vector_complex.c bspline.c dirac.c sf_laguerre.c sf_clausen.c const.c rng.c eigen.c sf_lambert.c randist.c vector_int.c array_complex.c sf_log.c matrix_complex.c sf_psi.c blas1.c histogram_oper.c stats.c sf_expint.c sf_zeta.c fresnel.c poly.c blas2.c const_additional.c ntuple.c sf_synchrotron.c sum.c multiroots.c deriv.c siman.c sf_coupling.c multimin_fsdf.c graph.c error.c sf_legendre.c block.c matrix_double.c sf_elljac.c multimin.c sort.c interp.c function.c sf_hyperg.c math.c gsl_narray.c fcmp.c gsl.c ndlinear.c sf_transport.c sf_elementary.c root.c spline.c sf_fermi_dirac.c sf_airy.c sf_gegenbauer.c signal.c fit.c histogram3d_source.c poly2.c oper_complex_source.c sf_bessel.c ool.c integration.c fft.c sf_mathieu.c cqp.c sf_trigonometric.c rational.c histogram2d.c sf_dawson.c sf.c dht.c wavelet.c min.c jacobi.c sf_dilog.c
OBJS = permutation.o blas.o array.o monte.o sf_debye.o sf_erfc.o combination.o sf_exp.o vector.o sf_coulomb.o tensor.o vector_double.o complex.o linalg.o cheb.o multifit.o sf_power.o tamu_anova.o matrix_int.o histogram3d.o qrng.o odeiv.o matrix.o cdf.o bundle.o blas3.o diff.o linalg_complex.o sf_ellint.o common.o histogram_find.o sf_gamma.o histogram.o ieee.o vector_complex.o bspline.o dirac.o sf_laguerre.o sf_clausen.o const.o rng.o eigen.o sf_lambert.o randist.o vector_int.o array_complex.o sf_log.o matrix_complex.o sf_psi.o blas1.o histogram_oper.o stats.o sf_expint.o sf_zeta.o fresnel.o poly.o blas2.o const_additional.o ntuple.o sf_synchrotron.o sum.o multiroots.o deriv.o siman.o sf_coupling.o multimin_fsdf.o graph.o error.o sf_legendre.o block.o matrix_double.o sf_elljac.o multimin.o sort.o interp.o function.o sf_hyperg.o math.o gsl_narray.o fcmp.o gsl.o ndlinear.o sf_transport.o sf_elementary.o root.o spline.o sf_fermi_dirac.o sf_airy.o sf_gegenbauer.o signal.o fit.o histogram3d_source.o poly2.o oper_complex_source.o sf_bessel.o ool.o integration.o fft.o sf_mathieu.o cqp.o sf_trigonometric.o rational.o histogram2d.o sf_dawson.o sf.o dht.o wavelet.o min.o jacobi.o sf_dilog.o
TARGET = rb_gsl
DLLIB = $(TARGET).so
EXTSTATIC = 
STATIC_LIB = 

RUBYCOMMONDIR = $(sitedir)$(target_prefix)
RUBYLIBDIR    = $(sitelibdir)$(target_prefix)
RUBYARCHDIR   = $(sitearchdir)$(target_prefix)

TARGET_SO     = $(DLLIB)
CLEANLIBS     = $(TARGET).so $(TARGET).il? $(TARGET).tds $(TARGET).map
CLEANOBJS     = *.o *.a *.s[ol] *.pdb *.exp *.bak

all:		$(DLLIB)
static:		$(STATIC_LIB)

clean:
		@-$(RM) $(CLEANLIBS) $(CLEANOBJS) $(CLEANFILES)

distclean:	clean
		@-$(RM) Makefile $(RUBY_EXTCONF_H) conftest.* mkmf.log
		@-$(RM) core ruby$(EXEEXT) *~ $(DISTCLEANFILES)

realclean:	distclean
install: install-so install-rb

install-so: $(RUBYARCHDIR)
install-so: $(RUBYARCHDIR)/$(DLLIB)
$(RUBYARCHDIR)/$(DLLIB): $(RUBYARCHDIR) $(DLLIB)
	$(INSTALL_PROG) $(DLLIB) $(RUBYARCHDIR)
install-rb: pre-install-rb install-rb-default
install-rb-default: pre-install-rb-default
pre-install-rb: Makefile
pre-install-rb-default: Makefile
$(RUBYARCHDIR):
	$(MAKEDIRS) $@

site-install: site-install-so site-install-rb
site-install-so: install-so
site-install-rb: install-rb

.SUFFIXES: .c .m .cc .cxx .cpp .C .o

.cc.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.cxx.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.cpp.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.C.o:
	$(CXX) $(INCFLAGS) $(CPPFLAGS) $(CXXFLAGS) -c $<

.c.o:
	$(CC) $(INCFLAGS) $(CPPFLAGS) $(CFLAGS) -c $<

$(DLLIB): $(OBJS) Makefile
	@-$(RM) $@
	$(LDSHARED) -o $@ $(OBJS) $(LIBPATH) $(DLDFLAGS) $(LOCAL_LIBS) $(LIBS)



$(OBJS): ruby.h defines.h
