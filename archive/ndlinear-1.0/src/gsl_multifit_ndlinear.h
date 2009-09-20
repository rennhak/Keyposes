/* gsl_multifit_ndlinear.h
 * 
 * Copyright (C) 2006, 2007 Patrick Alken
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */

#ifndef __GSL_MULTIFIT_NDLINEAR_H__
#define __GSL_MULTIFIT_NDLINEAR_H__

#include <gsl/gsl_matrix.h>
#include <gsl/gsl_vector.h>

typedef struct
{
  size_t n_dim;        /* dimension of fit function */
  size_t *N;           /* number of terms in fit sums N[i] = N_i */
  size_t n_coeffs;     /* number of fit coefficients */
  gsl_vector *work;    /* scratch array of size n_coeffs */
  gsl_vector *work2;   /* scratch array */

  /*
   * Views into the 'work' array which will be used to store
   * the results of calling the basis functions, so that
   * (v[i])_j = u^{(i)}_j(x_i)
   */
  gsl_vector_view *v;

  /* pointer to basis functions and parameters */
  int (**u)(double x, double y[], void *p);
  void *params;
} gsl_multifit_ndlinear_workspace;

/*
 * Prototypes
 */

gsl_multifit_ndlinear_workspace *
gsl_multifit_ndlinear_alloc(size_t n, size_t N[],
                            int (**u)(double x, double y[], void *p),
                            void *params);
void gsl_multifit_ndlinear_free(gsl_multifit_ndlinear_workspace *w);
int gsl_multifit_ndlinear_design(const gsl_matrix *data, gsl_matrix *X,
                                 gsl_multifit_ndlinear_workspace *w);
int gsl_multifit_ndlinear_est(const gsl_vector *x, const gsl_vector *c,
                              const gsl_matrix *cov, double *y,
                              double *y_err,
                              gsl_multifit_ndlinear_workspace *w);
double gsl_multifit_ndlinear_calc(const gsl_vector *x, const gsl_vector *c,
                                  gsl_multifit_ndlinear_workspace *w);
size_t gsl_multifit_ndlinear_ncoeffs(gsl_multifit_ndlinear_workspace *w);

#endif /* __GSL_MULTIFIT_NDLINEAR_H__ */
