/* ndlinear.c
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

#include <stdlib.h>

#include <gsl/gsl_errno.h>
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_multifit.h>
#include <gsl/gsl_blas.h>

#include "gsl_multifit_ndlinear.h"

static int ndlinear_construct_row(const gsl_vector *d, gsl_vector *x,
                                  gsl_multifit_ndlinear_workspace *w);

/*
gsl_multifit_ndlinear_alloc()
  Allocate a ndlinear workspace

Inputs: n_dim  - dimension of fit function
        N      - number of terms in each sum; N[i] = N_i, 0 <= i < n_dim
        u      - basis functions to call
                 u[j] = u^{(j)}, 0 <= j < n_dim
        params - parameters to pass to basis functions

Return: pointer to new workspace

Notes: the supplied basis functions 'u[j]' must accept three
       arguments:

int uj(double x, double y[], void *params)

and fill the y[] vector so that y[i] = u_{i}^{(j)}(x) (the ith
basis function for the jth parameter evaluated at x)
*/

gsl_multifit_ndlinear_workspace *
gsl_multifit_ndlinear_alloc(size_t n_dim, size_t N[],
                            int (**u)(double x, double y[], void *p),
                            void *params)
{
  gsl_multifit_ndlinear_workspace *w;
  size_t n_coeffs; /* total number of fit coefficients */
  size_t i, idx;
  size_t sum_N;

  if (n_dim == 0)
    {
      GSL_ERROR_NULL("n_dim must be at least 1", GSL_EINVAL);
    }

  w = calloc(1, sizeof(gsl_multifit_ndlinear_workspace));
  if (!w)
    {
      GSL_ERROR_NULL("failed to allocate space for workspace", GSL_ENOMEM);
    }

  w->N = calloc(n_dim, sizeof(size_t));
  if (!w->N)
    {
      gsl_multifit_ndlinear_free(w);
      GSL_ERROR_NULL("failed to allocate space for N vector", GSL_ENOMEM);
    }

  n_coeffs = 1;
  sum_N = 0;
  for (i = 0; i < n_dim; ++i)
    {
      if (N[i] == 0)
        {
          gsl_multifit_ndlinear_free(w);
          GSL_ERROR_NULL("one of the sums is empty", GSL_EINVAL);
        }

      /* The total number of coefficients is: N_1 * N_2 * ... * N_n */
      n_coeffs *= N[i];
      w->N[i] = N[i];
      sum_N += N[i];
    }

  w->n_dim = n_dim;
  w->n_coeffs = n_coeffs;

  w->work = gsl_vector_alloc(n_coeffs);
  w->work2 = gsl_vector_alloc(sum_N);
  if (!w->work || !w->work2)
    {
      gsl_multifit_ndlinear_free(w);
      GSL_ERROR_NULL("failed to allocate space for basis vector",
                     GSL_ENOMEM);
    }

  w->v = calloc(n_dim, sizeof(gsl_vector_view));
  if (!w->v)
    {
      gsl_multifit_ndlinear_free(w);
      GSL_ERROR_NULL("failed to allocate space for basis vector",
                     GSL_ENOMEM);
    }

  w->u = calloc(n_dim, sizeof(int *));
  if (!w->u)
    {
      gsl_multifit_ndlinear_free(w);
      GSL_ERROR_NULL("failed to allocate space for basis functions",
                     GSL_ENOMEM);
    }

  idx = 0;
  for (i = 0; i < n_dim; ++i)
    {
      w->v[i] = gsl_vector_subvector(w->work2, idx, N[i]);
      idx += N[i];

      w->u[i] = u[i];
    }

  w->params = params;

  return (w);
} /* gsl_multifit_ndlinear_alloc() */

/*
gsl_multifit_ndlinear_free()
  Free workspace w
*/

void
gsl_multifit_ndlinear_free(gsl_multifit_ndlinear_workspace *w)
{
  if (w->N)
    free(w->N);

  if (w->work)
    gsl_vector_free(w->work);

  if (w->work2)
    gsl_vector_free(w->work2);

  if (w->v)
    free(w->v);

  if (w->u)
    free(w->u);

  free(w);
} /* gsl_multifit_ndlinear_free() */

/*
gsl_multifit_ndlinear_design()
  This function constructs the coefficient design matrix 'X'

Inputs: vars  - independent variable vectors for matrix X
                vars is a ndata-by-n_dim matrix where the ith row
                specifies the n_dim independent variables for the
                ith observation, so that
                vars_{ij} = (x_i)_j, the jth element of the
                ith input variable vector
        X     - (output) design matrix (must be ndata-by-w->n_coeffs)
        w     - workspace

Return: success or error
*/

int
gsl_multifit_ndlinear_design(const gsl_matrix *vars, gsl_matrix *X,
                             gsl_multifit_ndlinear_workspace *w)
{
  const size_t ndata = vars->size1;

  if ((X->size1 != ndata) || (X->size2 != w->n_coeffs))
    {
      GSL_ERROR("X matrix has wrong dimensions", GSL_EBADLEN);
    }
  else
    {
      size_t i; /* looping */
      int s;

      for (i = 0; i < ndata; ++i)
        {
          gsl_vector_const_view d = gsl_matrix_const_row(vars, i);
          gsl_vector_view xv = gsl_matrix_row(X, i);

          s = ndlinear_construct_row(&d.vector, &xv.vector, w);
          if (s != GSL_SUCCESS)
            return s;
        }

      return GSL_SUCCESS;
    }
} /* gsl_multifit_ndlinear_design() */

/*
gsl_multifit_ndlinear_est()
  Compute the model function at a given data point with errors

Inputs: x     - data point (w->n_dim elements)
        c     - coefficient vector
        cov   - covariance matrix
        y     - where to store fit function result
        y_err - standard deviation of fit
        w     - workspace

Return: success or error
*/

int
gsl_multifit_ndlinear_est(const gsl_vector *x, const gsl_vector *c,
                          const gsl_matrix *cov, double *y, double *y_err,
                          gsl_multifit_ndlinear_workspace *w)
{
  if (c->size != w->n_coeffs)
    {
      GSL_ERROR("c vector has wrong size", GSL_EBADLEN);
    }
  else
    {
      int s;

      s = ndlinear_construct_row(x, w->work, w);
      if (s != GSL_SUCCESS)
        return s;

      /*
       * Now w->work contains the appropriate basis functions
       * evaluated at the given point - compute the function value
       */
      s = gsl_multifit_linear_est(w->work, c, cov, y, y_err);

      return s;
    }
} /* gsl_multifit_ndlinear_est() */

/*
gsl_multifit_ndlinear_calc()
  Compute the model function at a given data point

Inputs: x - data point (w->n_dim elements)
        c - coefficient vector
        w - workspace

Return: model value
*/

double
gsl_multifit_ndlinear_calc(const gsl_vector *x, const gsl_vector *c,
                           gsl_multifit_ndlinear_workspace *w)
{
  if (c->size != w->n_coeffs)
    {
      GSL_ERROR_VAL("c vector has wrong size", GSL_EBADLEN, 0.0);
    }
  else
    {
      double y;
      int s;

      s = ndlinear_construct_row(x, w->work, w);
      if (s != GSL_SUCCESS)
        {
          GSL_ERROR_VAL("constructing matrix row failed", s, 0.0);
        }

      gsl_blas_ddot(w->work, c, &y);

      return y;
    }
} /* gsl_multifit_ndlinear_calc() */

/*
gsl_multifit_ndlinear_ncoeffs()
  Return the total number of fit coefficients
*/

size_t
gsl_multifit_ndlinear_ncoeffs(gsl_multifit_ndlinear_workspace *w)
{
  return w->n_coeffs;
} /* gsl_multifit_ndlinear_ncoeffs() */

/******************************************
 *         INTERNAL ROUTINES              *
 ******************************************/

/*
ndlinear_construct_row()

  Compute a row of the design matrix X:

X(:,j) = u_{r_0}^{(0)}(d_0) * u_{r_1)^{(1)}(d_1) * ... *
         u_{r_{n-1}}^{(n-1)}(d_{n-1})

where 'd' is the corresponding data vector for that row

Inputs: d - data vector of length w->n_dim
        x - (output) where to store row of design matrix X
        w - workspace

Return: success or error
*/

static int
ndlinear_construct_row(const gsl_vector *d, gsl_vector *x,
                       gsl_multifit_ndlinear_workspace *w)
{
  size_t j;
  int k, s;
  size_t denom, rk;
  double melement;

  /* compute basis functions for this data point */
  for (j = 0; j < w->n_dim; ++j)
    {
      s = w->u[j](gsl_vector_get(d, j), w->v[j].vector.data, w->params);

      if (s != GSL_SUCCESS)
        return s;
    }

  for (j = 0; j < w->n_coeffs; ++j)
    {
      /*
       * The (:,j) element of the matrix X will be:
       *
       * X_{:,j} = u_{r_0}^{(0)}(d_0) *
       *           u_{r_1)^{(1)}(d_1) *
       *           ... *
       *           u_{r_{n-1}}^{(n-1)}(d_{n-1})
       *
       * with the basis function indices r_k given by
       *
       * r_k = floor(j / Prod_{i=(k+1)..(n-1)} [ N_i ]) (mod N_k)
       *
       * In the case where N_i = N for all i,
       *
       * r_k = floor(j / N^{n - k - 1}) (mod N)
       *
       * n: dimension of fit function (w->n_dim)
       * N_i: number of terms in sum i of fit function
       */

      /* calculate the r_k and the matrix element X_{:,j} */

      denom = 1;
      melement = 1.0;
      for (k = (int)(w->n_dim - 1); k >= 0; --k)
        {
          rk = (j / denom) % w->N[k];
          denom *= w->N[k];

          melement *= gsl_vector_get(&(w->v[k]).vector, rk);
        }

      /* set the matrix element */
      gsl_vector_set(x, j, melement);
    }

  return GSL_SUCCESS;
} /* ndlinear_construct_row() */
