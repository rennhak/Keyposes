
module OOL
  module Conmin
    class Minimizer
      class Pgrad
        class Parameters
          attr_accessor :fmin, :tol, :alpha, :sigma1, :sigma2
        end
      end
      class Spg
        class Parameters
          attr_accessor :fmin, :tol, :M, :alphamin, :alphamax, :gamma
          attr_accessor :sigma1, :sigma2
        end
      end
      class Gencan
        class Parameters
          attr_accessor :epsgpen, :epsgpsn, :fmin, :udelta0
          attr_accessor :ucgmia, :ucgmib
          attr_accessor :cg_scre, :cg_gpnf, :cg_epsi, :cg_epsf
          attr_accessor :cg_epsnqmp, :cg_maxitnqmp, :nearlyq
          attr_accessor :nint, :next, :mininterp, :maxextrap
          attr_accessor :trtype, :eta, :deltamin, :lspgmi, :lspgma
          attr_accessor :theta, :gamma, :beta, :sigma1, :sigma2
          attr_accessor :epsrel, :epsabs, :infrel, :infabs
        end    
      end
    end
  end
end
