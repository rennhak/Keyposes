=begin
= BLAS Support
The following is the list of the methods defined in (({GSL::Blas})) module.
See ((<GSL reference|URL:http://www.gnu.org/software/gsl/manual/gsl-ref_12.html#SEC212>)) for details.

== Level 1
--- GSL::Blas::ddot(x, y)
--- GSL::Vector#blas_ddot(y)
--- GSL::Vector#ddot(y)

--- GSL::Blas::zdotu(x, y)
--- GSL::Vector::Complex#blas_zdotu(y)
--- GSL::Vector::Complex#zdotu(y)

--- GSL::Blas::zdotc(x, y)
--- GSL::Vector::Complex#blas_zdotc(y)
--- GSL::Vector::Complex#zdotc(y)

--- GSL::Blas::dnrm2(x)
--- GSL::Vector#blas_dnrm2
--- GSL::Vector#dnrm2

--- GSL::Blas::dznrm2(x)
--- GSL::Vector::Complex#blas_dznrm2
--- GSL::Vector::Complex#dznrm2

--- GSL::Blas::dasum(x)
--- GSL::Vector#blas_dasum
--- GSL::Vector#dasum

--- GSL::Blas::dzasum(x)
--- GSL::Vector::Complex#blas_dzasum
--- GSL::Vector::Complex#dzasum

--- GSL::Blas::idamax(x)
--- GSL::Vector#blas_idamax
--- GSL::Vector#idamax

--- GSL::Blas::izamax(x)
--- GSL::Vector::Complex#blas_izamax
--- GSL::Vector::Complex#izamax

--- GSL::Blas::dswap(x, y)
--- GSL::Vector#blas_dswap(y)
--- GSL::Vector#dswap(y)

--- GSL::Blas::zswap(x, y)
--- GSL::Vector::Complex#blas_zswap(y)
--- GSL::Vector::Complex#zswap(y)

--- GSL::Blas::dcopy(x, y)
--- GSL::Vector#blas_dcopy(y)
--- GSL::Vector#dcopy(y)

--- GSL::Blas::zcopy(x, y)
--- GSL::Vector::Complex#blas_zcopy(y)
--- GSL::Vector::Complex#zcopy(y)

--- GSL::Blas::daxpy!(a, x, y)
--- GSL::Vector#blas_daxpy!(a, y)
--- GSL::Vector#daxpy!(a, y)
--- GSL::Blas::daxpy(a, x, y)
--- GSL::Vector#blas_daxpy(a, y)
--- GSL::Vector#daxpy(a, y)

--- GSL::Blas::zaxpy!(a, x, y)
--- GSL::Vector::Complex#blas_zaxpy!(a, y)
--- GSL::Vector::Complex#zaxpy!(a, y)
--- GSL::Blas::zaxpy(a, x, y)
--- GSL::Vector::Complex#blas_zaxpy(a, y)
--- GSL::Vector::Complex#zaxpy(a, y)

--- GSL::Blas::dscal!(a, x)
--- GSL::Vector#blas_dscal!(a)
--- GSL::Vector#dscal!(a)
--- GSL::Blas::dscal(a, x)
--- GSL::Vector#blas_dscal(a)
--- GSL::Vector#dscal(a)

--- GSL::Blas::zscal!(a, x)
--- GSL::Vector::Complex#blas_zscal!(a)
--- GSL::Vector::Complex#zscal!(a)
--- GSL::Blas::zscal(a, x)
--- GSL::Vector::Complex#blas_zscal(a)
--- GSL::Vector::Complex#zscal(a)

--- GSL::Blas::zdscal!(a, x)
--- GSL::Vector::Complex#blas_zdscal!(a)
--- GSL::Vector::Complex#zdscal!(a)
--- GSL::Blas::zdscal(a, x)
--- GSL::Vector::Complex#blas_zdscal(a)
--- GSL::Vector::Complex#zdscal(a)

--- GSL::Blas::drot(x, y, c, s)
--- GSL::Blas::drot!(x, y, c, s)
--- GSL::Blas::drotm(x, y, p)
--- GSL::Blas::drotm!(x, y, p)

== Level 2
--- GSL::Blas::dgemv(trans, a, A, x, b, y)
--- GSL::Blas::dgemv!(trans, a, A, x, b, y)
--- GSL::Blas::zgemv(trans, a, A, x, b, y)
--- GSL::Blas::zgemv!(trans, a, A, x, b, y)

--- GSL::Blas::dtrmv(trans, a, A, x, b, y)
--- GSL::Blas::dtrmv!(trans, a, A, x, b, y)
--- GSL::Blas::ztrmv(trans, a, A, x, b, y)
--- GSL::Blas::ztrmv!(trans, a, A, x, b, y)

--- GSL::Blas::dtrsv(uplo, trans, diag, A, x)
--- GSL::Blas::dtrsv!uplo, trans, diag, A, x)
--- GSL::Blas::ztrsvuplo, trans, diag, A, x)
--- GSL::Blas::ztrsv!uplo, trans, diag, A, x)

--- GSL::Blas::dsymv(uplo, a, A, x, b, y)
--- GSL::Blas::dsymv!(uplo, a, A, x, b, y)
--- GSL::Blas::zhemv(uplo, a, A, x, b, y)
--- GSL::Blas::zhemv!(uplo, a, A, x, b, y)

--- GSL::Blas::dger(a, x, y, A)
--- GSL::Blas::dger!(a, x, y, A)
--- GSL::Blas::zgeru(a, x, y, A)
--- GSL::Blas::zgeru!(a, x, y, A)
--- GSL::Blas::zgerc(a, x, y, A)
--- GSL::Blas::zgerc!(a, x, y, A)

--- GSL::Blas::dsyr(uplo, a, x, A)
--- GSL::Blas::dsyr!(uplo, a, x, A)
--- GSL::Blas::zher(uplo, a, x, A)
--- GSL::Blas::zher!(uplo, a, x, A)

--- GSL::Blas::dsyr2(uplo, a, x, y, A)
--- GSL::Blas::dsyr2!(uplo, a, x, y, A)
--- GSL::Blas::zher2(uplo, a, x, y, A)
--- GSL::Blas::zher2!(uplo, a, x, y, A)

== Level 3
--- GSL::Blas::dgemm(transA, transB, alpha, A, B, beta, C)
--- GSL::Blas::dgemm(A, B)

--- GSL::Blas::zgemm(transA, transB, alpha, A, B, beta, C)
--- GSL::Blas::zgemm(A, B)

--- GSL::Blas::dsymm(transA, transB, alpha, A, B, beta, C)
--- GSL::Blas::dsymm(A, B)

--- GSL::Blas::zsymm(transA, transB, alpha, A, B, beta, C)
--- GSL::Blas::zsymm(A, B)

--- GSL::Blas::zhemm(transA, transB, alpha, A, B, beta, C)
--- GSL::Blas::zhemm(A, B)

--- GSL::Blas::dtrmm(side, uplo, trans, diag, alpha, A, B)
--- GSL::Blas::ztrmm(side, uplo, trans, diag, alpha, A, B)

--- GSL::Blas::dtrsm(side, uplo, trans, diag, alpha, A, B)
--- GSL::Blas::ztrsm(side, uplo, trans, diag, alpha, A, B)

--- GSL::Blas::dsyrk(uplo, trans, diag, alpha, A, beta, C)
--- GSL::Blas::zsyrk(uplo, trans, diag, alpha, A, beta, C)
--- GSL::Blas::zherk(uplo, trans, diag, alpha, A, beta, C)

--- GSL::Blas::dsyr2k(uplo, trans, diag, alpha, A, B, beta, C)
--- GSL::Blas::zsyr2k(uplo, trans, diag, alpha, A, B, beta, C)
--- GSL::Blas::zher2k(uplo, trans, diag, alpha, A, B, beta, C)

== Constants
--- GSL::Blas::CblasRowMajor
--- GSL::Blas::RowMajor
--- GSL::Blas::CblasColMajor
--- GSL::Blas::ColMajor
--- GSL::Blas::CblasNoTrans
--- GSL::Blas::NoTrans
--- GSL::Blas::CblasTrans
--- GSL::Blas::Trans
--- GSL::Blas::CblasConjTrans
--- GSL::Blas::ConjTrans
--- GSL::Blas::CblasUpper
--- GSL::Blas::Upper
--- GSL::Blas::CblasTrans
--- GSL::Blas::Lower
--- GSL::Blas::CblasNonUnit
--- GSL::Blas::NonUnit
--- GSL::Blas::CblasUnit
--- GSL::Blas::Unit
--- GSL::Blas::CblasLeft
--- GSL::Blas::Left
--- GSL::Blas::CblasRight
--- GSL::Blas::Right

((<prev|URL:sort.html>))
((<next|URL:linalg.html>))

((<Reference index|URL:ref.html>))
((<top|URL:index.html>))

=end
