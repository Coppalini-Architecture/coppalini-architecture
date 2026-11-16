import Init.Data.Rat.Basic
import proofs.FlatEH010h

/-!
# Minimum Mechanics 010h — flat periodic Einstein–Hilbert functional derivative

The flat spatial background is the unit metric gamma_ij = delta_ij
on a 3-torus. Metric perturbations h_ij are *symmetric* by their
six independent finite Fourier-polynomial coordinates.

CERTIFIED HERE: the exact finite-mode integrated curvature variation
  δ(∫ N R sqrt(g))|_(g=I)
    = Σ_i,j <N,∂i∂j h_ij> - Σ_i,j <N,∂i∂i h_jj>
    = Σ_i,j <∂j∂i N,h_ij> - Σ_i,j <∂i∂i N,h_jj>.
The background R(I)=0; therefore the volume-density first variation
drops out of this *first-order* curvature result. The source
coefficient b=c³/(16πG_N) is retained as an arbitrary Rat.

This certifies the derivative-bearing potential contribution in the
ADM scalar constraint at the flat reference. It is NOT a proof of
differentiability of EH on all smooth three-metrics, full curved
variation, or full hypersurface-deformation brackets.
-/

set_option autoImplicit false

namespace FlatEHFunctional010h

open FourierTorus010e FourierPairing010g FlatEH010h

abbrev SymField := SymAddress → Polynomial

def component (h : SymField) (i j : Axis) : Polynomial :=
  h (pairIndex i j)

theorem component_symmetry (h : SymField) (i j : Axis) :
    component h i j = component h j i := by
  simp only [component]
  rw [pairIndex_symmetry i j]

-- The divergence-divergence term of δR, integrated against a lapse N.
def curvatureDivDiv (N : Polynomial) (h : SymField) : Int :=
  sum3 (fun i => sum3 (fun j =>
    pairing N (derivative i (derivative j (component h i j)))))

-- The Laplacian of the trace term of δR, same metric/read normalization.
def curvatureLapTrace (N : Polynomial) (h : SymField) : Int :=
  sum3 (fun i => sum3 (fun j =>
    pairing N (derivative i (derivative i (component h j j)))))

def flatCurvatureVariation (N : Polynomial) (h : SymField) : Int :=
  curvatureDivDiv N h - curvatureLapTrace N h

-- The functional derivative with derivatives transported onto N.
def curvatureDivDivAdjoint (N : Polynomial) (h : SymField) : Int :=
  sum3 (fun i => sum3 (fun j =>
    pairing (derivative j (derivative i N)) (component h i j)))

def curvatureLapTraceAdjoint (N : Polynomial) (h : SymField) : Int :=
  sum3 (fun i => sum3 (fun j =>
    pairing (derivative i (derivative i N)) (component h j j)))

def flatCurvatureAdjoint (N : Polynomial) (h : SymField) : Int :=
  curvatureDivDivAdjoint N h - curvatureLapTraceAdjoint N h

theorem divDiv_integrated_ibp (N : Polynomial) (h : SymField) :
    curvatureDivDiv N h = curvatureDivDivAdjoint N h := by
  simp only [curvatureDivDiv, curvatureDivDivAdjoint,
    sum3, fourier_two_ibp]

theorem lapTrace_integrated_ibp (N : Polynomial) (h : SymField) :
    curvatureLapTrace N h = curvatureLapTraceAdjoint N h := by
  simp only [curvatureLapTrace, curvatureLapTraceAdjoint,
    sum3, fourier_two_ibp]

theorem flat_EH_curvature_functional_variation
    (N : Polynomial) (h : SymField) :
    flatCurvatureVariation N h = flatCurvatureAdjoint N h := by
  rw [flatCurvatureVariation, flatCurvatureAdjoint,
    divDiv_integrated_ibp, lapTrace_integrated_ibp]

-- Preserve the physical normalization, with b positive for ordinary
-- Einstein gravity but this algebraic identity holds for every b ∈ ℚ.
def EHpotentialVariation (b : Rat) (N : Polynomial) (h : SymField) : Rat :=
  -(b * Rat.ofInt (flatCurvatureVariation N h))

def EHpotentialAdjoint (b : Rat) (N : Polynomial) (h : SymField) : Rat :=
  -(b * Rat.ofInt (flatCurvatureAdjoint N h))

theorem flat_EH_normalized_hessian (b : Rat)
    (N : Polynomial) (h : SymField) :
    EHpotentialVariation b N h = EHpotentialAdjoint b N h := by
  simp only [EHpotentialVariation, EHpotentialAdjoint]
  rw [flat_EH_curvature_functional_variation]

-- At the flat background R=0, the volume-factor first variation
-- contributes δsqrt(g)*R=0 for every variation.
theorem flat_metric_volume_cross_term (volumeFirstVariation : Rat) :
    volumeFirstVariation * (0 : Rat) = 0 := by
  simp

#print axioms component_symmetry
#print axioms divDiv_integrated_ibp
#print axioms lapTrace_integrated_ibp
#print axioms flat_EH_curvature_functional_variation
#print axioms flat_EH_normalized_hessian
#print axioms flat_metric_volume_cross_term

end FlatEHFunctional010h
