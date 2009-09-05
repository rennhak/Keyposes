=begin

=== Complex LU decomposition

--- GSL::Linalg::Complex::LU_decomp!(A)
--- GSL::Linalg::Complex::LU::decomp!(A)
--- GSL::Matrix::Complex#LU_decomp!
--- GSL::Matrix::Complex#LU_decomp!
    Factorizes the square matrix ((|A|)) into the LU decomposition PA = LU,
    and returns an array, ((|[perm, signum]|)). ((|A|)) is changed.

--- GSL::Linalg::Complex::LU_decomp(A)
--- GSL::Linalg::Complex::LU::decomp(A)
--- GSL::Matrix::Complex#LU_decomp
    Factorizes the square matrix ((|A|)) into the LU decomposition PA = LU,
    and returns an array, ((|[LU, perm, signum]|)). ((|A|)) is not changed.

--- GSL::Linalg::Complex::LU_solve(A, b)
--- GSL::Linalg::Complex::LU::solve(A, b)
--- GSL::Linalg::Complex::LU_solve(A, b)
--- GSL::Matrix::Complex#LU_solve(b)
--- GSL::Linalg::Complex::solve(LU, perm, b)
--- GSL::Linalg::Complex::LU::solve(LU, perm, b)
--- GSL::Linalg::Complex::LU::LUMatirx#solve(perm, b)

--- GSL::Linalg::Complex::LU_svx(A, x)
--- GSL::Linalg::Complex::LU::svx(A, x)
--- GSL::Linalg::Complex::LU_svx(A, x)
--- GSL::Matrix::Complex#LU_svx(x)
--- GSL::Linalg::Complex::svx(LU, perm, x)
--- GSL::Linalg::Complex::LU::svx(LU, perm, x)
--- GSL::Linalg::Complex::LU::LUMatirx#svx(perm, x)

--- GSL::Linalg::Complex::LU_refine(A, LU, perm, b, x)
--- GSL::Linalg::Complex::LU_::refine(A, LU, perm, b, x)

--- GSL::Linalg::Complex::LU_invert(A)
--- GSL::Linalg::Complex::LU::invert(A)
--- GSL::Linalg::Complex::LU_invert(LU, perm)
--- GSL::Linalg::Complex::LU::invert(LU, perm)
--- GSL::Matrix::Complex#LU_invert
--- GSL::Matrix::Complex#invert
--- GSL::Linalg::Complex::LU::LUMatrix#invert(perm)

--- GSL::Linalg::Complex::LU_det(A)
--- GSL::Linalg::Complex::LU::det(A)
--- GSL::Linalg::Complex::LU_det(LU, signum)
--- GSL::Linalg::Complex::LU::det(LU, signum)
--- GSL::Matrix::Complex#LU_det
--- GSL::Matrix::Complex#det
--- GSL::Linalg::Complex::LU::LUMatrix#det(signum)

--- GSL::Linalg::Complex::LU_lndet(A)
--- GSL::Linalg::Complex::LU::lndet(A)
--- GSL::Linalg::Complex::LU_lndet(LU)
--- GSL::Linalg::Complex::LU::lndet(LU)
--- GSL::Matrix::Complex#LU_lndet
--- GSL::Matrix::Complex#lndet
--- GSL::Linalg::Complex::LU::LUMatrix#lndet

--- GSL::Linalg::Complex::LU_sgndet(A)
--- GSL::Linalg::Complex::LU::sgndet(A)
--- GSL::Linalg::Complex::LU_sgndet(LU, signum)
--- GSL::Linalg::Complex::LU::sgndet(LU, signum)
--- GSL::Matrix::Complex#LU_sgndet
--- GSL::Matrix::Complex#sgndet
--- GSL::Linalg::Complex::LU::LUMatrix#sgndet(signum)

((<back|URL:linalg.html>))

=end
