#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <ndlinear/gsl_multifit_ndlinear.h>

#include <gsl/gsl_math.h>
#include <gsl/gsl_sf_laguerre.h>
#include <gsl/gsl_sf_legendre.h>
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_multifit.h>
#include <gsl/gsl_rng.h>
#include <gsl/gsl_randist.h>
#include <gsl/gsl_bspline.h>
#include <gsl/gsl_statistics.h>

/* dimension of fit */
#define N_DIM            3

/* number of basis functions for each variable */
#define N_SUM_R          10
#define N_SUM_THETA      10
#define N_SUM_PHI        9

#define R_MAX            3.0

double
psi_real_exact(int k, int l, int m, double r, double theta, double phi)
{
  double R, T, P;

  R = pow(r, (double) l) *
      exp(-r*r) *
      gsl_sf_laguerre_n(k, l + 0.5, 2 * r * r);
  T = gsl_sf_legendre_sphPlm(l, m, cos(theta));
  P = cos(m * phi);

  return (R * T * P);
}

/* basis functions for each variable */

int
basis_r(double r, double y[], void *params)
{
  gsl_bspline_workspace *bw = params;
  gsl_vector_view v = gsl_vector_view_array(y, N_SUM_R);
  int s;

  /* use B-splines for r dependence */
  s = gsl_bspline_eval(r, &v.vector, bw);

  return s;
}

int
basis_theta(double theta, double y[], void *params)
{
  size_t i;

  /* use Legendre polynomials for theta dependence */
  for (i = 0; i < N_SUM_THETA; ++i)
    y[i] = gsl_sf_legendre_Pl(i, cos(theta));

  return GSL_SUCCESS;
}

int
basis_phi(double phi, double y[], void *params)
{
  size_t i;

  /* use standard Fourier basis (sin/cos) for phi dependence */
  for (i = 0; i < N_SUM_PHI; ++i)
    {
      if ((i % 2) == 0)
        y[i] = cos((double)(i/2) * phi);
      else
        y[i] = sin((double)((i+1)/2) * phi);
    }

  return GSL_SUCCESS;
}

int
main(int argc, char *argv[])
{
  const size_t ndim = N_DIM; /* dimension of fit */
  const size_t ndata = 3000; /* number of data points to fit */
  size_t N[N_DIM];           /* upper bounds on model sums */
  int (*u[N_DIM])(double x, double y[], void *params);
  size_t i;                  /* looping */
  int k, l, m;               /* quantum numbers */
  gsl_rng *rng_p;
  gsl_bspline_workspace *bspline_p;
  gsl_multifit_linear_workspace *multifit_p;
  gsl_multifit_ndlinear_workspace *ndlinear_p;
  gsl_vector *data;          /* psi data */
  gsl_matrix *vars;          /* parameters corresponding to psi data */
  gsl_matrix *X;             /* matrix for least squares fit */
  gsl_vector *coeffs;        /* fit coefficients */
  gsl_matrix *cov;           /* covariance matrix */
  double chisq;              /* chi^2 */
  double Rsq;                /* R^2 */
  size_t ncoeffs;            /* total number of fit coefficients */

  gsl_rng_env_setup();

  k = 5;
  l = 4;
  m = 2;

  N[0] = N_SUM_R;
  N[1] = N_SUM_THETA;
  N[2] = N_SUM_PHI;

  u[0] = &basis_r;
  u[1] = &basis_theta;
  u[2] = &basis_phi;

  rng_p = gsl_rng_alloc(gsl_rng_default);
  bspline_p = gsl_bspline_alloc(4, N_SUM_R - 2);
  ndlinear_p = gsl_multifit_ndlinear_alloc(ndim, N, u, bspline_p);

  ncoeffs = gsl_multifit_ndlinear_ncoeffs(ndlinear_p);

  multifit_p = gsl_multifit_linear_alloc(ndata, ncoeffs);
  data = gsl_vector_alloc(ndata);
  vars = gsl_matrix_alloc(ndata, ndim);
  X = gsl_matrix_alloc(ndata, ncoeffs);
  coeffs = gsl_vector_alloc(ncoeffs);
  cov = gsl_matrix_alloc(ncoeffs, ncoeffs);

  gsl_bspline_knots_uniform(0.0, R_MAX, bspline_p);

  /* this is the data to be fitted */

  for (i = 0; i < ndata; ++i)
    {
      double r = gsl_rng_uniform(rng_p) * R_MAX;
      double theta = gsl_rng_uniform(rng_p) * M_PI;
      double phi = gsl_rng_uniform(rng_p) * 2.0 * M_PI;
      double psi = psi_real_exact(k, l, m, r, theta, phi);
      double dpsi = gsl_ran_gaussian(rng_p, 0.05 * psi);

      /* keep track of (r, theta, phi) points */
      gsl_matrix_set(vars, i, 0, r);
      gsl_matrix_set(vars, i, 1, theta);
      gsl_matrix_set(vars, i, 2, phi);

      /* fill in RHS data vector */
      gsl_vector_set(data, i, psi + dpsi);
    }

  /* construct the design matrix X */
  gsl_multifit_ndlinear_design(vars, X, ndlinear_p);

  /* now do the actual least squares fit */
  gsl_multifit_linear(X, data, coeffs, cov, &chisq, multifit_p);

  /* compute R^2 */
  Rsq = 1.0 - chisq / gsl_stats_tss(data->data, 1, data->size);

  fprintf(stderr, "chisq = %e, Rsq = %f\n", chisq, Rsq);

  /* now print out the model and the exact solution and compute rms error */
  {
    double eps_rms = 0.0;
    double volume = 0.0;
    double r, theta, phi;
    double dr = 0.05;
    double dtheta = 5.0 * M_PI / 180.0;
    double dphi = 5.0 * M_PI / 180.0;
    double x[N_DIM];
    gsl_vector_view xv = gsl_vector_view_array(x, N_DIM);
    double psi;
    double psi_model;
    double err;

    for (r = 0.01; r < R_MAX; r += dr)
      {
        for (theta = 0.0; theta < M_PI; theta += dtheta)
          {
            for (phi = 0.0; phi < 2.0 * M_PI; phi += dphi)
              {
                double dV = r * r * sin(theta) * dr * dtheta * dphi;

                x[0] = r;
                x[1] = theta;
                x[2] = phi;

                /* compute model value for this (r, theta, phi) */
                psi_model = gsl_multifit_ndlinear_calc(&xv.vector,
                                                       coeffs,
                                                       ndlinear_p);

                /* compute exact value for this (r, theta, phi) */
                psi = psi_real_exact(k, l, m, r, theta, phi);

                err = psi_model - psi;
                eps_rms += err * err * dV;
                volume += dV;

                if (phi == 0.0)
                  printf("%e %e %e %e\n", r, theta, psi, psi_model);
              }
          }
        printf("\n");
      }

    eps_rms /= volume;
    eps_rms = sqrt(eps_rms);
    fprintf(stderr, "rms error over all parameter space = %e\n", eps_rms);
  }

  gsl_rng_free(rng_p);
  gsl_bspline_free(bspline_p);
  gsl_multifit_ndlinear_free(ndlinear_p);
  gsl_multifit_linear_free(multifit_p);
  gsl_vector_free(data);
  gsl_matrix_free(vars);
  gsl_matrix_free(X);
  gsl_vector_free(coeffs);
  gsl_matrix_free(cov);

  return 0;
} /* main() */
